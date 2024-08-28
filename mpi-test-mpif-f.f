      program mpi_test_f
      implicit none
      include "mpif.h"

      integer initialized, finalized

      integer rank, size
      character*(MPI_MAX_PROCESSOR_NAME) processor_name
      integer processor_name_length

      integer isend, irecv
      integer count

      integer ivalue, isum

      integer status(MPI_STATUS_SIZE)
      integer ierror

      print '("mpi_test_f")'

      call MPI_Initialized(initialized, ierror)
      if (initialized /= 0) stop
      call MPI_Finalized(finalized, ierror)
      if (finalized /= 0) stop
      call MPI_Init(ierror)
      call MPI_Initialized(initialized, ierror)
      if (initialized /= 1) stop
      call MPI_Finalized(finalized, ierror)
      if (finalized /= 0) stop

      call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierror)
      call MPI_Comm_size(MPI_COMM_WORLD, size, ierror)
      call MPI_Get_processor_name(processor_name, processor_name_length,
     &     ierror)
      if (processor_name_length > MPI_MAX_PROCESSOR_NAME) stop
      if (len_trim(processor_name(processor_name_length + 1 :)) > 0)
     &     stop
      print '("size: ",i0,", rank: ",i0," processor name: """,a,"""")',
     &     size, rank, trim(processor_name)

      isend = 42
      irecv = -1
      print '("[",i0,"] MPI_Send")', rank
      call MPI_Send(isend, 1, MPI_INTEGER, mod(rank + 1, size),
     &     0, MPI_COMM_WORLD, ierror)
      print '("[",i0,"] MPI_Recv")', rank
      call MPI_Recv(irecv, 1, MPI_INTEGER, mod(rank + size - 1, size),
     &     0, MPI_COMM_WORLD, status, ierror)
      if (isend /= 42) stop
      if (irecv /= 42) stop
      if (status(MPI_SOURCE) /= mod(rank + size - 1, size)) stop
      if (status(MPI_TAG) /= 0) stop
      print '("[",i0,"] MPI_Get_count")', rank
      call MPI_Get_count(status, MPI_INTEGER, count, ierror)
      if (count /= 1) stop
      if (rank == 0) then
         print '("source: ",i0,", tag: ",i0,", error: ",i0,
     &", count: ",i0)',
     &        status(MPI_SOURCE), status(MPI_TAG), status(MPI_ERROR),
     &        count
      end if

      ivalue = 1
      print '("MPI_Allreduce")'
      call MPI_Allreduce(ivalue, isum, 1, MPI_INTEGER, MPI_SUM,
     &     MPI_COMM_WORLD, ierror)
      if (ivalue /= 1) call MPI_Abort(MPI_COMM_WORLD, 6, ierror)
      if (isum /= size) call MPI_Abort(MPI_COMM_WORLD, 7, ierror)
      print '("MPI_Allreduce (in place)")'
      print '("   MPI_IN_PLACE=",i0)', MPI_IN_PLACE
      call MPI_Allreduce(MPI_IN_PLACE, ivalue, 1, MPI_INTEGER, MPI_SUM,
     &     MPI_COMM_WORLD, ierror)
      print '("   ivalue=",i0)', ivalue
      if (ivalue /= isum) call MPI_Abort(MPI_COMM_WORLD, 8, ierror)

      call MPI_Finalize(ierror)
      call MPI_Initialized(initialized, ierror)
c     if (initialized /= 1) stop
      call MPI_Finalized(finalized, ierror)
      if (finalized /= 1) stop

      print '("Done.")'

      end
