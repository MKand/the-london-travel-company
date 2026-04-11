import os
import logging
from typing import Optional

from google.adk.agents.callback_context import CallbackContext
from google.adk.models.llm_request import LlmRequest
from google.adk.models.llm_response import LlmResponse
from google.genai import types
from london_agent.config import configs
from google.cloud import modelarmor_v1

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ModelArmorGuard:
    def __init__(self, template_name: str, location: str = "us-central1", block_on_match: bool = True):
        self.template_name = template_name
        self.location = location
        self.block_on_match = block_on_match
        self._client = None

    @property
    def client(self):
        if self._client is None:
            from google.cloud import modelarmor_v1
            from google.api_core.client_options import ClientOptions
            self._client = modelarmor_v1.ModelArmorClient(
                transport="rest",
                client_options=ClientOptions(api_endpoint=f"modelarmor.{self.location}.rep.googleapis.com"),
            )
        return self._client

    def _get_matched_filters(self, result) -> list[str]:
        matched_filters = []
        if result is None:
            return matched_filters
        try:
            filter_results = dict(result.sanitization_result.filter_results)
        except (AttributeError, TypeError):
            return matched_filters
        filter_attr_mapping = {
            'csam': 'csam_filter_filter_result',
            'malicious_uris': 'malicious_uri_filter_result',
            'pi_and_jailbreak': 'pi_and_jailbreak_filter_result',
            'rai': 'rai_filter_result',
            'sdp': 'sdp_filter_result',
            'virus_scan': 'virus_scan_filter_result'
        }
        for filter_name, filter_obj in filter_results.items():
            attr_name = filter_attr_mapping.get(filter_name, f'{filter_name}_filter_result')
            if hasattr(filter_obj, attr_name):
                filter_result = getattr(filter_obj, attr_name)
                if filter_name == 'sdp' and hasattr(filter_result, 'inspect_result'):
                    if getattr(filter_result.inspect_result, 'match_state', None) and filter_result.inspect_result.match_state.name == 'MATCH_FOUND':
                        matched_filters.append('sdp')
                elif filter_name == 'rai':
                    if hasattr(filter_result, 'match_state') and filter_result.match_state.name == 'MATCH_FOUND':
                        matched_filters.append('rai')
                    if hasattr(filter_result, 'rai_filter_type_results'):
                        for sub_result in filter_result.rai_filter_type_results:
                            if hasattr(sub_result, 'value') and hasattr(sub_result.value, 'match_state') and sub_result.value.match_state.name == 'MATCH_FOUND':
                                matched_filters.append(f'rai:{sub_result.key}')
                else:
                    if hasattr(filter_result, 'match_state') and filter_result.match_state.name == 'MATCH_FOUND':
                        matched_filters.append(filter_name)
        return matched_filters

    def _extract_user_text(self, llm_request: LlmRequest) -> str:
        try:
            if llm_request.contents:
                for content in reversed(llm_request.contents):
                    if content.role == "user":
                        for part in content.parts:
                            if hasattr(part, 'text') and part.text:
                                return part.text
        except Exception:
            pass
        return ""

    def _extract_model_text(self, llm_response: LlmResponse) -> str:
        try:
            if llm_response.content and llm_response.content.parts:
                for part in llm_response.content.parts:
                    if hasattr(part, 'text') and part.text:
                        return part.text
        except Exception:
            pass
        return ""

    async def before_model_callback(self, callback_context: CallbackContext, llm_request: LlmRequest) -> Optional[LlmResponse]:
        user_text = self._extract_user_text(llm_request)
        if not user_text:
            return None
        try:
            user_prompt_data = modelarmor_v1.DataItem(text=user_text)
            sanitize_request = modelarmor_v1.SanitizeUserPromptRequest(
                name=self.template_name,
                user_prompt_data=user_prompt_data,
            )
            result = self.client.sanitize_user_prompt(request=sanitize_request)
            matched_filters = self._get_matched_filters(result)
            if matched_filters and self.block_on_match:
                if 'pi_and_jailbreak' in matched_filters:
                    message = "I apologize, but I cannot process this request. Your message appears to contain instructions that could compromise my safety guidelines. Please rephrase your question."
                elif 'sdp' in matched_filters:
                    message = "I noticed your message contains sensitive personal information (like SSN or credit card numbers). For your security, I cannot process requests containing such data."
                elif any(f.startswith('rai') for f in matched_filters):
                    message = "I apologize, but I cannot respond to this type of request. Please rephrase your question in a respectful manner."
                else:
                    message = "I apologize, but I cannot process this request due to security concerns. Please rephrase your question."
                return LlmResponse(content=types.Content(role="model", parts=[types.Part.from_text(text=message)]))
        except Exception as e:
            logger.warning(f"Pre-ModelArmor check failed, allowing through: {e}")
        return None

    async def after_model_callback(self, callback_context: CallbackContext, llm_response: LlmResponse) -> Optional[LlmResponse]:
        model_text = self._extract_model_text(llm_response)
        if not model_text:
            return None
        try:
            sanitize_request = modelarmor_v1.SanitizeModelResponseRequest(
                name=self.template_name,
                model_response_data=modelarmor_v1.DataItem(text=model_text),
            )
            result = self.client.sanitize_model_response(request=sanitize_request)
            matched_filters = self._get_matched_filters(result)
            if matched_filters and self.block_on_match:
                message = "I apologize, but my response was filtered for security reasons. Could you please rephrase your question?"
                return LlmResponse(content=types.Content(role="model", parts=[types.Part.from_text(text=message)]))
        except Exception as e:
            logger.warning(f"Post-ModelArmor check failed, allowing through: {e}")
        return None


def create_model_armor_guard() -> ModelArmorGuard:
    template_name = f"projects/{configs.project_id}/locations/{configs.location}/templates/{configs.model_armor_template_name}"
    logger.info(f"Model Armor Location: {configs.location}, Template Name: {template_name}")
    if not template_name:
        raise ValueError("TEMPLATE_NAME not set. Create a Model Armor template first.")
    return ModelArmorGuard(template_name=template_name, location=configs.location, block_on_match=True)