import os
import subprocess

# --- STEP 1: Ensure deps are installed ---
deps = [
    "torch", "transformers", "accelerate", "datasets",
    "bitsandbytes", "peft", "sentencepiece"
]
subprocess.run(["pip", "install", "--quiet"] + deps)

# --- STEP 2: Imports ---
from datasets import Dataset
from transformers import (
    AutoModelForCausalLM, AutoTokenizer,
    TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType

# --- STEP 3: Load Phi-2 ---
model_name = "microsoft/phi-2"
tokenizer = AutoTokenizer.from_pretrained(model_name)

model = AutoModelForCausalLM.from_pretrained(
    model_name,
    device_map="auto",
    load_in_4bit=True,   # saves RAM/VRAM
    trust_remote_code=True
)

# --- STEP 4: Create toy dataset ---
data = {
    "text": [
        "Q: What is 2+2? A: 4",
        "Q: Who wrote Hamlet? A: Shakespeare",
        "Q: Capital of Japan? A: Tokyo"
    ]
}
dataset = Dataset.from_dict(data)

# --- STEP 5: Apply LoRA ---
lora_config = LoraConfig(
    r=8,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    task_type=TaskType.CAUSAL_LM,
)
model = get_peft_model(model, lora_config)

# --- STEP 6: Tokenize ---
tokenized = dataset.map(
    lambda x: tokenizer(
        x["text"],
        truncation=True,
        padding="max_length",
        max_length=128
    )
)

# --- STEP 7: Training ---
training_args = TrainingArguments(
    output_dir="./phi2-finetuned",
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,
    num_train_epochs=2,
    learning_rate=2e-4,
    fp16=True,
    save_strategy="epoch",
    logging_dir="./logs",
    logging_steps=5,
    report_to="none"
)

collator = DataCollatorForLanguageModeling(tokenizer, mlm=False)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized,
    data_collator=collator,
)

trainer.train()

# --- STEP 8: Save LoRA weights ---
model.save_pretrained("./phi2-lora")
print("✅ Training complete. LoRA weights saved in ./phi2-lora")
