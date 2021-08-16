program mpi_test_mpi_f90_f08
  use mpi_f08
  implicit none
  call MPI_Init()
  call MPI_Finalize()
end program mpi_test_mpi_f90_f08
