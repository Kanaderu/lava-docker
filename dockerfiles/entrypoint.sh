#!/bin/bash
set -e

source ${VENV_PATH}/bin/activate

exec "$@"
