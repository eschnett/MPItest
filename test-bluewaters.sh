#!/bin/bash

# Test MPItrampoline on Blue Waters, an HPC system at the NCSA
# $ rsync -P test-bluewaters.sh h2ologin1.ncsa.illinois.edu:

set -euxo pipefail

path="$HOME/test-mpitrampoline"
rm -rf "$path"
mkdir "$path"
cd "$path"
mkdir "$path/local"

# Prepare
module switch PrgEnv-cray PrgEnv-gnu
module load bwpy/2.0.4
module load cmake/3.17.3

(
# Prepare
module switch gcc gcc/8.2.0

# Install MPItrampoline
rm -rf "$path/MPItrampoline"
git clone https://github.com/eschnett/MPItrampoline
cd "$path/MPItrampoline"
cmake -S . -B build                                             \
      -DCMAKE_BUILD_TYPE=Debug                                  \
      -DCMAKE_C_COMPILER=gcc                                    \
      -DCMAKE_Fortran_COMPILER=gfortran                         \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitrampoline"
cmake --build build
cmake --install build
cd "$path"

# Install MPItest
rm -rf "$path/MPItest"
git clone https://github.com/eschnett/MPItest
cd "$path/MPItest"
cmake -S . -B build                                                     \
      -DCMAKE_C_COMPILER=gcc                                            \
      -DCMAKE_CXX_COMPILER=g++                                          \
      -DCMAKE_Fortran_COMPILER=gfortran                                 \
      -DMPIEXEC_EXECUTABLE="$path/local/mpitrampoline/bin/mpiexec"      \
      -DCMAKE_BUILD_TYPE=Debug                                          \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitest"
cmake --build build
cmake --install build
cd "$path"
)

# Install MPIwrapper
case cray-mpich/7.7.4 in

    cray-mpich/7.7.4)
        MPITEST_MODULES='cray-mpich/7.7.4'
        MPITEST_CMAKE_OPTIONS="                 \
            -DCMAKE_CXX_COMPILER=CC             \
            -DCMAKE_Fortran_COMPILER=ftn        \
            -DMPIEXEC_EXECUTABLE=aprun          \
        "
        MPITEST_SET_ENVVARS=''
        MPITEST_MPIEXEC_OPTIONS=''
        ;;

    *)
        echo 'Unknown MPI variant' 1>&2
        exit 1
        ;;
esac

rm -rf "$path/MPIwrapper"
git clone https://github.com/eschnett/MPIwrapper
cd "$path/MPIwrapper"
module load $MPITEST_MODULES
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes
cmake -S . -B build                                     \
      $MPITEST_CMAKE_OPTIONS                            \
      -DCMAKE_BUILD_TYPE=Debug                          \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpiwrapper"
cmake --build build
cmake --install build
cd "$path"
        
# Test MPIwrapper
rm -rf "$path/runtests"
mkdir "$path/runtests"
cd "$path/runtests"
cat >runtests.sh <<EOF
#!/bin/bash

echo "Starting batch script"

set -euxo pipefail
cd "$path/local/mpitest"
module switch PrgEnv-cray PrgEnv-gnu
module switch gcc gcc/8.2.0
module load $MPITEST_MODULES
module list
env | grep '^PBS_' | sort

$MPITEST_SET_ENVVARS

export MPITRAMPOLINE_VERBOSE=1
export MPITRAMPOLINE_MPIEXEC="$path/local/mpiwrapper/bin/mpiwrapperexec"
export MPITRAMPOLINE_LIB="$path/local/mpiwrapper/lib/libmpiwrapper.so"
export MPITRAMPOLINE_DLOPEN_MODE=dlopen
# export MPITRAMPOLINE_DLOPEN_BINDING=now

for exe in                                              \
    "$path/local/mpitest/bin/mpi-test-c"                \
    "$path/local/mpitest/bin/mpi-test-cxx"              \
    "$path/local/mpitest/bin/mpi-test-mpif-f"           \
    "$path/local/mpitest/bin/mpi-test-mpif-f90"         \
    "$path/local/mpitest/bin/mpi-test-mpi-f90"          \
    "$path/local/mpitest/bin/mpi-test-mpi_f08-f90";
do
    echo "Starting \$exe..."
    aprun -n 4 -N 2 $MPITEST_MPIEXEC_OPTIONS "\$exe"
    echo "Finished \$exe."
done

echo "Batch script done."
EOF
chmod a+x runtests.sh
:> runtests.out
tail -F runtests.out &
tail_pid=$!
qsub                                            \
    -A bbel                                     \
    -j oe                                       \
    -l nodes=2:ppn=2:xe                         \
    -l walltime=0:10:0                          \
    -o runtests.out                             \
    runtests.sh                                 \
    >jobid
while qstat $(cat jobid) >/dev/null 2>&1; do sleep 60; done
kill $tail_pid
cd "$path"

echo "All tests completed successfully."
