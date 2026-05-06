from typing import Literal

from pydantic import BaseModel, Field


class SummaryRequest(BaseModel):
    resource_id: str | None = None
    subject: str
    content: str = Field(min_length=20)


class SummaryResponse(BaseModel):
    title: str
    bullets: list[str]
    key_takeaways: list[str]


class FlashcardItem(BaseModel):
    question: str
    answer: str


class FlashcardsResponse(BaseModel):
    title: str
    flashcards: list[FlashcardItem]


class QuizQuestion(BaseModel):
    question: str
    type: Literal["mcq", "short_answer"]
    options: list[str] = Field(default_factory=list)
    answer: str
    explanation: str


class QuizResponse(BaseModel):
    title: str
    questions: list[QuizQuestion]


class ExplainRequest(BaseModel):
    subject: str
    concept: str
    audience_level: Literal["beginner", "intermediate", "advanced"] = "beginner"


class ExplainResponse(BaseModel):
    explanation: str
    practical_example: str
    memory_tip: str


class ChatMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class AssistantChatRequest(BaseModel):
    subject: str | None = None
    message: str
    history: list[ChatMessage] = Field(default_factory=list)


class AssistantChatResponse(BaseModel):
    reply: str
    suggestions: list[str] = Field(default_factory=list)
