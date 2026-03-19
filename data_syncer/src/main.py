from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from .sync import sync_data
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="London Travel Data Sync API")

class SyncRequest(BaseModel):
    db_url: Optional[str] = None

@app.post("/sync")
def trigger_sync(request: SyncRequest):
    logger.info(f"Received sync request targeting DB: {request.db_url or 'default'}")
    try:
        sync_data(db_url=request.db_url)
        return {"status": "success", "message": "Data synchronized successfully"}
    except Exception as e:
        logger.error(f"Error during synchronization: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/read")
def get_metadata(request: SyncRequest):
    logger.info(f"Received sync request targeting DB: {request.db_url or 'default'}")
    try:
        # get metadata from the database, such as tablenames, number of rows in each table, column names and types
        return {}
        
    except Exception as e:
        logger.error(f"Error during synchronization: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.main:app", host="0.0.0.0", port=8001, reload=True)
