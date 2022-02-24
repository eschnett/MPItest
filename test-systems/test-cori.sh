#!/bin/bash

# Test MPItrampoline on Cori, a Cray XS at NERSC
# $ rsync -P test-cori.sh cori.nersc.gov:

set -euxo pipefail

path="$HOME/test-mpitrampoline"
rm -rf "$path"
mkdir "$path"
cd "$path"
mkdir "$path/local"

(
# Prepare
module unload zlib
module unload PrgEnv-intel
module unload PrgEnv-cray
module unload PrgEnv-gnu
module unload PrgEnv-pgi
module unload craype-mic-knl
module unload craype-haswell
module unload gcc
module unload intel
module load PrgEnv-gnu/6.0.5
module load craype-haswell
module load cmake

# Install MPItrampoline
rm -rf "$path/MPItrampoline"
git clone https://github.com/eschnett/MPItrampoline
cd "$path/MPItrampoline"
cmake -S . -B build                                             \
      -DCMAKE_BUILD_TYPE=Debug                                  \
      -DCMAKE_C_COMPILER=gcc                                    \
      -DCMAKE_CXX_COMPILER=g++                                  \
      -DCMAKE_Fortran_COMPILER=gfortran                         \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitrampoline"
cmake --build build
cmake --install build
cd "$path"

# Install MPItest
rm -rf "$path/MPItest"
git clone https://github.com/eschnett/MPItest
cd "$path/MPItest"
# export MPITRAMPOLINE_FCFLAGS='-J/global/homes/s/schnette/test-mpitrampoline/local/mpitrampoline/include'
# -DMPIEXEC_EXECUTABLE="$path/local/mpitrampoline/bin/mpiexec"
cmake -S . -B build                                                     \
      -DCMAKE_BUILD_TYPE=Debug                                          \
      -DCMAKE_C_COMPILER="$path/local/mpitrampoline/bin/mpicc"          \
      -DCMAKE_CXX_COMPILER="$path/local/mpitrampoline/bin/mpicxx"       \
      -DCMAKE_Fortran_COMPILER="$path/local/mpitrampoline/bin/mpifort"  \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitest"
cmake --build build
cmake --install build
cd "$path"
)

# Install MPIwrapper
case PrgEnv-gnu in

    PrgEnv-gnu)
        MPITEST_MODULES='PrgEnv-gnu/6.0.5 craype-haswell cmake'
        MPITEST_CMAKE_OPTIONS='
            -DCMAKE_C_COMPILER=cc
            -DCMAKE_CXX_COMPILER=CC
            -DCMAKE_Fortran_COMPILER=ftn
        '
        MPITEST_SET_ENVVARS='
            export MPITRAMPOLINE_DLOPEN_MODE=dlopen
        '
        MPITEST_MPIEXEC_OPTIONS=''
        ;;

    PrgEnv-intel)
        MPITEST_MODULES='PrgEnv-intel/6.0.5 craype-haswell cmake'
        MPITEST_CMAKE_OPTIONS=''
        MPITEST_SET_ENVVARS='
            export MPITRAMPOLINE_DLOPEN_MODE=dlopen
        '
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
module unload zlib
module unload PrgEnv-intel
module unload PrgEnv-cray
module unload PrgEnv-gnu
module unload PrgEnv-pgi
module unload craype-mic-knl
module unload craype-haswell
module unload gcc
module unload intel
module load $MPITEST_MODULES
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
module unload zlib
module unload PrgEnv-intel
module unload PrgEnv-cray
module unload PrgEnv-gnu
module unload PrgEnv-pgi
module unload craype-mic-knl
module unload craype-haswell
module unload gcc
module unload intel
module load $MPITEST_MODULES
env | grep ^SLURM_ | sort

$MPITEST_SET_ENVVARS

export MPITRAMPOLINE_VERBOSE=1
export MPITRAMPOLINE_MPIEXEC="$path/local/mpiwrapper/bin/mpiwrapperexec"
export MPITRAMPOLINE_LIB="$path/local/mpiwrapper/lib64/libmpiwrapper.so"
# export MPITRAMPOLINE_DLOPEN_MODE=dlopen
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
    srun $MPITEST_MPIEXEC_OPTIONS "\$exe"
    echo "Finished \$exe."
done

echo "Batch script done."
EOF
chmod a+x runtests.sh
: >runtests.out
tail -f runtests.out &
tail_pid=$!
sbatch                                          \
    --constraint=haswell                        \
    --nodes=2                                   \
    --ntasks=4                                  \
    --output=runtests.out                       \
    --partition=regular                         \
    --time=0:30:0                               \
    --wait                                      \
    runtests.sh
sleep 3
kill $tail_pid
cd "$path"

echo "All tests completed successfully."
