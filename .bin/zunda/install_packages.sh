#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/apt_list"
xargs sudo apt install <"${SCRIPT_DIR}"
