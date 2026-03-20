from pydantic import BaseModel, Field
from typing import List
 
class Item(BaseModel):
    name: str = Field(description="The name of the item.")
    description: str = Field(description="The description of the item.")

class SearchResult(BaseModel):
    items: List[Item] = Field(description="The list of items found.")
    

class Activity(Item):
    duration: str = Field(description="The duration of the activity in natural language eg 2 hours.")
    cost: str = Field(description="The cost of the activity in natural language eg Free or 20 pounds.")
    kid_friendly: str = Field(description="Whether the activity is kid friendly eg Yes or No.")
    
class Location(Item):
    category: str = Field(description="The category of the location.")

