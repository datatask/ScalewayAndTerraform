#!/bin/bash

RELEASE=20230915

go build

docker build -t vhe74/blog-team-builder:${RELEASE} .

docker push vhe74/blog-team-builder:${RELEASE}