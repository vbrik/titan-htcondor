#!/bin/bash
set -x
cd "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
condor_submit test-submit