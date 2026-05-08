import os
import google.oauth2.id_token
from google.auth.transport.requests import Request
import logging

logger = logging.getLogger(__name__)

def get_bearer_token(audience: str) -> str:
    try:
        request = Request()
        token = google.oauth2.id_token.fetch_id_token(request, audience)
        logger.info(f"Token: {token}")
        return token
    except Exception as e:
        logger.error(f"Error fetching token: {e}")
        return "No token"
