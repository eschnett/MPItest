#include <mpi.h>

extern "C" const char *const MPITRAMPOLINE_VERBOSE;
const char *const MPITRAMPOLINE_VERBOSE = "1";

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  MPI_Finalize();
  return 0;
}
