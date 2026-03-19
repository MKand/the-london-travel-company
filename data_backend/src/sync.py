import re
import json
import logging
from sqlalchemy.orm import Session
from .database import SessionLocal, init_db
from .models import Location, Activity
from .config import settings
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SQL_DUMP_PATH = "/Users/manasakandula/Documents/demos/london-travel-agent/data_london/london_travel.sql"

def parse_sql_dump(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern for locations: INSERT INTO locations VALUES('ID','Name','Category','Description','[Vector]');
    location_matches = re.finditer(r"INSERT INTO locations VALUES\('([^']+)','([^']+)','([^']+)','([^']+)','([^']+)'\);", content)
    
    locations = []
    for m in location_matches:
        locations.append({
            "id": m.group(1),
            "name": m.group(2),
            "category": m.group(3),
            "description": m.group(4),
            "embedding": json.loads(m.group(5))
        })

    # Pattern for activities: INSERT INTO activities VALUES('ID','Name',min,max,score,cost,'SightID','Description','[Vector]');
    # Note: cost can be integer or float, min/max/score are integers.
    activity_matches = re.finditer(r"INSERT INTO activities VALUES\('([^']+)','([^']*)',(\d+),(\d+),(\d+),([\d\.]+),'([^']+)','([^']*)','([^']+)'\);", content)
    
    activities = []
    for m in activity_matches:
        activities.append({
            "activity_id": m.group(1),
            "name": m.group(2),
            "duration_min": int(m.group(3)),
            "duration_max": int(m.group(4)),
            "kid_friendliness_score": int(m.group(5)),
            "cost": float(m.group(6)),
            "sight_id": m.group(7),
            "description": m.group(8),
            "embedding": json.loads(m.group(9))
        })
        
    return locations, activities

def sync_data():
    logger.info(f"Starting sync from {SQL_DUMP_PATH}")
    locations_data, activities_data = parse_sql_dump(SQL_DUMP_PATH)
    
    init_db()
    db: Session = SessionLocal()
    
    try:
        # Sync Locations
        for loc_dict in locations_data:
            loc = db.query(Location).filter(Location.id == loc_dict["id"]).first()
            if not loc:
                loc = Location(**loc_dict)
                db.add(loc)
            else:
                for key, value in loc_dict.items():
                    setattr(loc, key, value)
        
        db.commit()
        logger.info(f"Synced {len(locations_data)} locations.")

        # Sync Activities
        for act_dict in activities_data:
            act = db.query(Activity).filter(Activity.activity_id == act_dict["activity_id"]).first()
            if not act:
                act = Activity(**act_dict)
                db.add(act)
            else:
                for key, value in act_dict.items():
                    setattr(act, key, value)
                    
        db.commit()
        logger.info(f"Synced {len(activities_data)} activities.")
        
    except Exception as e:
        db.rollback()
        logger.error(f"Sync failed: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    sync_data()
