program mpi_test_mpi_f90
  use mpi
  implicit none

  integer rank, size
  integer isend, irecv
  integer count

  integer ivalue, isum

  integer status(MPI_STATUS_SIZE)
  integer ierror

  print '("mpi_test_mpi_f90")'

  print '("MPI_Init")'
  call MPI_Init(ierror)

  print '("MPI_Comm_rank")'
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierror)
  print '("MPI_Comm_size")'
  call MPI_Comm_size(MPI_COMM_WORLD, size, ierror)
  print '("size: ",i0,", rank: ",i0)', size, rank

  isend = 42
  irecv = -1
  print '("MPI_Send")'
  call MPI_Send(isend, 1, MPI_INTEGER, mod(rank + 1, size), 0, &
       MPI_COMM_WORLD, ierror)
  print '("MPI_Recv")'
  call MPI_Recv(irecv, 1, MPI_INTEGER, mod(rank + size - 1, size), 0, &
       MPI_COMM_WORLD, status, ierror)
  if (isend /= 42) call MPI_Abort(MPI_COMM_WORLD, 1, ierror)
  if (irecv /= 42) call MPI_Abort(MPI_COMM_WORLD, 2, ierror)
  if (status(MPI_SOURCE) /= mod(rank + size - 1, size)) then
     call MPI_Abort(MPI_COMM_WORLD, 3, ierror)
  end if
  if (status(MPI_TAG) /= 0) call MPI_Abort(MPI_COMM_WORLD, 4, ierror)
  print '("MPI_Get_count")'
  call MPI_Get_count(status, MPI_INTEGER, count, ierror)
  if (count /= 1) call MPI_Abort(MPI_COMM_WORLD, 5, ierror)
  if (rank == 0) then
     print '("sent: ",i0,", received: ",i0)', isend, irecv
     print '("source: ",i0,", tag: ",i0,", error: ",i0,", count: ",i0)', &
          status(MPI_SOURCE), status(MPI_TAG), status(MPI_ERROR), count
  end if

  ivalue = 1
  print '("MPI_Allreduce")'
  call MPI_Allreduce(ivalue, isum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, &
       ierror)
  if (ivalue /= 1) call MPI_Abort(MPI_COMM_WORLD, 6, ierror)
  if (isum /= size) call MPI_Abort(MPI_COMM_WORLD, 7, ierror)
  print '("MPI_Allreduce (in place)")'
  call MPI_Allreduce(MPI_IN_PLACE, ivalue, 1, MPI_INTEGER, MPI_SUM, &
       MPI_COMM_WORLD, ierror)
  if (ivalue /= isum) call MPI_Abort(MPI_COMM_WORLD, 8, ierror)

  print '("MPI_Finalize")'
  call MPI_Finalize(ierror)

  print '("Done.")'

end program mpi_test_mpi_f90
