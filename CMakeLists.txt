cmake_minimum_required(VERSION 3.12...3.20)
project(
  MPItest VERSION 1.0.0
  DESCRIPTION "MPI test"
  # C++ and Fortan are only used for tests
  LANGUAGES C CXX Fortran
  )

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

add_executable(mpi-test-c mpi-test-c.c)
target_link_libraries(mpi-test-c mpi)

add_executable(mpi-test-cxx mpi-test-cxx.cxx)
target_link_libraries(mpi-test-cxx mpi)

add_executable(mpi-test-f mpi-test-f.f)
target_link_libraries(mpi-test-f mpi)

add_executable(mpi-test-f90 mpi-test-f90.f90)
target_link_libraries(mpi-test-f90 mpi)

install(TARGETS mpi-test-c mpi-test-cxx mpi-test-f mpi-test-f90)
