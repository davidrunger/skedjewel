#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

echo "Target Crystal version: $(cat .crystal-version) ."
target_version=$(cat .crystal-version)
escaped_target_version=$(sed 's/\./\\./g' <<< "$target_version")

echo "Actual Crystal version: $(crystal --version | head -1)"

[[ "$(crystal --version | head -1)" =~ ^Crystal\ ${escaped_target_version}\  ]]
