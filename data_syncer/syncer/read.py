
from sqlalchemy import create_engine, inspect, text
from syncer.database import engine as default_engine
        
def read_data(db_url=None):
      if db_url:
          engine = create_engine(db_url)
      else:
          engine = default_engine
          
      inspector = inspect(engine)
      metadata = {}
      for table_name in inspector.get_table_names():
          table_info = {}
          columns = inspector.get_columns(table_name)
          table_info["columns"] = [{"name": col["name"], "type": str(col["type"])} for col in columns]
          
          with engine.connect() as conn:
              count_query = text(f"SELECT COUNT(*) FROM {table_name}")
              result = conn.execute(count_query).scalar()
              table_info["row_count"] = result
              
          metadata[table_name] = table_info
          
      return metadata