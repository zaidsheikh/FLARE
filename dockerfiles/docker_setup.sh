#!/usr/env/bin bash

eval "$(conda shell.bash hook)"
conda create -n flare python=3.10.4
conda activate flare
conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=11.3 -c pytorch
pip install -r pip_freeze.txt
python -m spacy download en_core_web_sm

# elasticsearch disable disk usage threshold
#curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_cluster/settings -d '{ "transient": { "cluster.routing.allocation.disk.threshold_enabled": false } }'
