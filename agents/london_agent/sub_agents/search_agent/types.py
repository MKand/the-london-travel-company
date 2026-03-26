from pydantic import BaseModel, Field
from typing import List
 
class Item(BaseModel):
    name: str = Field(description="The name of the item.", default="some name")
    description: str = Field(description="The description of the item.", default="some description")

class SearchResult(BaseModel):
    items: List[Item] = Field(description="The list of items found.", default=[])
    

class Activity(Item):
    duration: str = Field(description="The duration of the activity in natural language eg 2 hours.", default="1 hr")
    cost: str = Field(description="The cost of the activity in natural language eg Free or 20 pounds.", default="free")
    kid_friendly: str = Field(description="Whether the activity is kid friendly eg Yes or No.", default="no")
    
class Location(Item):
    category: str = Field(description="The category of the location.", default="some category")

