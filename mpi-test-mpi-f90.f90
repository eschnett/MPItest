program mpi_test_mpi_f90
  use mpi
  implicit none
  integer ierror
  call MPI_Init(ierror)
  call MPI_Finalize(ierror)
end program mpi_test_mpi_f90
