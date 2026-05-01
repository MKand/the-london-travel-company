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

from typing import List, Dict, Any
import random

import random

names = [
    "Aarav", "Bianca", "Chiaki", "Dimitri", "Fatima", "Giovanni", 
    "Hana", "Isaac", "Javier", "Kiran", "Lars", "Min-jun"
]

# Generic Interests (The "Classic" categories)
interests = [
    "major historical landmarks and royal palaces",
    "popular museums and art galleries",
    "shopping districts and local markets",
    "famous parks and botanical gardens",
    "traditional British pubs and classic dining",
    "theatre shows and West End musicals",
    "family-friendly attractions and sightseeing tours",
    "modern architecture and city skyline views",
    "hidden gems and quiet neighborhood walks",
    "afternoon tea spots and cozy cafes"
]

# Standard Fellow Travellers
fellow_travellers = [
    "a partner on a romantic getaway",
    "a young family with school-aged children",
    "a group of close friends",
    "my parents who prefer a slower pace",
    "myself—I am traveling solo",
    "a small group of work colleagues",
    "a group of students on a budget"
]

# Common Moods
moods = [
    "curious and eager to learn",
    "relaxed and not in a rush",
    "very energetic and wanting to see everything",
    "focused on finding the best photo spots",
    "a bit overwhelmed by the options",
    "practical and budget-conscious",
    "looking for a luxury, high-end experience"
]

# Simple Conversation States
conversation_states = [
    "asking for a rough outline",
    "comparing different neighborhoods",
    "requesting restaurant recommendations",
    "narrowing down the top 3 must-see spots",
    "finalizing the dates and times",
    "finished conversation"
]

def get_random_prompt_vars():
    # Selecting the random values
    name = random.choice(names)
    days = random.randint(1, 7)
    travellers = random.choice(fellow_travellers)
    interest = random.choice(interests)
    mood = random.choice(moods)
    state = random.choice(conversation_states)

    return {
        "name": name.lower(),
        "days": days,
        "travellers": travellers,
        "interest": interest,
        "mood": mood,
        "state" : state
    }

def should_end_conversation(response_text: str) -> bool:
    """
    Decides whether to end the conversation based on probability.
    Higher probability to return False (continue conversation).
    """
    # 20% chance to end (True), 80% chance to continue (False)
    return random.random() < 0.2