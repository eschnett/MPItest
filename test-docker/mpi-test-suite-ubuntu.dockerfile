# This Dockerfile is for debugging the CI setup
# Run `docker build --file mpi-test-suite-debian.dockerfile --build-arg cpuarch=amd64 --build-arg mpivendor=MPICH --progress plain .`

ARG cpuarch=amd64 # amd64, arm32v5, arm32v7, arm64v8, i386, mips64le, ppc64le, riscv64

FROM ${cpuarch}/ubuntu:23.10
# MPICH is broken on Ubuntu 24.04; see
# <https://github.com/pmodels/mpich/issues/7064>. Older Ubuntus work,
# and Debian works as well.
# FROM ${cpuarch}/ubuntu:24.04

ARG mpivendor=MPICH             # MPICH, OpenMPI

RUN mkdir /cactus
WORKDIR /cactus

# Install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get --yes --no-install-recommends install \
        autoconf \
        automake \
        ca-certificates \
        cmake \
        gcc \
        g++ \
        gdb \
        gengetopt \
        gfortran \
        git \
        make \
        python3 \
        wget

# Install system MPI
RUN case $mpivendor in \
        MPICH) pkgs=libmpich-dev;; \
        OpenMPI) pkgs=libopenmpi-dev;; \
        *) exit 1;; \
    esac && \
    apt-get --yes --no-install-recommends install ${pkgs}

# Add a dependency to force a rebuild
ARG date=0
RUN : $date

# Install MPIwrapper
RUN git clone -n https://github.com/eschnett/MPIwrapper && cd MPIwrapper && git checkout 3e68cd837a5c3c737a88d44b1e65f7051e956206
WORKDIR /cactus/MPIwrapper
RUN which mpirun
RUN cmake -B build \
        -DCMAKE_C_COMPILER=mpicc \
        -DCMAKE_CXX_COMPILER=mpicxx \
        -DCMAKE_Fortran_COMPILER=mpifort \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpiwrapper
RUN cmake --build build
RUN cmake --install build
WORKDIR /cactus

# Install MPItrampoline
RUN git clone -n https://github.com/eschnett/MPItrampoline && cd MPItrampoline && git checkout 3bdd20528cf874615eae518decfa91334cbbe128
WORKDIR /cactus/MPItrampoline
RUN cmake -B build \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpitrampoline
RUN cmake --build build
RUN cmake --install build
WORKDIR /cactus

ENV MPITRAMPOLINE_VERBOSE=1
ENV MPITRAMPOLINE_MPIEXEC=/root/mpiwrapper/bin/mpiwrapperexec
ENV MPITRAMPOLINE_LIB=/root/mpiwrapper/lib/libmpiwrapper.so

# Install and run MPItest
RUN git clone -n https://github.com/eschnett/MPItest && cd MPItest && git checkout 145e08d066461c7a03af36b5be67525a7ac2d26d
WORKDIR /cactus/MPItest
RUN cmake -B build \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpitest \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DMPI_HOME=/root/mpitrampoline
RUN cmake --build build
RUN cmake --install build
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpitest/bin/mpi-test-c
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpitest/bin/mpi-test-cxx
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpitest/bin/mpi-test-mpif-f
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpitest/bin/mpi-test-mpif-f90
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpitest/bin/mpi-test-mpi-f90
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpitest/bin/mpi-test-mpi_f08-f90
WORKDIR /cactus

# Install mpi-test-suite
RUN git clone -n https://github.com/eschnett/mpi-test-suite && cd mpi-test-suite && git checkout f0f4c8665f6d94c517bcaa27f3545cc9ca52212d
WORKDIR /cactus/mpi-test-suite
RUN ./autogen.sh
RUN ./configure --prefix=/root/mpi-test-suite CC=/root/mpitrampoline/bin/mpicc LIBS=-lpthread
RUN make -j$(nproc)
RUN make -j$(nproc) install
WORKDIR /cactus

#TODO # TODO: This should be `docker run` instead
#TODO # Run mpi-test-suite
#TODO RUN case ${mpivendor} in \
#TODO         MPICH) opts='';; \
#TODO         OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
#TODO     esac && \
#TODO     /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpi-test-suite/bin/mpi_test_suite
