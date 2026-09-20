import os

from dotenv import load_dotenv
from openai import OpenAI


# .env file se API key load kar rahe hain
load_dotenv()

api_key = os.getenv("OPENAI_API_KEY")

# Agar API key nahi mili to clear error show hoga
if not api_key:
    raise ValueError("OPENAI_API_KEY not found in .env file")


# OpenAI client create kar rahe hain
client = OpenAI(api_key=api_key)


# AI ko first test question bhej rahe hain
response = client.responses.create(
    model="gpt-5.6-luna",
    input="In one sentence, explain what a university information chatbot does."
)


# AI ka generated answer print kar rahe hain
print("\nAI RESPONSE:")
print(response.output_text)