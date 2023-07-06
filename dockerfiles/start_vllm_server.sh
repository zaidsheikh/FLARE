#!/bin/bash -x

python -m vllm.entrypoints.openai.api_server \
    --model lmsys/vicuna-7b-v1.3 \
    --tokenizer hf-internal-testing/llama-tokenizer \
    --download-dir /hf_cache/ \
    --host 0.0.0.0 --port 8000

