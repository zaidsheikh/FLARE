#!/bin/bash -x

cd /FLARE/elasticsearch-7.17.9/
nohup su elasticsearch -c bin/elasticsearch &

sleep 30

# elasticsearch disable disk usage threshold
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_cluster/settings -d '{ "transient": { "cluster.routing.allocation.disk.threshold_enabled": false } }'

mkdir -p /FLARE/data/dpr/
wget -O /FLARE/data/dpr/psgs_w100.tsv.gz https://dl.fbaipublicfiles.com/dpr/wikipedia_split/psgs_w100.tsv.gz
gunzip /FLARE/data/dpr/psgs_w100.tsv.gz

# build index
cd /FLARE/

. /opt/conda/etc/profile.d/conda.sh
[[ $CONDA_DEFAULT_ENV == "base" ]] || eval $(command conda shell.bash hook)
conda activate flare 2>/dev/null
[[ $CONDA_DEFAULT_ENV == "flare" ]] || source activate flare
[[ $CONDA_DEFAULT_ENV == "flare" ]] || { echo "Couldn't activate conda env flare. Exiting!"; exit 1; }

python prep.py --task build_elasticsearch --inp data/dpr/psgs_w100.tsv wikipedia_dpr
