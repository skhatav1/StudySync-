from app.models.domain import CollectionNames
from app.schemas.ai import (
    AssistantChatRequest,
    AssistantChatResponse,
    ExplainRequest,
    ExplainResponse,
    FlashcardsResponse,
    QuizResponse,
    SummaryRequest,
    SummaryResponse,
)
from app.services.firestore_service import FirestoreService
from app.services.openai_service import OpenAIService


class AIService:
    def __init__(self) -> None:
        self.openai = OpenAIService()
        self._store: FirestoreService | None = None

    @property
    def store(self) -> FirestoreService:
        if self._store is None:
            self._store = FirestoreService()
        return self._store

    def summarize(self, uid: str, request: SummaryRequest) -> SummaryResponse:
        if self.openai.client:
            system_prompt = OpenAIService.to_json_prompt(
                SummaryResponse,
                "Summarize the study material for a student. Keep it concise, factual, and exam useful.",
            )
            summary = self.openai.generate_structured(
                system_prompt=system_prompt,
                user_prompt=request.model_dump_json(indent=2),
                schema=SummaryResponse,
            )
        else:
            summary = SummaryResponse(
                title=f"{request.subject} summary",
                bullets=["Review the core definitions.", "Practice one worked example.", "Check common mistakes."],
                key_takeaways=["Focus on the highest-yield concepts first."],
            )
        self._store_history(uid, "summary", summary.model_dump())
        return summary

    def flashcards(self, uid: str, request: SummaryRequest) -> FlashcardsResponse:
        if self.openai.client:
            system_prompt = OpenAIService.to_json_prompt(
                FlashcardsResponse,
                "Create useful study flashcards from the material. Use clear question and answer pairs.",
            )
            response = self.openai.generate_structured(
                system_prompt=system_prompt,
                user_prompt=request.model_dump_json(indent=2),
                schema=FlashcardsResponse,
            )
        else:
            response = FlashcardsResponse(
                title=f"{request.subject} flashcards",
                flashcards=[
                    {"question": "What is the main concept?", "answer": "A concise explanation of the main concept."},
                    {"question": "What is a common mistake?", "answer": "A likely misunderstanding to avoid."},
                ],
            )
        self._store_history(uid, "flashcards", response.model_dump())
        return response

    def quiz(self, uid: str, request: SummaryRequest) -> QuizResponse:
        if self.openai.client:
            system_prompt = OpenAIService.to_json_prompt(
                QuizResponse,
                "Create a short quiz from the study material. Use exam-style questions and clean explanations.",
            )
            response = self.openai.generate_structured(
                system_prompt=system_prompt,
                user_prompt=request.model_dump_json(indent=2),
                schema=QuizResponse,
            )
        else:
            response = QuizResponse(
                title=f"{request.subject} quiz",
                questions=[
                    {
                        "question": "What is the highest-yield idea from these notes?",
                        "type": "mcq",
                        "options": ["A", "B", "C", "D"],
                        "answer": "A",
                        "explanation": "This is the central concept in the material.",
                    }
                ],
            )
        self._store_history(uid, "quiz", response.model_dump())
        return response

    def explain(self, uid: str, request: ExplainRequest) -> ExplainResponse:
        if self.openai.client:
            system_prompt = OpenAIService.to_json_prompt(
                ExplainResponse,
                "Explain the concept simply. Include a practical example and one memory tip.",
            )
            response = self.openai.generate_structured(
                system_prompt=system_prompt,
                user_prompt=request.model_dump_json(indent=2),
                schema=ExplainResponse,
            )
        else:
            response = ExplainResponse(
                explanation=f"{request.concept} explained in a {request.audience_level}-friendly way.",
                practical_example="Connect the idea to one real exam scenario.",
                memory_tip="Use a short analogy and review it after one day.",
            )
        self._store_history(uid, "explain", response.model_dump())
        return response

    def chat(self, uid: str, request: AssistantChatRequest) -> AssistantChatResponse:
        if self.openai.client:
            system_prompt = (
                "You are StudySync AI, a high-quality study coach. Give concise, practical help. "
                "Return plain text only."
            )
            history_text = "\n".join(f"{item.role}: {item.content}" for item in request.history)
            reply = self.openai.generate_text(
                system_prompt=system_prompt,
                user_prompt=f"Subject: {request.subject}\nHistory:\n{history_text}\nUser: {request.message}",
            )
            response = AssistantChatResponse(
                reply=reply.strip(),
                suggestions=["Generate a quiz", "Create flashcards", "Rebuild my plan"],
            )
        else:
            response = AssistantChatResponse(
                reply="Start with the most urgent weak-area topic, then finish with a 10-minute self-test.",
                suggestions=["Explain simply", "Make a quiz", "Summarize my notes"],
            )
        self._store_history(uid, "assistant_chat", {"request": request.model_dump(), "response": response.model_dump()})
        return response

    def _store_history(self, uid: str, item_type: str, output: dict) -> None:
        self.store.create(CollectionNames.assistant_history, {"user_id": uid, "type": item_type, "output": output})
