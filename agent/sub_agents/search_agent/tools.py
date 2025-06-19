# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This file contains the tools used by the database agent."""

import logging
import re
from pydantic import BaseModel
import requests 
import json
import psycopg2
from pgvector.psycopg2 import register_vector
from google import genai
from google.adk.tools import ToolContext
from google.genai import Client
from ...config import Config 

configs = Config()

llm_client = Client(vertexai=True, project=configs.project, location=configs.location)

# Global variables to store database settings and PostgreSQL client connection
database_settings = None
_pgsql_conn = None # Store the connection globally to reuse


class activity(BaseModel):
    activity_id: str
    name: str
    description: str
    cost: float # Changed from int to float to accommodate NUMERIC DB type
    duration_min: int
    duration_max: int
    kid_friendliness_score: int

class SQL_query_output(BaseModel):
    sql_query: str
    justification: str

class actvities_search_output(BaseModel):
    activities_list: list[activity] | None = None
    error_message: str

def get_pgsql_client():
    """
    Establishes and returns a PostgreSQL database connection using psycopg2.
    Ensures the pgvector extension is enabled.
    This function will attempt to reuse an existing connection.
    """
    global _pgsql_conn
    # Check if connection exists and is still open.
    # The 'closed' attribute is 0 for open, non-zero for closed/invalid.
    if _pgsql_conn is None or _pgsql_conn.closed != 0:
        try:
            _pgsql_conn = psycopg2.connect(
                host=configs.db_host,
                port=configs.db_port,
                database=configs.db_name,
                user=configs.db_user,
                password=configs.db_pwd
            )
            # Set autocommit to True before operations that might conflict with transactions
            _pgsql_conn.autocommit = True

            # Register the vector type for psycopg2 to handle pgvector data
            # This should now happen with autocommit=True.
            register_vector(_pgsql_conn) 

            with _pgsql_conn.cursor() as cur:
                # Enable the pgvector extension if not already enabled.
                # This is an idempotent operation.
                cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
            
            # Set autocommit back to False if subsequent application logic
            # relies on explicit transaction management (BEGIN/COMMIT/ROLLBACK).
            _pgsql_conn.autocommit = False
            print("PostgreSQL database connected successfully and pgvector extension ensured.")
        except Exception as e:
            print(f"Error connecting to PostgreSQL: {e}")
            if _pgsql_conn and not _pgsql_conn.closed: # If connection object exists and is not closed
                _pgsql_conn.close() # Close it to release resources
            _pgsql_conn = None # Reset connection on failure
    return _pgsql_conn


def get_database_settings():
    """
    Retrieves and returns database settings.
    If settings are not loaded, it calls update_database_settings to load them.
    """
    global database_settings
    if database_settings is None:
        database_settings = update_database_settings()
    return database_settings


def update_database_settings():
    """
    Updates and returns database settings.
    For a local PostgreSQL database, you would typically fetch the schema
    dynamically using `information_schema` views.
    For this example, a hardcoded schema is provided.
    Ensure `embedding` dimension matches your actual LLM output (e.g., 768 or 1536).
    """
    global database_settings
    database_settings = {
        "pgsql_ddl_schema": """
            CREATE TABLE IF NOT EXISTS activities (
                activity_id SERIAL PRIMARY KEY,
                name VARCHAR(255),
                description TEXT,
                embedding vector(768), -- IMPORTANT: Ensure this dimension (768) matches your LLM's embedding output
                duration_min INT, -- Duration in minutes
                duration_max INT, -- Duration in minutes
                kid_friendliness_score INT, -- Score from 0-10
                cost NUMERIC(10, 2) -- Monetary cost
            );
            """
    }
    return database_settings


async def get_embedding_tool (
    vector_query: str,
    tool_context: ToolContext,
) -> list[float]:
    """Tool to create vector embedding for the vector search components of the user's query."""
    try:
       tool_context.state["get_embedding_tool_input"] = vector_query
       client = genai.Client()
       response = client.models.embed_content(
       model=configs.embedding_model_name,
       contents=vector_query,)
       if configs.debug_state:
        tool_context.state["get_embedding_tool_embedding_dimension"] = len(response.embeddings[0].values)
       return response.embeddings[0].values
    except requests.exceptions.RequestException as e:
        logging.error(f"Error generating embedding for text '{vector_query}': {e}")
        tool_context.state["get_embedding_tool_error"] = f"Error generating embedding for text '{vector_query}': {e}"
        return None
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding JSON response for text '{vector_query}': {e}")
        tool_context.state["get_embedding_tool_error"] = f"Error decoding JSON response for text '{vector_query}': {e}"
        return None

# generate a get_data_tool that first calls the get_embedding_tool, followed by the get_sql_query_tool and finally,  get_data_from_db_tool. Clean up the methods abd remove redundancies
async def get_activities_tool(
    vector_query: str,
    keyword_queries: str,
    tool_context: ToolContext,
) -> str:
    """Tool to get data from the database using NL2SQL."""
    tool_context.state["get_data_tool_input"] = {"vector_query": vector_query, "keyword_queries": keyword_queries}
    if vector_query != "":
        embedding = await get_embedding_tool(vector_query, tool_context)
    else:
        embedding = None

    where_clause = await get_sql_where_clause_tool(keyword_queries, tool_context)
    table_name = "activities"
    if where_clause != "":
        if embedding:
            sql_query = f"""
            SELECT * FROM {table_name} 
            WHERE {where_clause}
            ORDER BY 
            embedding <#> '{embedding}'
            LIMIT {configs.max_rows}; 
            """
        else:
            sql_query = f"""
            SELECT * FROM {table_name} 
            WHERE {where_clause}
            LIMIT {configs.max_rows}; 
            """
    else:
        if embedding:
            sql_query = f"""
            SELECT * FROM {table_name} 
            ORDER BY 
            embedding <#> '{embedding}'
            LIMIT {configs.max_rows}; 
            """
        else:
            sql_query = f"""
            SELECT * FROM {table_name} 
            LIMIT {configs.max_rows}; 
            """
    if configs.debug_state:
        tool_context.state["get_data_tool_sql_query"] = sql_query

    results = await get_data_from_db_tool(sql_query, tool_context)

    if not results:
        return str(actvities_search_output(activities_list=None, error_message="Failed to get results."))

    return str(results)
    
async def get_sql_where_clause_tool(
    keyword_queries: str,
    tool_context: ToolContext,
) -> str:
    """Generates an initial PostgreSQL SQL query from a natural language question.

    This function leverages an LLM to construct an SQL query based on the
    provided database schema and a sql query params string. 

    Args:
        keyword_queries (string): A string that respresents the list of keyword queries. 
        tool_context (ToolContext): The ADK (Agent Development Kit) tool context,
            providing access to shared state, invocation details, and other
            contextual information relevant to the agent's operation.
    Returns:
        SQL_query_output: A Pydantic model containing the generated SQL query
            and a justification for its creation.
    """

    # Get the latest database settings/schema. This call ensures
    # `database_settings` global variable is populated.
    get_database_settings()
    tool_context.state["get_sql_where_clause_tool_input"] = keyword_queries 

    prompt_template = """
    You are an AI assistant serving as an expert in converting keywords into the WHERE clauses of the **PostgreSQL SQL queries**.
    Your primary goal is to take keywords (eg: "duration <= 3 days") that express their travel constraints and translate into a WHERE clause of a PostgreSQL query. 
    The schema of the db is given below.

    You must produce your final response as a JSON format with the following four keys:
    - "justification": A step-by-step reasoning explaining how you generated the SQL query based on the schema, examples, and the input.
    - "where": The where clause of the query

    **Important Directives:**
    -   **Schema Adherence**: Strictly adhere to the provided database schema (including column names and `pgvector` usage) creating the sql_query.

    **Schema:**
    The database structure is defined by the following table schemas (possibly with sample rows):
    ```
    {SCHEMA}
    ```
    duration_min and duration_min are expressed in minutes
    cost is expressed in euros
    If there is a vector embedding, then query the embedding column

    Query Parameters that need to be translated into SQL
    
    ```
    {QUERY_PARAMS}
    ```

    **Think Step-by-Step:** Carefully consider the schema, embedding, and keyword queries, and all guidelines to generate and validate the correct PostgreSQL SQL.

   """

    # Ensure ddl_schema is obtained from the global database_settings
    ddl_schema = database_settings.get("pgsql_ddl_schema", "")
    if not ddl_schema:
        print("Warning: Database schema is not available. Please ensure update_database_settings() populates it or fetch it dynamically.")

    try:
        prompt = prompt_template.format(
            MAX_NUM_ROWS=configs.max_rows, SCHEMA=ddl_schema, QUERY_PARAMS=keyword_queries
        )

        response = llm_client.models.generate_content( 
            model=configs.agent_settings.model,
            contents=prompt,
            config={"temperature": 0.1},
        )

        response_text = response.text
        if configs.debug_state:
            tool_context.state["get_sql_where_clause_llm_output"] = response_text

        json_text = response_text.replace("```json", "").replace("```", "").strip()
        json_obj = json.loads(json_text)
        where_clause = json_obj.get("where", "")
        if configs.debug_state:
            tool_context.state["get_sql_where_clause_output"] = where_clause
        return where_clause
    except Exception as e:
        print(f"Error generating SQL: {e}")
        tool_context.state["get_sql_where_clause_error"] = f"Error generating SQL: {e}"
        return None

async def get_data_from_db_tool(
    sql_string: str,
    tool_context: ToolContext,
) -> actvities_search_output:
    """
    Validates PostgreSQL SQL syntax and functionality by executing it in a dry-run
    or limited fashion against the PostgreSQL database.

    This function performs the following checks:
    1. **SQL Cleanup:** Preprocesses the SQL string using a `cleanup_sql` function.
    2. **DML/DDL Restriction:** Rejects any SQL queries containing DML or DDL
       statements (e.g., UPDATE, DELETE, INSERT, CREATE, ALTER) to ensure
       read-only operations.
    3. **Syntax and Execution:** Attempts to execute the cleaned SQL. If the query
       is syntactically correct and executable, it retrieves the results.
    4. **Result Analysis:** Checks if the query produced any results. If so, it
       formats the first few rows of the result set for inspection.

    Args:
        sql_string (str): The SQL query string to validate.
        tool_context (ToolContext): The tool context to use for validation.

    Returns:
        actvities_search_output: An object indicating the validation outcome. This includes:
              - "activities": List of activities if query is valid and returns data.
              - "error_message": String with error details if query is invalid or
                                 contains disallowed operations.
    """

    def cleanup_sql(sql_input_string):
        """Processes the SQL string to get a printable, valid SQL string."""

        # 1. Remove backslashes escaping double quotes
        sql_output_string = sql_input_string.replace('\\"', '"')

        # 2. Remove backslashes before newlines (e.g., in multi-line string literals)
        sql_output_string = sql_output_string.replace("\\\n", "\n")

        # 3. Replace escaped single quotes
        sql_output_string = sql_output_string.replace("\\'", "'")

        # 4. Replace escaped newlines (those not preceded by a backslash, from LLM output)
        sql_output_string = sql_output_string.replace("\\n", "\n")

        # 5. Add limit clause if not present (case-insensitive check for common forms)
        # Using regex to be more robust
        if not re.search(r'\sLIMIT\s+\d+', sql_output_string, re.IGNORECASE):
            sql_output_string += f" LIMIT {configs.max_rows}"

        return sql_output_string

    logging.info("Validating SQL")
    cleaned_sql_string = cleanup_sql(sql_string)
    output = actvities_search_output(error_message="")


    logging.info("Validating SQL (after cleanup): %s", cleaned_sql_string)

    # More restrictive check for PostgreSQL - disallow DML and DDL.
    # Using word boundaries (\b) for more precise matching.
    if re.search(
        r"(?i)\b(update|delete|drop|insert|create|alter|truncate|merge)\b", cleaned_sql_string
    ):
        output.error_message ="Invalid SQL: Contains disallowed DML/DDL operations."
        return output

    conn = None
    cur = None
    try:
        conn = get_pgsql_client()
        if not conn: # Ensure connection was successful
            raise ConnectionError("Failed to establish PostgreSQL connection.")

        cur = conn.cursor()
        cur.execute(cleaned_sql_string)

        # If it's a SELECT query, fetch results.
        # cursor.description will be None for non-SELECT statements (e.g., DDL/DML).
        if cur.description:
            column_names = [desc[0] for desc in cur.description]
            db_rows = cur.fetchall()

            # Format results into a list of dictionaries for easier consumption.
            formatted_rows = []
            for row_data in db_rows:
                formatted_rows.append(dict(zip(column_names, row_data)))
            
            # format output into object of type activities
            activities_list = []
            try:
                for row in formatted_rows:
                    activity_obj = activity(
                        activity_id=row.get('activity_id'),
                        name=row.get('name'),
                        description=row.get('description'),
                        cost=row.get('cost'),
                        duration_min=row.get('duration_min'),
                        duration_max=row.get('duration_max'),
                        kid_friendliness_score=row.get('kid_friendliness_score')
                    )
                    activities_list.append(activity_obj)
                            
                output.activities_list = activities_list
                print("activities are: ", output.activities_list)
                if configs.debug_state:
                    tool_context.state["get_data_from_db_tool_output"] = output.activities_list
            except Exception as format_error:
                output.error_message = f"Error formatting row into activity object: {format_error}"
                tool_context.state["query_result_error"] = output.error_message
                logging.error(output.error_message)
        else:
            tool_context.state["get_data_from_db_tool_error"] =  "Valid SQL. Query executed successfully (no results)."

    except psycopg2.Error as e:
        output.error_message = f"Invalid SQL: Database error (SQLSTATE {e.pgcode}) - {e.pgerror.strip()}"
    except ConnectionError as e:
        output.error_message = f"Database Connection Error: {e}"
    except Exception as e:
       output.error_message = f"Invalid SQL: An unexpected error occurred - {e}"
    finally:
        tool_context.state["get_data_from_db_tool_error"] = output.error_message
        if cur:
            cur.close()

    return output

# Example usage (for testing purposes, if you run this script directly)
if __name__ == "__main__":
    print("Initializing database tools...")
    # Ensure database_settings is loaded before any prompt generation or validation
    get_database_settings()
    
    # Example of getting a connection (for testing connectivity)
    conn = get_pgsql_client()
    if conn:
        print("Test connection successful.")
    else:
        print("Test connection failed.")
