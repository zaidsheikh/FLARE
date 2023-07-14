#!/bin/bash -x

cd /FLARE/elasticsearch-7.17.9/
nohup su elasticsearch -c bin/elasticsearch &

# elasticsearch disable disk usage threshold
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_cluster/settings -d '{ "transient": { "cluster.routing.allocation.disk.threshold_enabled": false } }'

mkdir -p /FLARE/data/dpr/
wget -O /FLARE/data/dpr/psgs_w100.tsv.gz https://dl.fbaipublicfiles.com/dpr/wikipedia_split/psgs_w100.tsv.gz
gunzip /FLARE/data/dpr/psgs_w100.tsv.gz

# build index
python prep.py --task build_elasticsearch --inp data/dpr/psgs_w100.tsv wikipedia_dpr
