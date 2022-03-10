      program mpi_test_f
      implicit none
      include "mpif.h"

      integer rank, size
      integer isend, irecv
      integer count

      integer ivalue, isum

!     integer status(MPI_STATUS_SIZE)
      integer status(100 * MPI_STATUS_SIZE)
      integer ierror

      integer size1

      print '("mpi_test_f")'

      call MPI_Init(ierror)

      call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierror)
      call MPI_Comm_size(MPI_COMM_WORLD, size, ierror)
      print '("size: ",i0,", rank: ",i0)', size, rank
      size1 = size
      print '("size1: ",i0,", rank: ",i0)', size1, rank

      isend = 42
      irecv = -1
      print '("[",i0,"] MPI_Send")', rank
      call MPI_Send(isend, 1, MPI_INTEGER, mod(rank + 1, size),
     $     0, MPI_COMM_WORLD, ierror)
      print '("[",i0,"] MPI_Recv")', rank
      call MPI_Recv(irecv, 1, MPI_INTEGER, mod(rank + size - 1, size),
     $     0, MPI_COMM_WORLD, status, ierror)
      print '("[",i0,"] if size")', rank, size
      print '("[",i0,"] if size1")', rank, size1
      call flush()
      print '("[",i0,"] if isend")', rank
      call flush()
      if (isend /= 42) stop
      print '("[",i0,"] if irecv")', rank
      call flush()
      if (irecv /= 42) stop
      print '("[",i0,"] if source")', rank
      call flush()
      print '("[",i0,"] if source SRC=", i0)', rank, MPI_SOURCE
      call flush()
      print '("[",i0,"] if source rank+size-1=", i0)',
     &     rank, rank + size - 1
      call flush()
      print '("[",i0,"] if source size=", i0)', rank, size
      print '("[",i0,"] if source size1=", i0)', rank, size1
      call flush()
      print '("[",i0,"] if source mod=", i0)', rank,
     &     mod(rank + size - 1, size)
      call flush()
      print '("[",i0,"] if source src=", i0)', rank, status(MPI_SOURCE)
      call flush()
      if (status(MPI_SOURCE) /= mod(rank + size - 1, size)) stop
      print '("[",i0,"] if tag")', rank
      call flush()
      if (status(MPI_TAG) /= 0) stop
      print '("[",i0,"] MPI_Get_count")', rank
      call flush()
      call MPI_Get_count(status, MPI_INTEGER, count, ierror)
      if (count /= 1) stop
      if (rank == 0) then
         print '("sent: ",i0,", received: ",i0)', isend, irecv
         call flush()
         print '("source: ",i0,", tag: ",i0,", error: ",i0,
     $", count: ",i0)',
     $        status(MPI_SOURCE), status(MPI_TAG), status(MPI_ERROR),
     $        count
         call flush()
      end if

      ivalue = 1
      print '("MPI_Allreduce")'
      call MPI_Allreduce(ivalue, isum, 1, MPI_INTEGER, MPI_SUM,
     &     MPI_COMM_WORLD, ierror)
      if (ivalue /= 1) call MPI_Abort(MPI_COMM_WORLD, 6, ierror)
      if (isum /= size) call MPI_Abort(MPI_COMM_WORLD, 7, ierror)
      call MPI_Allreduce(MPI_IN_PLACE, ivalue, 1, MPI_INTEGER, MPI_SUM,
     &     MPI_COMM_WORLD, ierror)
      if (ivalue /= isum) call MPI_Abort(MPI_COMM_WORLD, 8, ierror)

      call MPI_Finalize(ierror)

      print '("Done.")'

      end
