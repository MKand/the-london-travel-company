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


MOODS = [
    {
        "name": "happy",
        "description": "Enthusiastic, friendly, uses exclamation marks, expresses excitement about traveling",
        "examples": ["This is going to be amazing!", "I can't wait to explore!", "So excited!"],
    },
    {
        "name": "impatient",
        "description": "In a hurry, wants quick answers, short sentences, slightly frustrated",
        "examples": ["Just give me the info.", "Need this fast.", "Quick question."],
    },
    {
        "name": "frustrated",
        "description": "Having trouble, confused, needs help, may express annoyance",
        "examples": ["I've been looking everywhere.", "This is confusing.", "Can someone help me?"],
    },
    {
        "name": "curious",
        "description": "Asks many questions, wants details, explores options",
        "examples": ["What about...?", "I'm wondering...", "Tell me more about..."],
    },
    {
        "name": "polite",
        "description": "Very formal, uses please and thank you, respectful",
        "examples": ["Would you kindly...", "I would appreciate...", "Thank you so much!"],
    },
    {
        "name": "direct",
        "description": "To the point, minimal words, efficient communication",
        "examples": ["Show me the itinerary.", "London attractions.", "3 days, family."],
    },
    {
        "name": "anxious",
        "description": "Worried, needs reassurance, concerned about details",
        "examples": ["Will this work?", "Is it safe?", "What if something goes wrong?"],
    },
    {
        "name": "laid_back",
        "description": "Casual, relaxed, flexible, no rush",
        "examples": ["Whatever works.", "No pressure.", "Just show me what's good."],
    },
    {
        "name": "businesslike",
        "description": "Professional, concise, focused on outcomes",
        "examples": ["I need a detailed itinerary for a business trip.", "Time-sensitive request.", "Efficiency is key."],
    },
    {
        "name": "romantic",
        "description": "Looking for romantic experiences, couples activities, intimate settings",
        "examples": ["Looking for something romantic.", "Perfect for two?", "Couples activities."],
    },
]


REQUEST_TEMPLATES = [
    {
        "type": "basic_itinerary",
        "templates": [
            "I want to visit London for {days} days, what can I do?",
            "Plan a {days}-day trip to London",
            "What's a good London itinerary for {days} days?",
            "London trip - {days} days - what to see?",
        ],
    },
    {
        "type": "family_friendly",
        "templates": [
            "Family trip to London - {days} days with kids, what activities?",
            "Taking my kids to London, need child-friendly attractions",
            "Best things to do in London with a 6-year-old?",
            "Family-friendly itinerary for {days} days in London",
        ],
    },
    {
        "type": "specific_interest",
        "templates": [
            "I love museums - what do you recommend in London?",
            "Looking for historical sites in London",
            "Best parks and gardens in London?",
            "London food scene - where to eat?",
            "Art galleries in London - recommendations?",
            "Shopping in London - best areas?",
        ],
    },
    {
        "type": "budget",
        "templates": [
            "Budget trip to London - free activities?",
            "Cheap things to do in London?",
            "London on a budget - help me plan",
            "Free attractions in London?",
        ],
    },
    {
        "type": "luxury",
        "templates": [
            "Luxury London experience - premium attractions?",
            "High-end things to do in London",
            "Exclusive experiences in London?",
            "Best fine dining in London?",
        ],
    },
    {
        "type": "specific_attraction",
        "templates": [
            "Tell me about the British Museum",
            "What's at Tower of London?",
            "Is Buckingham Palace worth visiting?",
            "London Eye - worth it?",
            "What can I do at Hyde Park?",
        ],
    },
    {
        "type": "detailed_request",
        "templates": [
            "Planning a {days}-day trip to London with my partner, we love history and good food. Budget is moderate. Can you create an itinerary?",
            "First time in London, solo traveler, interested in photography and local culture. {days} days. Help!",
            "Business trip to London, have 2 free evenings. What can I do?",
            "Anniversary trip - romantic things to do in London for 2 days?",
        ],
    },
    {
        "type": "follow_up",
        "templates": [
            "What about transport between these places?",
            "Can you add more museum visits?",
            "Are these places kid-friendly?",
            "What's the best time to visit?",
            "How much should I budget for these?",
        ],
    },
    {
        "type": "problem_solving",
        "templates": [
            "It rained all day - what indoor activities in London?",
            "One day in London with a toddler - help!",
            "Have 6 hours in London - what can I see?",
            "Traveling with elderly - accessible attractions?",
        ],
    },
    {
        "type": "complex_multi_day",
        "templates": [
            "Plan a week in London - mix of tourist spots and hidden gems",
            "Two weeks in London and surrounding areas - day trips?",
            "London for 5 days - include both classic and unique experiences",
        ],
    },
]


def get_random_mood() -> Dict[str, str]:
    return random.choice(MOODS)


def get_random_request() -> str:
    request_type = random.choice(REQUEST_TEMPLATES)
    template = random.choice(request_type["templates"])
    
    days = random.choice([1, 2, 3, 4, 5, 7])
    template = template.replace("{days}", str(days))
    
    return template


def get_mood_prefix(mood: Dict[str, str]) -> str:
    if mood["name"] == "happy":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "impatient":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "frustrated":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "curious":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "polite":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "direct":
        return ""
    elif mood["name"] == "anxious":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "laid_back":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "businesslike":
        return random.choice(mood["examples"]) + " "
    elif mood["name"] == "romantic":
        return random.choice(mood["examples"]) + " "
    return ""


def generate_test_request() -> str:
    mood = get_random_mood()
    request = get_random_request()
    prefix = get_mood_prefix(mood)
    return prefix + request


def generate_conversation_starter() -> str:
    return generate_test_request()


def generate_follow_up(previous_context: str = "") -> str:
    follow_up_type = random.choice(REQUEST_TEMPLATES)
    if follow_up_type["type"] == "follow_up":
        template = random.choice(follow_up_type["templates"])
    else:
        template = random.choice(REQUEST_TEMPLATES[7]["templates"])
    return template
