#!/bin/bash

# Test MPItrampoline on Niagara, a Compute Canada HPC system
# $ rsync -P test-niagara.sh niagara.computecanada.ca:

set -euxo pipefail

path="$SCRATCH/test-mpitrampoline"
rm -rf "$path"
mkdir "$path"
cd "$path"
mkdir "$path/local"

module load cmake
module load python/3.8.5

(
# Prepare
module load gcc/9.4.0

# Install MPItrampoline
rm -rf "$path/MPItrampoline"
git clone https://github.com/eschnett/MPItrampoline
cd "$path/MPItrampoline"
cmake -S . -B build                                             \
      -DCMAKE_BUILD_TYPE=Debug                                  \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitrampoline"
cmake --build build
cmake --install build
cd "$path"

# Install MPItest
rm -rf "$path/MPItest"
git clone https://github.com/eschnett/MPItest
cd "$path/MPItest"
cmake -S . -B build                                                     \
      -DMPIEXEC_EXECUTABLE="$path/local/mpitrampoline/bin/mpiexec"      \
      -DCMAKE_BUILD_TYPE=Debug                                          \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitest"
cmake --build build
cmake --install build
cd "$path"
)

# Install MPIwrapper
case openmpi/4.1.1 in

    openmpi/4.1.1)
        MPITEST_MODULES='gcc/9.4.0 openmpi/4.1.1'
        MPITEST_CMAKE_OPTIONS='-DMPIEXEC_EXECUTABLE=/scinet/niagara/software/2019b/opt/gcc-9.4.0/openmpi/4.1.1/bin/mpiexec'
        MPITEST_SET_ENVVARS='
            export MPITRAMPOLINE_DLOPEN_MODE=dlopen
            export OMPI_MCA_btl_base_verbose=100
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
    "$path/local/mpitrampoline/bin/mpiexec"     \
        -n "\$SLURM_NTASKS"                     \
        $MPITEST_MPIEXEC_OPTIONS                \
        "\$exe"
    echo "Finished \$exe."
done

echo "Batch script done."
EOF
chmod a+x runtests.sh
: >runtests.out
tail -f runtests.out &
tail_pid=$!
sbatch                                          \
    --nodes=2                                   \
    --open-mode=append                          \
    --output=runtests.out                       \
    --ntasks-per-node=2                         \
    --time=0:30:0                               \
    --wait                                      \
    runtests.sh
sleep 3
kill $tail_pid
cd "$path"

echo "All tests completed successfully."
