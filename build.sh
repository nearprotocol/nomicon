#!/bin/bash
set -e

mdbook build
git checkout -- docs/CNAME
