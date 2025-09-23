from TTS.api import TTS 
tts = TTS(model_name="/models/xtts_v2", gpu=False)

print("Model Loaded")
print(tts.speakers)