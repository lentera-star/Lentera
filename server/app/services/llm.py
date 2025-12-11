import requests


def generate_with_ollama(prompt: str, model: str, base_url: str) -> str:
	"""Call Ollama /api/generate and return the generated text."""
	payload = {"model": model, "prompt": prompt, "stream": False}
	resp = requests.post(f"{base_url.rstrip('/')}/api/generate", json=payload, timeout=60)
	resp.raise_for_status()
	data = resp.json()
	return data.get("response", "")
