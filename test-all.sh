#!/bin/sh
set -e

busted ./test/unit-test.lua
sh ./test/integration-test.sh
