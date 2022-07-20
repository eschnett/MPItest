# Failures

mpi-test-suite-debian.cpuarch-arm32v5.mpivendor-MPICH: stalls in
tst_test_array[47]:Alltoall

mpi-test-suite-debian.cpuarch-arm32v5.mpivendor-OpenMPI: OpenMPI is
not supported on 32-bit systems since its MPI_Count is not 64 bits
wide. MPItrampoline does not yet support this.

mpi-test-suite-debian.cpuarch-arm32v7.mpivendor-OpenMPI: OpenMPI is
not supported on 32-bit systems since its MPI_Count is not 64 bits
wide. MPItrampoline does not yet support this.

mpi-test-suite-debian.cpuarch-arm64v8.mpivendor-OpenMPI: stalls in
tst_test_array[47]:Alltoall

mpi-test-suite-debian.cpuarch-i386.mpivendor-OpenMPI: OpenMPI is not
supported on 32-bit systems since its MPI_Count is not 64 bits wide.
MPItrampoline does not yet support this.

mpi-test-suite-debian.cpuarch-riscv64.mpivendor-MPICH: Debian 11.4
image does not exist

mpi-test-suite-debian.cpuarch-riscv64.mpivendor-OpenMPI: Debian 11.4
image does not exist
