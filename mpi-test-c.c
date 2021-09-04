#include <mpi.h>

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

void add(void *invec, void *inoutvec, int *len, MPI_Datatype *datatype) {
  assert(*datatype == MPI_INT);
  for (int i = 0; i < *len; ++i)
    ((int *)inoutvec)[i] += ((int *)invec)[i];
}

int main(int argc, char **argv) {

  int initialized, finalized;
  // fprintf(stderr, "MPI_Initialized\n");
  MPI_Initialized(&initialized);
  assert(!initialized);
  // fprintf(stderr, "MPI_Finalized\n");
  MPI_Finalized(&finalized);
  assert(!finalized);

  // fprintf(stderr, "MPI_Init\n");
  MPI_Init(&argc, &argv);

  // fprintf(stderr, "MPI_Initialized\n");
  MPI_Initialized(&initialized);
  assert(initialized);
  // fprintf(stderr, "MPI_Finalized\n");
  MPI_Finalized(&finalized);
  assert(!finalized);

  int rank, size;
  // fprintf(stderr, "MPI_Comm_rank\n");
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  // fprintf(stderr, "MPI_Comm_size\n");
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  int processor_name_length;
  // fprintf(stderr, "MPI_Get_processor_name\n");
  MPI_Get_processor_name(processor_name, &processor_name_length);
  printf("size: %d, rank: %d, processor name: \"%s\"\n", size, rank,
         processor_name);

  const char *const comm_world_size_str = getenv("MPITEST_COMM_WORLD_SIZE");
  if (comm_world_size_str) {
    const int comm_world_size = atoi(comm_world_size_str);
    if (size != comm_world_size) {
      fprintf(stderr,
              "*** Error: MPI_COMM_WORLD has the wrong size.\n"
              "  Expected: %d\n"
              "  Found: %d\n",
              comm_world_size, size);
      exit(1);
    }
  }

  {
    int isend = 42;
    int irecv = -1;
    MPI_Status status;
    // fprintf(stderr, "MPI_Sendrecv\n");
    MPI_Sendrecv(&isend, 1, MPI_INT, (rank + 1) % size, 0, &irecv, 1, MPI_INT,
                 (rank + size - 1) % size, 0, MPI_COMM_WORLD, &status);
    assert(isend == 42);
    assert(irecv == 42);
    assert(status.MPI_SOURCE == (rank + size - 1) % size);
    assert(status.MPI_TAG == 0);
    int count;
    // fprintf(stderr, "MPI_Get_count\n");
    MPI_Get_count(&status, MPI_INT, &count);
    assert(count == 1);
    if (rank == 0) {
      printf("sent: %d, received: %d\n", isend, irecv);
      printf("source: %d, tag: %d, count: %d\n", status.MPI_SOURCE,
             status.MPI_TAG, count);
    }
  }

  {
    int isend = 42;
    int irecv = -1;
    MPI_Request sreq;
    // fprintf(stderr, "MPI_Isend\n");
    MPI_Isend(&isend, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD, &sreq);
    MPI_Request rreq;
    // fprintf(stderr, "MPI_Irecv\n");
    MPI_Irecv(&irecv, 1, MPI_INT, (rank + size - 1) % size, 0, MPI_COMM_WORLD,
              &rreq);
    // fprintf(stderr, "MPI_Wait\n");
    MPI_Wait(&sreq, MPI_STATUS_IGNORE);
    MPI_Status status;
    // fprintf(stderr, "MPI_Wait\n");
    MPI_Wait(&rreq, &status);
    assert(isend == 42);
    assert(irecv == 42);
    assert(status.MPI_SOURCE == (rank + size - 1) % size);
    assert(status.MPI_TAG == 0);
    int count;
    // fprintf(stderr, "MPI_Get_count\n");
    MPI_Get_count(&status, MPI_INT, &count);
    assert(count == 1);
  }

  struct float5 {
    float elts[5];
  };
  MPI_Datatype mpi_float5;
  // fprintf(stderr, "MPI_Type_contiguous\n");
  MPI_Type_contiguous(5, MPI_FLOAT, &mpi_float5);
  MPI_Datatype mpi_float55;
  // fprintf(stderr, "MPI_Type_contiguous\n");
  MPI_Type_contiguous(5, mpi_float5, &mpi_float55);

  // fprintf(stderr, "MPI_Barrier\n");
  MPI_Barrier(MPI_COMM_WORLD);

  {
    int ivalue = rank;
    // fprintf(stderr, "MPI_Bcast\n");
    MPI_Bcast(&ivalue, 1, MPI_INT, 0, MPI_COMM_WORLD);
    assert(ivalue == 0);
  }

  {
    MPI_Op op_add;
    // fprintf(stderr, "MPI_Op_create\n");
    MPI_Op_create(add, 1, &op_add);
    int ivalue = 1;
    int isum;
    // fprintf(stderr, "MPI_Allreduce\n");
    MPI_Allreduce(&ivalue, &isum, 1, MPI_INT, op_add, MPI_COMM_WORLD);
    assert(ivalue == 1);
    assert(isum == size);
    // fprintf(stderr, "MPI_Op_free\n");
    MPI_Op_free(&op_add);
  }

  // fprintf(stderr, "MPI_Initialized\n");
  MPI_Initialized(&initialized);
  assert(initialized);
  // fprintf(stderr, "MPI_Finalized\n");
  MPI_Finalized(&finalized);
  assert(!finalized);

  // fprintf(stderr, "MPI_Finalize\n");
  MPI_Finalize();

  // fprintf(stderr, "MPI_Initialized\n");
  MPI_Initialized(&initialized);
  // This fails for MPICH 3.4.2
  // assert(initialized);
  // fprintf(stderr, "MPI_Finalized\n");
  MPI_Finalized(&finalized);
  assert(finalized);

  // fprintf(stderr, "Done.\n");
  return 0;
}
