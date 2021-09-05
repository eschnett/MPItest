# This Dockerfile is for debugging the CI setup
# First: `docker build --file test-i386-debian-11.0.dockerfile --tag mpitest .`
# Then maybe: `docker run -it mpitest`

# TODO: Use Debian Testing instead?
FROM i386/debian:11.0

RUN mkdir /cactus
WORKDIR /cactus

# Install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get --yes --no-install-recommends install \
        build-essential \
        ca-certificates \
        cmake \
        g++ \
        gdb \
        gfortran \
        git \
        python3 \
        wget

# Install MPItrampoline
RUN git clone https://github.com/eschnett/MPItrampoline
WORKDIR /cactus/MPItrampoline
RUN mkdir build
RUN cmake  --version
RUN cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpitrampoline
RUN cmake --build build
RUN cmake --install build
WORKDIR /cactus

# Install MPItest
RUN git clone https://github.com/eschnett/MPItest
WORKDIR /cactus/MPItest
RUN mkdir build
RUN cmake -S . -B build \
        -DMPIEXEC_EXECUTABLE=/root/mpitrampoline/bin/mpiexec \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpitest
RUN cmake --build build
RUN cmake --install build
WORKDIR /cactus

# Install MPIwrapper
RUN apt-get --yes --no-install-recommends install libmpich-dev
# RUN apt-get --yes --no-install-recommends install libopenmpi-dev
RUN git clone https://github.com/eschnett/MPIwrapper
WORKDIR /cactus/MPIwrapper
RUN mkdir build
RUN cmake -S . -B build \
        -DCMAKE_CXX_COMPILER=mpicxx \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=/root/mpiwrapper
RUN cmake --build build
RUN cmake --install build

# Test MPIwrapper
ENV mpiexec_options=''
# ENV mpiexec_options='--oversubscribe --allow-run-as-root'
ENV MPITRAMPOLINE_VERBOSE=1
ENV MPITRAMPOLINE_DLOPEN_MODE=dlmopen
ENV MPITRAMPOLINE_DLOPEN_BINDING=now
ENV MPITRAMPOLINE_MPIEXEC=/root/mpiwrapper/bin/mpiwrapperexec
ENV MPITRAMPOLINE_LIB=/root/mpiwrapper/lib/libmpiwrapper.so
RUN /root/mpitrampoline/bin/mpiexec ${mpiexec_options} -n 4 /root/mpitest/bin/mpi-test-c
RUN /root/mpitrampoline/bin/mpiexec ${mpiexec_options} -n 4 /root/mpitest/bin/mpi-test-cxx
RUN /root/mpitrampoline/bin/mpiexec ${mpiexec_options} -n 4 /root/mpitest/bin/mpi-test-mpif-f
RUN /root/mpitrampoline/bin/mpiexec ${mpiexec_options} -n 4 /root/mpitest/bin/mpi-test-mpif-f90
RUN /root/mpitrampoline/bin/mpiexec ${mpiexec_options} -n 4 /root/mpitest/bin/mpi-test-mpi-f90
RUN /root/mpitrampoline/bin/mpiexec ${mpiexec_options} -n 4 /root/mpitest/bin/mpi-test-mpi_f08-f90
