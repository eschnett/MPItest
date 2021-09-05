#!/bin/bash

# Test MPItrampoline on Summit, an HPC system at ORNL
# $ rsync -P test-summit.sh summit.olcf.ornl.gov:

set -euxo pipefail

path="$HOME/test-mpitrampoline"
rm -rf "$path"
mkdir "$path"
cd "$path"
mkdir "$path/local"

# Prepare
module load cmake

(
# Prepare
module unload spectrum-mpi
module load gcc/11.1.0

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
case spectrum-mpi/10.4.0.3-20210112 in

    spectrum-mpi/10.4.0.3-20210112)
        MPITEST_MODULES='spectrum-mpi/10.4.0.3-20210112'
        MPITEST_CMAKE_OPTIONS='-DMPIEXEC_EXECUTABLE=/sw/summit/spack-envs/base/opt/linux-rhel8-ppc64le/xl-16.1.1-10/spectrum-mpi-10.4.0.3-20210112-v7qymniwgi6mtxqsjd7p5jxinxzdkhn3/bin/mpiexec'
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
module load $MPITEST_MODULES
env | grep '^LSB\?_' | sort

$MPITEST_SET_ENVVARS

export MPITRAMPOLINE_VERBOSE=1
export MPITRAMPOLINE_MPIEXEC="$path/local/mpiwrapper/bin/mpiwrapperexec"
export MPITRAMPOLINE_LIB="$path/local/mpiwrapper/lib/libmpiwrapper.so"
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
    jsrun -n4 -a1 -c1 $MPITEST_MPIEXEC_OPTIONS "\$exe"
    echo "Finished \$exe."
done

echo "Batch script done."
EOF
chmod a+x runtests.sh
: >runtests.out
tail -f runtests.out &
tail_pid=$!
bsub                                            \
    -K                                          \
    -P ast154                                   \
    -W 1:00                                     \
    -alloc_flags smt1                           \
    -eo runtests.out                            \
    -nnodes 2                                   \
    -q batch                                    \
    runtests.sh
sleep 3
kill $tail_pid
cd "$path"

echo "All tests completed successfully."
