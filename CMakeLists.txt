#[[
# Test all the ways in which cmake looks for an MPI library

rm -rf build $HOME/src/c/MPIstuff/mpitest
cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DMPIEXEC_EXECUTABLE=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

rm -rf build $HOME/src/c/MPIstuff/mpitest
cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DMPI_HOME=$HOME/src/c/MPIstuff/mpitrampoline -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

rm -rf build $HOME/src/c/MPIstuff/mpitest
env MPITRAMPOLINE_CC=gcc-mp-11 MPITRAMPOLINE_CXX=g++-mp-11 MPITRAMPOLINE_FC=gfortran-mp-11 cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpicc -DCMAKE_CXX_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpicxx -DCMAKE_Fortran_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpifc -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi_f08-f90

env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi_f08-f90

env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpif-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi-f90
env MPITRAMPOLINE_MPIEXEC=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/bin/mpiwrapper-mpiexec MPITRAMPOLINE_LIB=$HOME/src/c/MPIstuff/mpiwrapper-mpich-twolevel/lib/libmpiwrapper.so $HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -n 4 $HOME/src/c/MPIstuff/mpitest/bin/mpi-test-mpi_f08-f90



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
]]



cmake_minimum_required(VERSION 3.12...3.20)
project(
  MPItest VERSION 1.1.1
  DESCRIPTION "MPI test"
  LANGUAGES C CXX Fortran
  )

set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

find_package(MPI REQUIRED)

add_executable(mpi-test-c mpi-test-c.c)
target_link_libraries(mpi-test-c PUBLIC MPI::MPI_C)

add_executable(mpi-test-cxx mpi-test-cxx.cxx)
target_link_libraries(mpi-test-cxx PUBLIC MPI::MPI_CXX)

add_executable(mpi-test-mpif-f mpi-test-mpif-f.f)
target_link_libraries(mpi-test-mpif-f PUBLIC MPI::MPI_Fortran)

add_executable(mpi-test-mpif-f90 mpi-test-mpif-f90.f90)
target_link_libraries(mpi-test-mpif-f90 PUBLIC MPI::MPI_Fortran)

add_executable(mpi-test-mpi-f90 mpi-test-mpi-f90.f90)
target_link_libraries(mpi-test-mpi-f90 PUBLIC MPI::MPI_Fortran)

add_executable(mpi-test-mpi_f08-f90 mpi-test-mpi_f08-f90.f90)
target_link_libraries(mpi-test-mpi_f08-f90 PUBLIC MPI::MPI_Fortran)

install(TARGETS mpi-test-c mpi-test-cxx mpi-test-mpif-f mpi-test-mpif-f90 mpi-test-mpi-f90 mpi-test-mpi_f08-f90)
