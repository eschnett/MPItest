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

add_executable(mpi-test-mpif-f mpi-test-mpif-f.f mpi-test-mpif-f-c.c)
target_link_libraries(mpi-test-mpif-f PUBLIC MPI::MPI_Fortran)

add_executable(mpi-test-mpif-f90 mpi-test-mpif-f90.f90)
target_link_libraries(mpi-test-mpif-f90 PUBLIC MPI::MPI_Fortran)

add_executable(mpi-test-mpi-f90 mpi-test-mpi-f90.f90)
target_link_libraries(mpi-test-mpi-f90 PUBLIC MPI::MPI_Fortran)

add_executable(mpi-test-mpi_f08-f90 mpi-test-mpi_f08-f90.f90)
target_link_libraries(mpi-test-mpi_f08-f90 PUBLIC MPI::MPI_Fortran)

install(TARGETS mpi-test-c mpi-test-cxx mpi-test-mpif-f mpi-test-mpif-f90 mpi-test-mpi-f90 mpi-test-mpi_f08-f90)
