#[[
# Test all the ways in which cmake looks for an MPI library

rm -rf build ../MPIstuff/mpitest
cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DMPIEXEC_EXECUTABLE=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpiexec -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

rm -rf build ../MPIstuff/mpitest
cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DMPI_HOME=$HOME/src/c/MPIstuff/mpitrampoline -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

rm -rf build ../MPIstuff/mpitest
env MPITRAMPOLINE_CC=gcc-mp-11 MPITRAMPOLINE_CXX=g++-mp-11 MPITRAMPOLINE_FC=gfortran-mp-11 cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpicc -DCMAKE_CXX_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpicxx -DCMAKE_Fortran_COMPILER=$HOME/src/c/MPIstuff/mpitrampoline/bin/mpifc -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build

env MPITRAMPOLINE_LIB=/Users/eschnett/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.dylib mpiexec-openmpi-gcc11 -n 4 /Users/eschnett/src/c/MPIstuff/mpitest/bin/mpi-test-c
env MPITRAMPOLINE_LIB=/Users/eschnett/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.dylib mpiexec-openmpi-gcc11 -n 4 /Users/eschnett/src/c/MPIstuff/mpitest/bin/mpi-test-cxx
env MPITRAMPOLINE_LIB=/Users/eschnett/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.dylib mpiexec-openmpi-gcc11 -n 4 /Users/eschnett/src/c/MPIstuff/mpitest/bin/mpi-test-f
env MPITRAMPOLINE_LIB=/Users/eschnett/src/c/MPIstuff/mpiwrapper-openmpi/lib/libmpiwrapper.dylib mpiexec-openmpi-gcc11 -n 4 /Users/eschnett/src/c/MPIstuff/mpitest/bin/mpi-test-f90
]]



cmake_minimum_required(VERSION 3.12...3.20)
project(
  MPItest VERSION 1.0.0
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
