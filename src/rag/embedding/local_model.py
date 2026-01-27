"""Local model embedding using sentence-transformers."""
from typing import List

from langchain_core.embeddings import Embeddings
from sentence_transformers import SentenceTransformer

from src.common.logger import get_logger

logger = get_logger(__name__)


class LocalModelEmbedding(Embeddings):
    """
    Embedding class for local models using sentence-transformers.
    
    Supports any HuggingFace model compatible with sentence-transformers.
    """

    def __init__(
        self,
        model_name: str = "BAAI/bge-m3",
        cache_folder: str = None,
        device: str = "cpu",
    ):
        """
        Initialize local model embedding.

        Args:
            model_name: HuggingFace model name or path
            cache_folder: Local cache folder for model files
            device: Device to use ('cpu' or 'cuda')
        """
        logger.info(f"Initializing LocalModelEmbedding with model: {model_name}")
        
        self.model_name = model_name
        self.cache_folder = cache_folder
        self.device = device
        
        # Load model
        try:
            self.model = SentenceTransformer(
                model_name,
                cache_folder=cache_folder,
                device=device,
            )
            logger.info(f"Successfully loaded model: {model_name}")
        except Exception as e:
            logger.error(f"Failed to load model {model_name}: {e}")
            raise

    def embed_documents(self, texts: List[str]) -> List[List[float]]:
        """
        Embed a list of documents.

        Args:
            texts: List of texts to embed

        Returns:
            List of embeddings
        """
        logger.debug(f"Embedding {len(texts)} documents")
        embeddings = self.model.encode(
            texts,
            normalize_embeddings=True,
            show_progress_bar=False,
        )
        return embeddings.tolist()

    def embed_query(self, text: str) -> List[float]:
        """
        Embed a single query.

        Args:
            text: Query text to embed

        Returns:
            Embedding vector
        """
        logger.debug(f"Embedding query: {text[:50]}...")
        embedding = self.model.encode(
            text,
            normalize_embeddings=True,
            show_progress_bar=False,
        )
        return embedding.tolist()
