#!/bin/bash
ulimit -s unlimited
OMP_NUM_THREADS=1 ed2.develop -s -f /data/input/ED2IN
