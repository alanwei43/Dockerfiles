#!/usr/bin/env bash

# git clone --depth 1 https://github.com/slopus/happy.git && \
curl -o happy.zip "https://codeload.github.com/slopus/happy/zip/refs/heads/main" && \
unzip happy.zip -d ./ && \
mv happy-main/* happy-main/.[!.]* ./ 2>/dev/null && \
mv Dockerfile.server Dockerfile
