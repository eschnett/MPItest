#!/bin/bash

cpuarchs="amd64 arm32v5 arm32v7 arm64v8 i386 mips64le ppc64le riscv64 s390x"
mpivendors="MPICH OpenMPI"

date="$(date)"
for cpuarch in $cpuarchs; do
    for mpivendor in $mpivendors; do
        tag="mpi-test-suite-debian.cpuarch-$cpuarch.mpivendor-$mpivendor"
        rm -f "$tag".*
        {
            docker build --file mpi-test-suite-debian.dockerfile --build-arg cpuarch="$cpuarch" --build-arg mpivendor="$mpivendor" --build-arg date="$date" --progress plain . &&
                : >"$tag.succeeded" ||
                    : >"$tag.failed";
        } 2>&1 |
            tee "$tag.log"
    done
done
