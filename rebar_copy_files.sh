#!/bin/bash

cp -r piqi-erlang/ebin/* ebin && \
mkdir -p include/ && \
cp -r -L piqi-erlang/include/* include && \
rm -rf bin
