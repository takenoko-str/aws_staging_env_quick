#!/bin/bash

# 正しく上書きされない事があるので一旦消す
# Gitにコミットもしない
rm -f docker-compose.override.yml

# デプロイ済コンテナ定義から作成
aws ecs describe-task-definition \
    --task-definition "$1" \
    | jq -r ".taskDefinition" \
    > task_definition.json

ecs-cli local create \
    --task-def-file task_definition.json \
    --output docker-compose.yml