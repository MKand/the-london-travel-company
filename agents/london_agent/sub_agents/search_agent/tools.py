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
import requests
import json
import sqlite3
import sqlite_vec
import asyncio
import os
from pydantic import BaseModel
from google import genai
from google.adk.tools import ToolContext
from google.genai import Client
from ...config import Config
from ...utils import write_to_tool_context

configs = Config()
base_dir = os.path.dirname(os.path.abspath(__name__))

llm_client = Client(vertexai=True, project=configs.project, location=configs.location)

# Global variables to store database settings and SQLite client connection
database_settings = None
_sqlite_conn = None  # Store the connection globally to reuse

class activity(BaseModel):
    activity_id: str
    name: str
    description: str
    cost: float
    duration_min: int
    duration_max: int
    kid_friendliness_score: int


class SQL_query_output(BaseModel):
    sql_query: str
    justification: str


class actvities_search_output(BaseModel):
    activities_list: list[activity] | None = None
    error_message: str


def setup_sqlite_client():
    """
    Establishes and returns a SQLite database connection.
    If the database file does not exist, it copies it from a default location.
    Ensures the sqlite-vec extension is loaded.
    This function will attempt to reuse an existing connection.
    """
    global _sqlite_conn
    if _sqlite_conn is None:
        try:
            if not os.path.exists(configs.db_file_path):
                raise Exception(f"Database not found at {configs.db_file_path}")
            
            # load the data in configs.db_file_path  which is a .sql file to the sqllite db
            with open(configs.db_file_path, 'r') as f:
                sql_script = f.read()
            
            _sqlite_conn = sqlite3.connect(":memory:")
            temp_cursor = _sqlite_conn.cursor()
            temp_cursor.executescript(sql_script)
            logging.info(f"Database created and loaded from {configs.db_file_path}")
            _sqlite_conn.enable_load_extension(True)
            sqlite_vec.load(_sqlite_conn)
            logging.info("SQLite database connected successfully and sqlite-vec extension loaded.")
            temp_cursor.close()
            return _sqlite_conn
        except Exception as e:
            print(f"Error connecting to SQLite: {e}")
            if _sqlite_conn:
                _sqlite_conn.close()
            _sqlite_conn = None
            return None
    else:
        return _sqlite_conn

def get_database_settings():
    """
    Retrieves and returns database settings.
    If settings are not loaded, it loads them from a hardcoded schema.
    """
    global database_settings
    if database_settings is None:
        database_settings = {
            "sqlite_ddl_schema": """
            TABLE activities (
                activity_id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                duration_min INT,
                duration_max INT,
                kid_friendliness_score INT,
                cost INT,
                sight_id VARCHAR(50) REFERENCES locations(sight_id), -- Foreign key to locations table
                description TEXT,
                embedding VECTOR(768);
            """
    }
    return database_settings


async def get_embedding_tool(
    vector_query: str,
    tool_context: ToolContext = None,
) -> list[float]:
    """Tool to create vector embedding for the vector search components of the user's query."""
    try:

        write_to_tool_context("get_embedding_tool_input", vector_query, tool_context)
        client = genai.Client()
        response = client.models.embed_content(
            model=configs.embedding_model_name,
            contents=vector_query,
        )
        if configs.debug_state:
            write_to_tool_context("get_embedding_tool_output", response.embeddings[0].values, tool_context)
        return response.embeddings[0].values
    except requests.exceptions.RequestException as e:
        logging.error(f"Error generating embedding for text '{vector_query}': {e}")
        write_to_tool_context("get_embedding_tool_error", f"Error generating embedding for text '{vector_query}': {e}", tool_context)
        return None
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding JSON response for text '{vector_query}': {e}")
        write_to_tool_context("get_embedding_tool_error", f"Error decoding JSON response for text '{vector_query}': {e}", tool_context)
        return None


async def get_activities_tool(
    vector_query: str,
    keyword_queries: str,
    tool_context: ToolContext=None,
) -> str:
    write_to_tool_context("get_activities_tool_input", {"vector_query": vector_query, "keyword_queries": keyword_queries}, tool_context)
    embedding = None
    if vector_query != "":
        embedding = await get_embedding_tool(vector_query, tool_context)

    where_clause = await get_sql_where_clause_tool(keyword_queries, tool_context)

    sql_query = ""
    params = []

    sql_query += "SELECT activity_id, name, description, cost, duration_min, duration_max, kid_friendliness_score, sight_id "
    if embedding:
        sql_query+= f", vec_distance_cosine(embedding, vec_f32('{embedding}')) AS score "
        
    
    sql_query += f"""
    FROM activities 
    """
    if where_clause:
        sql_query += f"""
        WHERE {where_clause} 
        """
    
    sql_query += f"""ORDER BY score ASC 
    LIMIT {configs.max_rows};
    """

    if configs.debug_state:
        write_to_tool_context("get_data_tool_sql_query", sql_query, tool_context)

    results = await get_data_from_db_tool(sql_query, params, tool_context)

    if not results:
        return str(actvities_search_output(activities_list=None, error_message="Failed to get results."))

    return str(results)


async def get_sql_where_clause_tool(
    keyword_queries: str,
    tool_context: ToolContext=None,
) -> str:
    """Generates an initial SQLite SQL query from a natural language question.

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

    get_database_settings()
    write_to_tool_context("get_sql_where_clause_tool_input", keyword_queries, tool_context)

    prompt_template = """
    You are an AI assistant serving as an expert in converting keywords into the WHERE clauses of the **SQLite SQL queries**.
    Your primary goal is to take keywords (eg: "duration <= 3 days") that express their travel constraints and translate into a WHERE clause of a SQLite query.
    The schema of the db is given below.

    You must produce your final response as a JSON format with the following four keys:
    - "justification": A step-by-step reasoning explaining how you generated the SQL query based on the schema, examples, and the input.
    - "where": The where clause of the query

    **Important Directives:**
    -   **Schema Adherence**: Strictly adhere to the provided database schema creating the sql_query.

    **Schema:**
    The database structure is defined by the following table schemas (possibly with sample rows):
    ```
    {SCHEMA}
    ```
    duration_min and duration_max are expressed in minutes
    cost is expressed in euros

    Query Parameters that need to be translated into SQL

    ```
    {QUERY_PARAMS}
    ```

    **Think Step-by-Step:** Carefully consider the schema and keyword queries, and all guidelines to generate and validate the correct SQLite SQL.

   """

    ddl_schema = database_settings.get("sqlite_ddl_schema", "")
    if not ddl_schema:
        logging.warning("Database schema is not available. Please ensure update_database_settings() populates it or fetch it dynamically.")

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
            write_to_tool_context("get_sql_where_clause_llm_prompt", prompt, tool_context)

        json_text = response_text.replace("```json", "").replace("```", "").strip()
        json_obj = json.loads(json_text)
        where_clause = json_obj.get("where", "")
        if configs.debug_state:
            write_to_tool_context("get_sql_where_clause_output", where_clause, tool_context)
        return where_clause
    except Exception as e:
        logging.error(f"Error generating SQL: {e}")
        write_to_tool_context("get_sql_where_clause_error", f"Error generating SQL: {e}", tool_context)
        return None


async def get_data_from_db_tool(
    sql_string: str,
    params: list,
    tool_context: ToolContext = None,
) -> actvities_search_output:
    """
    Validates SQLite SQL syntax and functionality by executing it against the SQLite database.

    This function performs the following checks:
    1. **DML/DDL Restriction:** Rejects any SQL queries containing DML or DDL
       statements (e.g., UPDATE, DELETE, INSERT, CREATE, ALTER) to ensure
       read-only operations.
    2. **Syntax and Execution:** Attempts to execute the SQL. If the query
       is syntactically correct and executable, it retrieves the results.
    3. **Result Analysis:** Checks if the query produced any results. If so, it
       formats the results.

    Args:
        sql_string (str): The SQL query string to validate.
        params (list): The parameters to pass to the SQL query.
        tool_context (ToolContext): The tool context to use for validation.

    Returns:
        actvities_search_output: An object indicating the validation outcome.
    """

    output = actvities_search_output(error_message="")

    logging.debug("Validating SQL: %s", sql_string)

    if re.search(
        r"(?i)\b(update|delete|drop|insert|create|alter|truncate|merge)\b", sql_string
    ):
        output.error_message = "Invalid SQL: Contains disallowed DML/DDL operations."
        return output

    conn = None
    cur = None
    try:
        conn = setup_sqlite_client()
        if not conn:
            raise ConnectionError("Failed to establish SQLite connection.")

        cur = conn.cursor()
        cur.execute(sql_string, params)

        if cur.description:
            column_names = [desc[0] for desc in cur.description]
            db_rows = cur.fetchall()

            formatted_rows = []
            for row_data in db_rows:
                formatted_rows.append(dict(zip(column_names, row_data)))

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
                
                logging.info(f"Number of activities returned: {len(activities_list)}")

                output.activities_list = activities_list
                if configs.debug_state and tool_context is not None:
                    write_to_tool_context("get_data_from_db_tool_output", output.activities_list, tool_context)
            except Exception as format_error:
                output.error_message = f"Error formatting row into activity object: {format_error}"
                write_to_tool_context("get_data_from_db_tool_error", output.error_message, tool_context)
                logging.error(output.error_message)
        else:
            write_to_tool_context("get_data_from_db_tool_error", "Valid SQL. Query executed successfully (no results).", tool_context)

    except sqlite3.Error as e:
        output.error_message = f"Invalid SQL: Database error - {e}"
    except ConnectionError as e:
        output.error_message = f"Database Connection Error: {e}"
    except Exception as e:
        output.error_message = f"Invalid SQL: An unexpected error occurred - {e}"
    finally:
        write_to_tool_context("get_data_from_db_tool_error", output.error_message, tool_context)
        if cur:
            cur.close()

    return output


if __name__ == "__main__":
    logging.info("Initializing database tools...")
    get_database_settings()
    conn = setup_sqlite_client()
    if conn:
        logging.info("Test connection successful.")
    else:
        logging.info("Test connection failed.")
    asyncio.run(get_activities_tool("museums", "less than 3 hours", None))
