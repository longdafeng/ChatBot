from src.common.config import (
    DEFAULT_EMBEDDING_DIMENSIONS,
    DEFAULT_OLLAMA_BASE_URL,
    DEFAULT_OLLAMA_MODEL,
)

from .base import get_embedding
from .local_model import LocalModelEmbedding
from .ollama import create_ollama_embedding
from .openai import create_openai_embedding

# Export all classes and functions
__all__ = [
    "LocalModelEmbedding",
    "create_openai_embedding",
    "create_ollama_embedding",
    "get_embedding"
]
