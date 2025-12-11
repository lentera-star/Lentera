import json
from typing import Any, Dict, List

import requests

from app.services.llm import generate_with_ollama


def query_chroma(chroma_url: str, query_text: str, n_results: int = 3) -> List[Dict[str, Any]]:
	"""Query Chroma HTTP API with plain text; returns list of documents (may be empty)."""
	try:
		resp = requests.post(
			f"{chroma_url.rstrip('/')}/api/v1/query",
			json={"query_texts": [query_text], "n_results": n_results},
			timeout=15,
		)
		resp.raise_for_status()
		data = resp.json()
		# data format: {ids, documents, metadatas, distances}
		docs = data.get("documents") or []
		# docs is list of list
		flat = []
		if docs and isinstance(docs, list):
			for group in docs:
				if isinstance(group, list):
					flat.extend(group)
		return flat
	except Exception:
		return []


def build_trivia_prompt(mood_text: str, context_docs: List[str]) -> str:
	context_block = "\n".join(context_docs[:3]) if context_docs else "(no context)"
	prompt = f"""
Anda adalah asisten yang membuat pertanyaan trivia singkat seputar kesehatan mental atau wellbeing.
Gunakan konteks berikut jika relevan:
{context_block}

Mood pengguna / catatan harian:
{mood_text}

Kembalikan jawaban dalam JSON dengan schema:
{{"question": "...", "options": ["A","B","C","D"], "answer_index": 0}}
Pastikan options minimal 3 pilihan.
"""
	return prompt


def generate_trivia(mood_text: str, chroma_url: str | None, ollama_url: str, model: str = "llama3") -> Dict[str, Any]:
	context_docs = query_chroma(chroma_url, mood_text, n_results=3) if chroma_url else []
	prompt = build_trivia_prompt(mood_text, context_docs)
	raw = generate_with_ollama(prompt, model=model, base_url=ollama_url)

	# Try to parse JSON from the model response
	try:
		parsed = json.loads(raw)
		question = parsed.get("question")
		options = parsed.get("options") or []
		answer_index = parsed.get("answer_index", 0)
	except Exception:
		# fallback: build trivial response
		question = "Trivia seputar wellbeing"
		options = [raw[:100] or "Tidak tersedia", "Ya", "Tidak"]
		answer_index = 0

	return {
		"question": question,
		"options": options,
		"answer_index": answer_index,
		"context_used": context_docs,
	}
