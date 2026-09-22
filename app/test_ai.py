import os

from dotenv import load_dotenv
from openai import OpenAI



load_dotenv()

api_key = os.getenv("OPENAI_API_KEY")


if not api_key:
    raise ValueError("OPENAI_API_KEY not found in .env file")


client = OpenAI(api_key=api_key)



response = client.responses.create(
    model="gpt-5.6-luna",
    input="In one sentence, explain what a university information chatbot does."
)



print("\nAI RESPONSE:")
print(response.output_text)