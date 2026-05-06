import json
from typing import TypeVar

from openai import OpenAI
from pydantic import BaseModel

from app.core.config import get_settings
from app.utils.json_tools import extract_json


SchemaT = TypeVar("SchemaT", bound=BaseModel)


class OpenAIService:
    def __init__(self) -> None:
        settings = get_settings()
        self.model = settings.openai_model
        self.client = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None

    def ensure_client(self) -> OpenAI:
        if not self.client:
            raise ValueError("OPENAI_API_KEY is not configured.")
        return self.client

    def generate_structured(self, *, system_prompt: str, user_prompt: str, schema: type[SchemaT]) -> SchemaT:
        client = self.ensure_client()
        response = client.responses.create(
            model=self.model,
            input=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        )
        raw = response.output_text
        parsed = extract_json(raw)
        if isinstance(parsed, list):
            parsed = {"items": parsed}
        return schema.model_validate(parsed)

    def generate_text(self, *, system_prompt: str, user_prompt: str) -> str:
        client = self.ensure_client()
        response = client.responses.create(
            model=self.model,
            input=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        )
        return response.output_text

    @staticmethod
    def to_json_prompt(schema: type[BaseModel], task: str) -> str:
        example = json.dumps(schema.model_json_schema(), indent=2)
        return (
            f"{task}\n"
            "Return only valid JSON matching this schema. Do not include markdown fences.\n"
            f"{example}"
        )
