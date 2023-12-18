#!/bin/bash -x

base_dir=$(readlink -ve $(dirname $0)/../)

# change this if needed
elasticsearch_dir=${base_dir}/elasticsearch/

mkdir -p ${base_dir}/data/ ${elasticsearch_dir}/data ${elasticsearch_dir}/config
chmod -R 777 ${base_dir}/data/ ${elasticsearch_dir}/data ${elasticsearch_dir}/config

docker run -it --gpus all \
    -v ${base_dir}/data/:/FLARE/data/ \
    -v ${elasticsearch_dir}/data:/FLARE/elasticsearch-7.17.9/data \
    -v ${elasticsearch_dir}/config/:/FLARE/elasticsearch-7.17.9/config/ \
    zs12/flare:v0.2.5 /bin/bash

# Run these manually once the docker container boots up:
# /FLARE/dockerfiles/start_elasticsearch.sh
# /FLARE/openai.sh 2wikihop /FLARE/configs/2wikihop_flare_config.json vllm_server:5000
