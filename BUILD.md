# Redshift

# Test all the ways in which cmake looks for an MPI library

## mpitest-mpiexec

```sh
rm -rf mpitest-mpiexec $HOME/src/c/MPIstuff/mpitest-mpiexec
cmake -S . -B mpitest-mpiexec -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DCMAKE_Fortran_FLAGS='-fallow-argument-mismatch -fcray-pointer' -DMPIEXEC_EXECUTABLE=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest-mpiexec
cmake --build mpitest-mpiexec && cmake --install mpitest-mpiexec
```

## mpitest-mpiexec (shared libraries)

```sh
rm -rf mpitest-mpiexec $HOME/src/c/MPIstuff/mpitest-mpiexec
cmake -S . -B mpitest-mpiexec -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DMPIEXEC_EXECUTABLE=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest-mpiexec
cmake --build mpitest-mpiexec && cmake --install mpitest-mpiexec
```

## mpitest-mpihome

```sh
rm -rf mpitest-mpihome $HOME/src/c/MPIstuff/mpitest-mpihome
cmake -S . -B mpitest-mpihome -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DCMAKE_Fortran_FLAGS='-fallow-argument-mismatch -fcray-pointer' -DMPI_HOME=$HOME/src/c/MPIstuff/mpitrampoline -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest-mpihome
cmake --build mpitest-mpihome && cmake --install mpitest-mpihome
```

## mpitest-compilers

```sh
rm -rf mpitest-compilers $HOME/src/c/MPIstuff/mpitest-compilers
env MPITRAMPOLINE_CC=gcc-mp-11 MPITRAMPOLINE_CXX=g++-mp-11 MPITRAMPOLINE_FC=gfortran-mp-11 cmake -S . -B mpitest-compilers -G Ninja -DCMAKE_C_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpicc -DCMAKE_CXX_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpicxx -DCMAKE_Fortran_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpifc -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest-compilers
cmake --build mpitest-compilers && cmake --install mpitest-compilers
```

## MacPorts OpenMPI

```sh
#ALL BROKEN:
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi_f08-f90
```

## MacPorts MPICH

```sh
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f90
#BROKEN:
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi-f90
#BROKEN:
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-macports-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi_f08-f90
```

## OpenMPI

```sh
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi_f08-f90
```

## MPICH

```sh
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest-mpihome/bin/mpi-test-mpi_f08-f90
```

# 

env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi_f08-f90

#

env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi_f08-f90

env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapperexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi_f08-f90



module load cmake
rm -rf build $HOME/src/c/MPIstuff/mpitest
cmake -S . -B build -DCMAKE_C_COMPILER=gcc-9 -DCMAKE_CXX_COMPILER=g++-9 -DCMAKE_Fortran_COMPILER=gfortran -DMPIEXEC_EXECUTABLE=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

env MPITRAMPOLINE_MPIEXEC=/usr/bin/mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi-ubuntu/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 --oversubscribe -mca oob_tcp_if_include lo --mca btl self,vader $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c

env MPITRAMPOLINE_MPIEXEC=/cm/shared/apps/openmpi/gcc-9/64/4.1.0/bin/mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 --oversubscribe -mca oob_tcp_if_include lo --mca btl self,vader $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c

env MPITRAMPOLINE_MPIEXEC=$HOME/src/spack/opt/spack/linux-ubuntu18.04-skylake_avx512/gcc-11.2.0/openmpi-4.1.1-3b4drmye35bg6hok7gk462yvoj6d4oqq/bin/mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi-spack/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 --oversubscribe -mca oob_tcp_if_include lo --mca btl self,vader $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c

env MPITRAMPOLINE_MPIEXEC=/cm/shared/apps/mpich/gcc-9//3.3.2/bin/mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c

module load mpi
env MPITRAMPOLINE_MPIEXEC=/cm/shared/apps/intel/mpi/2021.1.1/bin/mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-intel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
module unload mpi
