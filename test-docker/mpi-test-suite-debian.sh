#!/bin/bash

date="$(date)"
for cpuarch in amd64 arm32v5 arm32v7 arm64v8 i386 mips64le ppc64le riscv64; do
    for mpivendor in MPICH OpenMPI; do
        tag=mpi-test-suite-debian.cpuarch-$cpuarch.mpivendor-$mpivendor
        {
            rm -f $tag.*
            docker build --file mpi-test-suite-debian.dockerfile --build-arg cpuarch=$cpuarch --build-arg mpivendor=$mpivendor --progress plain . &&
                : >$tag.succeeded ||
                    : >$tag.failed
        } 2>&1 |
            tee $tag.log
    done
done
