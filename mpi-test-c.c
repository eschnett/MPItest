#include <mpi.h>

#include <assert.h>
#include <stdio.h>

void add(void *invec, void *inoutvec, int *len, MPI_Datatype *datatype) {
  fprintf(stderr, "Calling add\n");
  assert(*datatype == MPI_INT);
  for (int i = 0; i < *len; ++i)
    ((int *)inoutvec)[i] += ((int *)invec)[i];
}

int main(int argc, char **argv) {
  int initialized, finalized;
  MPI_Initialized(&initialized);
  assert(!initialized);
  MPI_Finalized(&finalized);
  assert(!finalized);

  MPI_Init(&argc, &argv);

  MPI_Initialized(&initialized);
  assert(initialized);
  MPI_Finalized(&finalized);
  assert(!finalized);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("size: %d, rank: %d\n", size, rank);

  {
    int isend = 42;
    int irecv = -1;
    MPI_Status status;
    MPI_Sendrecv(&isend, 1, MPI_INT, (rank + 1) % size, 0, &irecv, 1, MPI_INT,
                 (rank + size - 1) % size, 0, MPI_COMM_WORLD, &status);
    assert(isend == 42);
    assert(irecv == 42);
    assert(status.MPI_SOURCE == (rank + size - 1) % size);
    assert(status.MPI_TAG == 0);
    int count;
    MPI_Get_count(&status, MPI_INT, &count);
    assert(count == 1);
    if (rank == 0) {
      printf("sent: %d, received: %d\n", isend, irecv);
      printf("source: %d, tag: %d, error: %d, count: %d\n", status.MPI_SOURCE,
             status.MPI_TAG, status.MPI_ERROR, count);
    }
  }

  {
    int isend = 42;
    int irecv = -1;
    MPI_Request sreq;
    MPI_Isend(&isend, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD, &sreq);
    MPI_Request rreq;
    MPI_Irecv(&irecv, 1, MPI_INT, (rank + size - 1) % size, 0, MPI_COMM_WORLD,
              &rreq);
    MPI_Wait(&sreq, MPI_STATUS_IGNORE);
    MPI_Status status;
    MPI_Wait(&rreq, &status);
    assert(isend == 42);
    assert(irecv == 42);
    assert(status.MPI_SOURCE == (rank + size - 1) % size);
    assert(status.MPI_TAG == 0);
    int count;
    MPI_Get_count(&status, MPI_INT, &count);
    assert(count == 1);
  }

  struct float5 {
    float elts[5];
  };
  MPI_Datatype mpi_float5;
  MPI_Type_contiguous(5, MPI_FLOAT, &mpi_float5);
  MPI_Datatype mpi_float55;
  MPI_Type_contiguous(5, mpi_float5, &mpi_float55);

  MPI_Barrier(MPI_COMM_WORLD);

  {
    int ivalue = rank;
    MPI_Bcast(&ivalue, 1, MPI_INT, 0, MPI_COMM_WORLD);
    assert(ivalue == 0);
  }

  {
    MPI_Op op_add;
    MPI_Op_create(add, 1, &op_add);
    int ivalue = 1;
    int isum;
    MPI_Allreduce(&ivalue, &isum, 1, MPI_INT, op_add, MPI_COMM_WORLD);
    assert(ivalue == 1);
    assert(isum == size);
    MPI_Op_free(&op_add);
  }

  MPI_Finalize();

  MPI_Initialized(&initialized);
  assert(initialized);
  MPI_Finalized(&finalized);
  assert(finalized);

  return 0;
}
