#!/bin/bash

export MSYS_NO_PATHCONV=1 

docker run --gpus all \
    -e TORTOISE_MODELS_DIR="/models" \
    -v $HOME/tortoise_tts/models:"/models" \
    -v $HOME/tortoise_tts/results:"/results" \
    -v $HOME/.cache/huggingface:"/root/.cache/huggingface" \
    -v /c:"/work" \
    -it tts