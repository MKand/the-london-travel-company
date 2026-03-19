from sqlalchemy import Column, String, Integer, Float, ForeignKey, Text
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.types import UserDefinedType
import json

Base = declarative_base()

class Vector(UserDefinedType):
    """Simple wrapper for pgvector/sqlite-vec handled as strings/lists by SQLAlchemy."""
    def get_col_spec(self, **kw):
        return "VECTOR(768)"

    def bind_processor(self, dialect):
        def process(value):
            if isinstance(value, list):
                return str(value)
            return value
        return process

    def result_processor(self, dialect, coltype):
        def process(value):
            if value is None:
                return None
            if isinstance(value, str):
                return json.loads(value)
            return value
        return process

class Location(Base):
    __tablename__ = "locations"
    
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    category = Column(String)
    description = Column(Text)
    embedding = Column(Vector)  # Abstracted vector column
    
    activities = relationship("Activity", back_populates="location")

class Activity(Base):
    __tablename__ = "activities"
    
    activity_id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    duration_min = Column(Integer)
    duration_max = Column(Integer)
    kid_friendliness_score = Column(Integer)
    cost = Column(Float)
    description = Column(Text)
    sight_id = Column(String, ForeignKey("locations.id")) # Linked to Location.id
    embedding = Column(Vector) # Vector for semantic search on activities
    
    location = relationship("Location", back_populates="activities")
