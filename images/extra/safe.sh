#!/bin/bash
set -eu -o pipefail
IFS=$'\n\t'

export JAVA_OPTIONS='-Xms1G -Xmn128M -Xmx4G'
export HADOOP_HEAPSIZE='4096'

# Compute current path and set working dir so maven works
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPTPATH"
