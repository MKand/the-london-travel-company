import os
import google.oauth2.id_token
from google.auth.transport.requests import Request


def get_bearer_token(audience: str) -> str:
    try:
        request = Request()
        return google.oauth2.id_token.fetch_id_token(request, audience)
    except Exception as e:
        
        return "No token"
