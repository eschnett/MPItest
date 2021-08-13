#[[
rm -rf build ../MPIstuff/mpitest
cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=gcc-mp-11 -DCMAKE_CXX_COMPILER=g++-mp-11 -DCMAKE_Fortran_COMPILER=gfortran-mp-11 -DMPI_HOME=$HOME/src/c/MPIstuff/mpitrampoline -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$HOME/src/c/MPIstuff/mpitest
cmake --build build && cmake --install build
]]



cmake_minimum_required(VERSION 3.12...3.20)
project(
  MPItest VERSION 1.0.0
  DESCRIPTION "MPI test"
  LANGUAGES C CXX Fortran
  )

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

find_package(MPI REQUIRED)

# TODO: Avoid having to specify ${CMAKE_DL_LIBS}
add_executable(mpi-test-c mpi-test-c.c)
target_link_libraries(mpi-test-c PRIVATE MPI::MPI_C ${CMAKE_DL_LIBS})

add_executable(mpi-test-cxx mpi-test-cxx.cxx)
target_link_libraries(mpi-test-cxx PRIVATE MPI::MPI_CXX ${CMAKE_DL_LIBS})

add_executable(mpi-test-f mpi-test-f.f)
target_link_libraries(mpi-test-f PRIVATE MPI::MPI_Fortran ${CMAKE_DL_LIBS})

add_executable(mpi-test-f90 mpi-test-f90.f90)
target_link_libraries(mpi-test-f90 PRIVATE MPI::MPI_Fortran ${CMAKE_DL_LIBS})

install(TARGETS mpi-test-c mpi-test-cxx mpi-test-f mpi-test-f90)
