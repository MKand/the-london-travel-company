
import sys
import os
from google.adk.agents import Agent

def check_agent():
    print("Checking google.adk.agents.Agent...")
    a = Agent(model='gemini-2.0-flash', instruction='test', name='test')
    methods = ['query', 'stream_query', 'async_stream_query', 'register_operations']
    for m in methods:
        print(f"{m}: {hasattr(a, m)}")
    
    print("\nAll public methods/attributes:")
    print([m for m in dir(a) if not m.startswith('_')])

if __name__ == "__main__":
    check_agent()
