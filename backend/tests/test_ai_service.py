"""Unit tests for AIService fallback paths (no OpenAI key required)."""
from app.schemas.ai import SummaryRequest, ExplainRequest, AssistantChatRequest
from app.services.ai_service import AIService


def _service_no_openai() -> AIService:
    svc = AIService()
    svc.openai.client = None  # Force fallback path.
    svc._store = None
    return svc


class _NullStore:
    """Drop-in that silently discards history writes."""
    def create(self, *_args, **_kwargs) -> dict:
        return {}


def test_summarize_fallback():
    svc = _service_no_openai()
    svc._store = _NullStore()  # type: ignore[assignment]
    result = svc.summarize("demo", SummaryRequest(subject="Calculus", content="Integration by parts"))
    assert len(result.bullets) > 0
    assert result.title


def test_flashcards_fallback():
    svc = _service_no_openai()
    svc._store = _NullStore()  # type: ignore[assignment]
    result = svc.flashcards(
        "demo",
        SummaryRequest(subject="Biology", content="Mitosis is the process of cell division into two identical daughter cells."),
    )
    assert len(result.flashcards) > 0


def test_quiz_fallback():
    svc = _service_no_openai()
    svc._store = _NullStore()  # type: ignore[assignment]
    result = svc.quiz(
        "demo",
        SummaryRequest(subject="Physics", content="Newton's three laws of motion describe force and acceleration."),
    )
    assert len(result.questions) > 0


def test_chat_fallback():
    svc = _service_no_openai()
    svc._store = _NullStore()  # type: ignore[assignment]
    result = svc.chat(
        "demo",
        AssistantChatRequest(message="How do I prioritize?", subject="General", history=[]),
    )
    assert result.reply
    assert len(result.suggestions) > 0


def test_explain_fallback():
    svc = _service_no_openai()
    svc._store = _NullStore()  # type: ignore[assignment]
    result = svc.explain(
        "demo",
        ExplainRequest(subject="Calculus", concept="Integration by parts", audience_level="intermediate"),
    )
    assert result.explanation
    assert result.memory_tip
