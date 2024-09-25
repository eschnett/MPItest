#!/bin/bash

# cpuarchs="amd64 arm32v5 arm32v7 arm64v8 i386 mips64le ppc64le riscv64 s390x"
cpuarchs="amd64"
distributions="debian ubuntu"
mpivendors="MPICH OpenMPI"

# date="$(date)"
date=date
for cpuarch in $cpuarchs; do
    for distribution in $distributions; do
        for mpivendor in $mpivendors; do
            tag="mpi-test-suite-$distribution-$cpuarch-$mpivendor"
            rm -f "$tag".*
            {
                docker build \
                       --file mpi-test-suite-$distribution.dockerfile \
                       --build-arg cpuarch="$cpuarch" \
                       --build-arg mpivendor="$mpivendor" \
                       --build-arg date="$date" \
                       --progress plain \
                       . \
                    &&
                    : >"$tag.succeeded" ||
                        : >"$tag.failed";
            } 2>&1 |
                tee "$tag.log"
        done
    done
done
