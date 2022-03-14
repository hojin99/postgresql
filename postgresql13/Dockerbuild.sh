#!/bin/sh

# 변수선언
_image_name="pg13" 

echo _image_name = "${_image_name}"

# docker build
docker build --network=host -t "${_image_name}" .

# 사용하지 않는 이미지 정리
docker image prune -f