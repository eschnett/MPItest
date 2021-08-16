      program mpi_test_f
      implicit none
      include "mpif.h"

      integer rank, size
      integer isend, irecv
      integer count

      integer status(MPI_STATUS_SIZE)
      integer ierror

      call MPI_Init(ierror)

      call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierror)
      call MPI_Comm_size(MPI_COMM_WORLD, size, ierror)
      print '("size: ",i0,", rank: ",i0)', size, rank

      isend = 42
      irecv = -1
      call MPI_Send(isend, 1, MPI_INTEGER, mod(rank + 1, size),
     $     0, MPI_COMM_WORLD, ierror)
      call MPI_Recv(irecv, 1, MPI_INTEGER, mod(rank + size - 1, size),
     $     0, MPI_COMM_WORLD, status, ierror)
      if (isend /= 42) stop
      if (irecv /= 42) stop
      if (status(MPI_SOURCE) /= mod(rank + size - 1, size)) stop
      if (status(MPI_TAG) /= 0) stop
      call MPI_Get_count(status, MPI_INTEGER, count, ierror)
      if (count /= 1) stop
      if (rank == 0) then
         print '("sent: ",i0,", received: ",i0)', isend, irecv
         print '("source: ",i0,", tag: ",i0,", error: ",i0,
     $", count: ",i0)',
     $        status(MPI_SOURCE), status(MPI_TAG), status(MPI_ERROR),
     $        count
      end if

      call MPI_Finalize(ierror)

      end
