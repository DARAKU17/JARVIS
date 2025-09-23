import sys
from TTS.api import TTS
import os
import time
from datetime import datetime
from playsound import playsound

# -------------------------------
# Configuration
# -------------------------------
MODEL_PATH = "/models/xtts_v2"
MODEL_SPEAKER = "Tanja Adelina"   # Your recorded voice sample
MODEL_NAME = "FRIDAY"
DEFAULT_LANGUAGE = "en"

# Load TTS model
tts = TTS(MODEL_PATH, progress_bar=True, gpu=False)
LANGUAGE = DEFAULT_LANGUAGE

# -------------------------------
# Functions
# -------------------------------
def model_speak(text):
    """Generate TTS using reference voice and play audio."""
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{MODEL_NAME}_{timestamp}.wav"

        tts.tts_to_file(
            text=text,
            file_path=f"./history/{filename}",
            language=LANGUAGE,
            speaker_id=MODEL_SPEAKER  # reference sample
        )

        print(f"{MODEL_NAME} ({LANGUAGE}): {text} | Saved as {filename}")
        play_audio(f"./history/{filename}")

    except Exception as e:
        print(f"[Error] Could not generate TTS: {e}")

def play_audio(file_path):
    """Play audio directly in Python using playsound."""
    try:
        playsound(file_path)
    except Exception as e:
        print(f"[Error] Could not play audio: {e}")

def initialize_system():
    """Simulate system initialization and greet user."""
    print("Initializing system...")
    model_speak("Initializing system...")
    time.sleep(3)
    print("System initialized!")
    model_speak("System initialized!")
    model_speak("Hello Astro! Friday is online and ready to assist you.")

def choose_language():
    """Prompt user to select a language."""
    global LANGUAGE
    try:
        lang_input = input("Select language for Jarvis (e.g., en, fr, es, de) [default: en]: ").strip()
        if lang_input:
            LANGUAGE = lang_input
        print(f"Language set to: {LANGUAGE}")
    except Exception as e:
        print(f"[Error] Could not set language: {e}")

# -------------------------------
# Main Program
# -------------------------------
if __name__ == "__main__":
    choose_language()
    initialize_system()

    # Interactive chat loop
    while True:
        try:
            user_input = input("You: ").strip()

            if user_input.lower() in ["quit", "exit", "bye"]:
                model_speak("Goodbye, Astro! Shutting down.")
                break
            # Change language on-the-fly
            elif user_input.startswith("/lang "):
                new_lang = user_input.split(" ", 1)[1].strip()
                if new_lang:
                    LANGUAGE = new_lang
                    print(f"Language switched to: {LANGUAGE}")
                    model_speak(f"Language switched to {LANGUAGE}.")
                continue
            else:
                model_speak(user_input)

        except Exception as e:
            print(f"[Error] Something went wrong: {e}")
