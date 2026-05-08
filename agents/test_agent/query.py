import asyncio
import vertexai

PROJECT_ID = "agentic-platform-demo-495009"
LOCATION = "us-central1"

client = vertexai.Client(
    project=PROJECT_ID,
    location=LOCATION,
)

remote_agent = client.agent_engines.get(name="projects/agentic-platform-demo-495009/locations/us-central1/reasoningEngines/4004250374302072832")

# response = remote_agent.query("What is the exchange rate from US dollars to Swedish krona on 2025-04-03?")
# print(response)

async def main():
    try:
        async for event in remote_agent.async_stream_query(
            user_id="ysian",
            message="What is the exchange rate from US dollars to Swedish krona on 2025-04-03?",
        ):
            print(event)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        await client.aio.aclose()

if __name__ == "__main__":
    asyncio.run(main())