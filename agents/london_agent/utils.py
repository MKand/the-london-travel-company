from google.adk.tools import ToolContext

def write_to_tool_context(key, value, tool_context: ToolContext = None):
    if tool_context is not None:
        tool_context.state[key] = value