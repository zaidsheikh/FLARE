## Docker images

This repo includes two docker images, one containing the FLARE code, and another containing the [vllm](https://github.com/vllm-project/vllm) server:

```
https://hub.docker.com/r/zs12/flare/tags
https://hub.docker.com/r/zs12/vllm/tags
```

### Build index over the Wikipedia dump using Elasticsearch
```shell
# start docker container
./dockerfiles/start_flare_docker.sh
# run the following command inside the docker container to download the data and build the index
./dockerfiles/build_elasticsearch_db.sh
```
The build index step will take some time but needs to be run only once

### Run the vllm server
```shell
./dockerfiles/start_vllm_docker.sh
```

### Try out FLARE
```shell
# start docker container
./dockerfiles/start_flare_docker.sh
# Run these inside the docker container:
/FLARE/dockerfiles/start_elasticsearch.sh
/FLARE/openai.sh 2wikihop /FLARE/configs/2wikihop_flare_config.json ${vllm_server_ip}:5000
```
