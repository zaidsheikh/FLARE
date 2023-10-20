FROM nvcr.io/nvidia/pytorch:22.12-py3
RUN pip uninstall torch -y
ENV CUDA_HOME=/usr/local/cuda-11.8/
RUN pip install git+https://github.com/vllm-project/vllm
RUN pip uninstall -y transformer-engine
RUN pip install --upgrade pydantic
