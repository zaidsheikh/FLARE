#!/usr/bin/env -S bash -i

[ $# -lt 2 ] && { echo "Usage: $0 <dataset> <config_file> [openai_compatible_llm_server] [model]"; exit 1; }

debug=true

dataset=$1
config_file=$(readlink -ve $2) || exit 1
llm_server=${3:-"localhost:5000"}
model=${4:-"lmsys/vicuna-7b-v1.3"}

. /opt/conda/etc/profile.d/conda.sh 2>/dev/null
[[ $CONDA_DEFAULT_ENV == "base" ]] || eval $(command conda shell.bash hook)
conda activate flare 2>/dev/null
[[ $CONDA_DEFAULT_ENV == "flare" ]] || source activate flare
[[ $CONDA_DEFAULT_ENV == "flare" ]] || { echo "Couldn't activate conda env flare. Exiting!"; exit 1; }
which python

cd $(dirname $0)

source keys.sh
num_keys=${#keys[@]}

config_filename=$(basename -- "${config_file}")
config_filename="${config_filename%.*}"

debug_batch_size=1
batch_size=1
export OPENAI_API_BASE="http://${llm_server}/v1"

temperature=0

# alpaca_tokenizer="chavinlo/alpaca-native"
# alpaca_tokenizer="./models--chavinlo--alpaca-native/"

output=output/${dataset}/${model}/${config_filename}.jsonl
mkdir -p $(dirname $output)
echo 'output to:' $output

prompt_type=""
if [[ ${dataset} == '2wikihop' ]]; then
    input="--input data/2wikimultihopqa/dev_beir"
    engine=elasticsearch
    index_name=wikipedia_dpr
    fewshot=3
    max_num_examples=500
    max_generation_len=256
elif [[ ${dataset} == 'strategyqa' ]]; then
    input="--input data/strategyqa/dev_beir"
    engine=elasticsearch
    index_name=wikipedia_dpr
    fewshot=2
    max_num_examples=229
    max_generation_len=256
elif [[ ${dataset} == 'asqa' ]]; then
    prompt_type="--prompt_type general_hint_in_output"
    input="--input data/asqa/ASQA.json"
    engine=elasticsearch
    index_name=wikipedia_dpr
    fewshot=2
    max_num_examples=500
    max_generation_len=256
elif [[ ${dataset} == 'asqa_hint' ]]; then
    prompt_type="--prompt_type general_hint_in_input"
    dataset=asqa
    input="--input data/asqa/ASQA.json"
    engine=elasticsearch
    index_name=wikipedia_dpr
    fewshot=2
    max_num_examples=500
    max_generation_len=256
elif [[ ${dataset} == 'wikiasp' ]]; then
    input="--input \"data/wikiasp/matched_with_bing_test.500.annotated\""
    engine=bing
    index_name=wikiasp
    fewshot=2
    max_num_examples=500
    max_generation_len=512
elif [[ ${dataset} == 'xlsum' ]]; then
    input="--input data/xlsum/burmese_test.jsonl"
    engine=elasticsearch
    index_name=xlsum_burmese_doc
    fewshot=0
    max_num_examples=500
    max_generation_len=512
else
    exit
fi

set -x

# query api
if [[ ${debug} == "true" ]]; then
    python -m src.openai_api \
        --model ${model} \
        --dataset ${dataset} ${input} ${prompt_type} \
        --config_file ${config_file} \
        --fewshot ${fewshot} \
        --search_engine ${engine} \
        --index_name ${index_name} \
        --max_num_examples 100 \
        --max_generation_len ${max_generation_len} \
        --batch_size ${debug_batch_size} \
        --output test.jsonl \
        --num_shards 1 \
        --shard_id 0 \
        --openai_keys ${test_key} \
        --debug
    exit
fi

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

joined_keys=$(join_by " " "${keys[@]:0:${num_keys}}")

python -m src.openai_api \
    --model ${model} \
    --dataset ${dataset} ${input} ${prompt_type} \
    --config_file ${config_file} \
    --fewshot ${fewshot} \
    --search_engine ${engine} \
    --index_name ${index_name} \
    --max_num_examples ${max_num_examples} \
    --max_generation_len ${max_generation_len} \
    --temperature ${temperature} \
    --batch_size ${batch_size} \
    --output ${output} \
    --num_shards 1 \
    --shard_id 0 \
    --openai_keys ${joined_keys} \
