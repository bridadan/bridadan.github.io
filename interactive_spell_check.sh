#!/bin/bash
aspell check $1 --home-dir $(dirname $0)/.github/actions/ci --ignore 3
