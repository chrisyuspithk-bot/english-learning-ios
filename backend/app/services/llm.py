from openai import OpenAI

from ..config import LLM_API_KEY, LLM_BASE_URL, LLM_MODEL


def get_client() -> OpenAI:
    if not LLM_API_KEY:
        raise ValueError(
            "No LLM API key configured. Set LLM_API_KEY (or OPENAI_API_KEY / DEEPSEEK_API_KEY)."
        )
    return OpenAI(api_key=LLM_API_KEY, base_url=LLM_BASE_URL)


def complete(system: str, user: str, temperature: float = 0.2) -> str:
    client = get_client()
    messages = [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]
    kwargs = dict(model=LLM_MODEL, temperature=temperature, messages=messages)
    try:
        resp = client.chat.completions.create(response_format={"type": "json_object"}, **kwargs)
    except Exception:
        # Some providers/models do not support the json_object response format.
        resp = client.chat.completions.create(**kwargs)
    return resp.choices[0].message.content
