#!/bin/bash -x

llm_server=${1:-"localhost:5000"}

curl http://${llm_server}/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
    "model": "lmsys/vicuna-7b-v1.3",
    "prompt": "San Francisco is a",
    "max_tokens": 7,
    "logprobs": 0,
    "echo": false,
    "temperature": 1,
    "frequency_penalty": 1,
    "logit_bias": null,
    "top_p": 1
}' | python -m json.tool | less
