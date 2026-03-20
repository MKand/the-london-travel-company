from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from syncer.sync import sync_data
from syncer.read import read_data
import logging
import uvicorn

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

@app.post("/read")
def get_metadata(request: SyncRequest):
    logger.info(f"Received read request targeting DB: {request.db_url or 'default'}")
    try:
        response = read_data(db_url=request.db_url)
        return response
        
    except Exception as e:
        logger.error(f"Error extracting metadata: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001, reload=True)
