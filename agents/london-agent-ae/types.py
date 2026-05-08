from pydantic import BaseModel, Field
from typing import List
 
class ItineraryItem(BaseModel):
    day: int = Field(description="The day of the itinerary eg 0, 1, 2 etc.")
    time: str = Field(description="The time of the activity or location. eg morning, afternoon, evening.")
    name: str = Field(description="The name of the activity or location.")
    description: str = Field(description="The description of the item or location.")
    duration: str = Field(description="The duration of the activity in natural language eg 2 hours.")
    cost: str = Field(description="The cost of the activity in natural language eg Free or 20 pounds.")
    kid_friendly: str = Field(description="Whether the activity is kid friendly eg Yes or No.")
    
    
class AgentOutput(BaseModel):
    text_response: str = Field(description="The conversational response to the user.")
    recommendations: List[ItineraryItem] = Field(description="The list of activities to do in London.")
    error: str = Field(description="The error message if any.")

