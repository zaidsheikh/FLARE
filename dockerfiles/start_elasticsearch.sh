#!/bin/bash -x

cd /FLARE/elasticsearch-7.17.9/
nohup su elasticsearch -c bin/elasticsearch &
sleep 10
curl --fail -XGET localhost:9200/_cat/indices/wikipedia_dpr || echo "wikipedia_dpr index not found, please run ./build_elasticsearch_db.sh first!"
