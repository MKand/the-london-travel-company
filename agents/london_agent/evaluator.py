import asyncio
import os
import sys
import pandas as pd
import dotenv
from google.cloud import bigquery

# Load environment variables from .env file before importing agent modules
script_dir = os.path.dirname(os.path.abspath(__file__))
dotenv.load_dotenv(os.path.join(script_dir, ".env"))

# Map environment variables for Vertex AI Eval SDK (needed for safety_v1)
if 'PROJECT_ID' in os.environ and 'GOOGLE_CLOUD_PROJECT' not in os.environ:
    os.environ['GOOGLE_CLOUD_PROJECT'] = os.environ['PROJECT_ID']
if 'LOCATION' in os.environ and 'GOOGLE_CLOUD_LOCATION' not in os.environ:
    os.environ['GOOGLE_CLOUD_LOCATION'] = os.environ['LOCATION']

# Add the 'agents' directory to sys.path so that 'london_agent' can be found
agents_dir = os.path.abspath(os.path.join(script_dir, ".."))
sys.path.append(agents_dir)

from google.adk.cli.cli_eval import _collect_eval_results, _collect_inferences, get_root_agent
from google.adk.cli.cli_eval import _convert_content_to_text, _convert_tool_calls_to_text
from google.adk.evaluation.eval_config import get_eval_metrics_from_config, get_evaluation_criteria_or_default
from google.adk.evaluation.in_memory_eval_sets_manager import InMemoryEvalSetsManager
from google.adk.evaluation.local_eval_service import LocalEvalService
from google.adk.evaluation.local_eval_set_results_manager import LocalEvalSetResultsManager
from google.adk.evaluation.local_eval_sets_manager import load_eval_set_from_file
from google.adk.evaluation.simulation.user_simulator_provider import UserSimulatorProvider
from google.adk.evaluation.base_eval_service import InferenceConfig, InferenceRequest

async def main():
    agent_module_file_path = script_dir # This is 'london_agent' directory
    eval_set_file_path = os.path.join(script_dir, "evalset.evalset.json")
    config_file_path = os.path.join(script_dir, "eval_config.json")
    
    app_name = os.path.basename(agent_module_file_path)
    
    # 1. Load config
    eval_config = get_evaluation_criteria_or_default(config_file_path)
    eval_metrics = get_eval_metrics_from_config(eval_config)
    
    # 2. Get root agent
    root_agent = get_root_agent(agent_module_file_path)
    
    # 3. Setup managers
    eval_sets_manager = InMemoryEvalSetsManager()
    eval_set_results_manager = LocalEvalSetResultsManager(agents_dir=agents_dir)
    
    # 4. Load eval set
    eval_set = load_eval_set_from_file(eval_set_file_path, eval_set_file_path)
    eval_sets_manager.create_eval_set(app_name=app_name, eval_set_id=eval_set.eval_set_id)
    for eval_case in eval_set.eval_cases:
        eval_sets_manager.add_eval_case(app_name=app_name, eval_set_id=eval_set.eval_set_id, eval_case=eval_case)
        
    # 5. Create inference request
    inference_requests = [
        InferenceRequest(
            app_name=app_name,
            eval_set_id=eval_set.eval_set_id,
            eval_case_ids=[], # Run all cases
            inference_config=InferenceConfig(),
        )
    ]
    
    # 6. Setup service
    user_simulator_provider = UserSimulatorProvider(
        user_simulator_config=eval_config.user_simulator_config
    )
    
    eval_service = LocalEvalService(
        root_agent=root_agent,
        eval_sets_manager=eval_sets_manager,
        eval_set_results_manager=eval_set_results_manager,
        user_simulator_provider=user_simulator_provider,
    )
    
    # 7. Run inference and eval
    print("Running inferences...")
    inference_results = await _collect_inferences(inference_requests=inference_requests, eval_service=eval_service)
    
    print("Running evaluation...")
    eval_results = await _collect_eval_results(inference_results=inference_results, eval_service=eval_service, eval_metrics=eval_metrics)
    
    # 8. Process results into detailed DataFrame
    detailed_rows = []
    for eval_result in eval_results:
        eval_id = eval_result.eval_id
        
        # Extract overall scores for this case
        overall_scores = {}
        for metric in eval_result.overall_eval_metric_results:
            overall_scores[f"overall_{metric.metric_name}"] = metric.score
            
        for per_invocation_result in eval_result.eval_metric_result_per_invocation:
            actual_invocation = per_invocation_result.actual_invocation
            expected_invocation = per_invocation_result.expected_invocation
            
            row_data = {
                "invocation_id": actual_invocation.invocation_id,
                "eval_id": eval_id,
                "prompt": _convert_content_to_text(actual_invocation.user_content),
                "expected_response": _convert_content_to_text(expected_invocation.final_response) if expected_invocation else None,
                "actual_response": _convert_content_to_text(actual_invocation.final_response),
                "expected_tool_calls": _convert_tool_calls_to_text(expected_invocation.intermediate_data) if expected_invocation else None,
                "actual_tool_calls": _convert_tool_calls_to_text(actual_invocation.intermediate_data),
            }
            
            # Add per-invocation scores
            for metric_result in per_invocation_result.eval_metric_results:
                row_data[metric_result.metric_name] = metric_result.score
                
            # Add overall scores (repeated for each turn of the case)
            row_data.update(overall_scores)
                
            detailed_rows.append(row_data)
            
    df = pd.DataFrame(detailed_rows)
    print("\nEvaluation Results DataFrame (Detailed):")
    print(df)
    
    # Save to CSV
    output_csv = os.path.join(script_dir, "eval_results.csv")
    df.to_csv(output_csv, index=False)
    print(f"\nSaved results to {output_csv}")
    
    # 9. Upload to BigQuery (Upsert logic)
    print("\nUploading results to BigQuery...")
    try:
        bq_client = bigquery.Client()
        dataset_id = "agent_telemetry"
        table_id = "agent_evals"
        staging_table_id = "agent_evals_staging"
        
        project = bq_client.project
        
        # Create dataset if it doesn't exist
        dataset_ref = bq_client.dataset(dataset_id)
        try:
            bq_client.get_dataset(dataset_ref)
            print(f"Dataset {dataset_id} already exists.")
        except Exception:
            print(f"Dataset {dataset_id} not found. Creating it...")
            dataset = bigquery.Dataset(dataset_ref)
            dataset.location = os.environ.get("LOCATION", "US")
            bq_client.create_dataset(dataset)
            print(f"Dataset {dataset_id} created.")
            
        table_ref = dataset_ref.table(table_id)
        staging_table_ref = dataset_ref.table(staging_table_id)
        
        # Check if target table exists
        try:
            bq_client.get_table(table_ref)
            table_exists = True
            print(f"Target table {table_id} exists. Performing upsert...")
        except Exception:
            table_exists = False
            print(f"Target table {table_id} does not exist. Creating it via direct load...")
            
        if not table_exists:
            # Load directly to target table (creates it)
            job_config = bigquery.LoadJobConfig(
                write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
            )
            job = bq_client.load_table_from_dataframe(df, table_ref, job_config=job_config)
            job.result()
            print(f"Successfully created and loaded results to {dataset_id}.{table_id}")
        else:
            # Upsert logic using a staging table and MERGE
            # 1. Load to staging table (overwrite)
            job_config = bigquery.LoadJobConfig(
                write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            )
            print("Loading data to staging table...")
            job = bq_client.load_table_from_dataframe(df, staging_table_ref, job_config=job_config)
            job.result()
            print("Staging table loaded.")
            
            # 2. Run MERGE query
            merge_query = f"""
            MERGE `{project}.{dataset_id}.{table_id}` T
            USING `{project}.{dataset_id}.{staging_table_id}` S
            ON T.invocation_id = S.invocation_id
            WHEN MATCHED THEN
              UPDATE SET
                eval_id = S.eval_id,
                prompt = S.prompt,
                expected_response = S.expected_response,
                actual_response = S.actual_response,
                expected_tool_calls = S.expected_tool_calls,
                actual_tool_calls = S.actual_tool_calls,
                tool_trajectory_avg_score = S.tool_trajectory_avg_score,
                final_response_match_v2 = S.final_response_match_v2,
                hallucinations_v1 = S.hallucinations_v1,
                safety_v1 = S.safety_v1,
                overall_tool_trajectory_avg_score = S.overall_tool_trajectory_avg_score,
                overall_final_response_match_v2 = S.overall_final_response_match_v2,
                overall_hallucinations_v1 = S.overall_hallucinations_v1,
                overall_safety_v1 = S.overall_safety_v1
            WHEN NOT MATCHED THEN
              INSERT ROW
            """
            print("Running MERGE query for upsert...")
            query_job = bq_client.query(merge_query)
            query_job.result()
            print(f"Successfully upserted results to {dataset_id}.{table_id}")
            
            # 3. Clean up staging table
            bq_client.delete_table(staging_table_ref, not_found_ok=True)
            print("Cleaned up staging table.")
            
    except Exception as e:
        print(f"Failed to upload to BigQuery: {e}")
        print("Make sure you have the correct Google Cloud credentials and 'pyarrow' installed if required.")

if __name__ == "__main__":
    asyncio.run(main())
