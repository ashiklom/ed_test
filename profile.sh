#!/bin/bash
ulimit -s unlimited
EXE=/usr/local/bin/ed2.develop
OMP_NUM_THREADS=1 ${EXE} -s -f /data/input/ED2IN
gprof ${EXE}
