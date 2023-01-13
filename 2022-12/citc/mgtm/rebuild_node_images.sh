#!/bin/bash
set -e
sudo /usr/local/bin/run-packer 2>&1 | tee /tmp/packer-x86_64.log
sudo /usr/local/bin/run-packer aarch64 2>&1 | tee /tmp/packer-aarch64.log
