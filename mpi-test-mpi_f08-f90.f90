program mpi_test_mpi_f08_f90
  use mpi_f08
  implicit none

  integer rank, size
  integer isend, irecv
  integer count

  type(MPI_Status) :: status

  print '("mpi_test_mpi_f08_f90")'

  call MPI_Init()

  ! call MPI_Comm_rank(MPI_COMM_WORLD, rank)
  ! call MPI_Comm_size(MPI_COMM_WORLD, size)
  ! print '("size: ",i0,", rank: ",i0)', size, rank
  ! 
  ! isend = 42
  ! irecv = -1
  ! call MPI_Send(isend, 1, MPI_INTEGER, mod(rank + 1, size), 0, &
  !      MPI_COMM_WORLD)
  ! call MPI_Recv(irecv, 1, MPI_INTEGER, mod(rank + size - 1, size), 0, &
  !      MPI_COMM_WORLD, status)
  ! if (isend /= 42) call MPI_Abort(MPI_COMM_WORLD, 1)
  ! if (irecv /= 42) call MPI_Abort(MPI_COMM_WORLD, 2)
  ! if (status%MPI_SOURCE /= mod(rank + size - 1, size)) then
  !    call MPI_Abort(MPI_COMM_WORLD, 3)
  ! end if
  ! if (status%MPI_TAG /= 0) call MPI_Abort(MPI_COMM_WORLD, 4)
  ! call MPI_Get_count(status, MPI_INTEGER, count)
  ! if (count /= 1) call MPI_Abort(MPI_COMM_WORLD, 5)
  ! if (rank == 0) then
  !    print '("sent: ",i0,", received: ",i0)', isend, irecv
  !    print '("source: ",i0,", tag: ",i0,", error: ",i0,", count: ",i0)', &
  !         status%MPI_SOURCE, status%MPI_TAG, status%MPI_ERROR, count
  ! end if

  call MPI_Finalize()

  print '("Done.")'

end program mpi_test_mpi_f08_f90
