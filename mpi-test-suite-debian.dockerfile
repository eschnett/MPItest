# This Dockerfile is for debugging the CI setup
# Run `docker build --file mpi-test-suite-debian.dockerfile --build-arg cpuarch=amd64 --build-arg mpivendor=MPICH --progress plain .`

ARG cpuarch=amd64 # amd64, arm32v5, arm32v7, arm64v8, i386, mips64le, ppc64le, riscv64

FROM ${cpuarch}/debian:11.1

ARG mpivendor=MPICH             # MPICH, OpenMPI

RUN mkdir /cactus
WORKDIR /cactus

# Install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get --yes --no-install-recommends install \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        cmake \
        g++ \
        gdb \
        gengetopt \
        gfortran \
        git \
        python3 \
        wget

# Install MPIwrapper
RUN case $mpivendor in \
        MPICH) pkgs=libmpich-dev;; \
        OpenMPI) pkgs=libopenmpi-dev;; \
        *) exit 1;; \
    esac && \
    apt-get --yes --no-install-recommends install ${pkgs}
RUN git clone -n https://github.com/eschnett/MPIwrapper
WORKDIR /cactus/MPIwrapper
RUN git checkout 428a2d3726caef68aebe62a492066d1a9de6fa4a
RUN which mpirun
RUN cmake -S . -B build \
        -DCMAKE_CXX_COMPILER=mpicxx \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpiwrapper
RUN cmake --build build
RUN cmake --install build
WORKDIR /cactus

# Install MPItrampoline
RUN git clone -n https://github.com/eschnett/MPItrampoline
WORKDIR /cactus/MPItrampoline
RUN git checkout eee4ec583f6b0246f249d4684999f9f3de8b3c28
RUN cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpitrampoline
RUN cmake --build build
RUN cmake --install build
WORKDIR /cactus

# Install mpi-test-suite
RUN git clone -n https://github.com/eschnett/mpi-test-suite
WORKDIR /cactus/mpi-test-suite
RUN git checkout 98013e8522fd8c04fb88dabc06e19d5bf8ea37cf
RUN ./autogen.sh
RUN ./configure --prefix=/root/mpi-test-suite CC=/root/mpitrampoline/bin/mpicc LIBS=-lpthread
RUN make -j$(nproc)
RUN make -j$(nproc) install
WORKDIR /cactus

# Run mpi-test-suite
ENV MPITRAMPOLINE_VERBOSE=1
ENV MPITRAMPOLINE_MPIEXEC=/root/mpiwrapper/bin/mpiwrapperexec
ENV MPITRAMPOLINE_LIB=/root/mpiwrapper/lib/libmpiwrapper.so
RUN case ${mpivendor} in \
        MPICH) opts='';; \
        OpenMPI) opts='--oversubscribe --allow-run-as-root';; \
    esac && \
    /root/mpitrampoline/bin/mpiexec ${opts} -n 4 /root/mpi-test-suite/bin/mpi_test_suite