#!/bin/bash

# Test MPItrampoline on Symmetry, Perimeter's HPC system
# $ rsync -P test-symmetry.sh symmetry:

set -euxo pipefail

path="$HOME/test-mpitrampoline"
rm -rf "$path"
mkdir "$path"
cd "$path"
mkdir "$path/local"

# Prepare
module load cmake

(
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
      -DCMAKE_Fortran_FLAGS=-fcray-pointer                              \
      -DCMAKE_INSTALL_PREFIX="$path/local/mpitest"
cmake --build build
cmake --install build
cd "$path"
)

# Install MPIwrapper

# Ubuntu OpenMPI 2.1.1
# -DCMAKE_CXX_COMPILER=/usr/bin/mpic++
# -DCMAKE_Fortran_COMPILER=/usr/bin/mpifort

# Intel MPI 2021.1.1
# module load mpi
# -DCMAKE_CXX_COMPILER=/cm/shared/apps/intel/mpi/2021.1.1/bin/mpicxx
# -DCMAKE_Fortran_COMPILER=/cm/shared/apps/intel/mpi/2021.1.1/bin/mpifc

case OpenMPI in

    MPICH)
        # ES: I don't know whether this uses Infiniband or not.
        MPITEST_MODULES='mpich/gcc-9/3.3.2'
        MPITEST_CMAKE_OPTIONS='-DMPIEXEC_EXECUTABLE=/cm/shared/apps/mpich/gcc-9/3.3.2/bin/mpiexec'
        MPITEST_SET_ENVVARS=''
        MPITEST_MPIEXEC_OPTIONS='-verbose -prepend-rank'
        ;;

    MVAPICH2)
        # DOES NOT WORK YET
        # Findings:
        # - MPITRAMPOLINE_DLOPEN_MODE=dlmopen doesn't work with
        #   multiple processes; liblzma.so.2 is not found
        # - MPITRAMPOLINE_DLOPEN_MODE=dlopen leads to a segfault in
        #   MPI_Init
        MPITEST_MODULES='mvapich2/gcc/64/2.3.2'
        MPITEST_CMAKE_OPTIONS='-DMPIEXEC_EXECUTABLE=/cm/shared/apps/mvapich2/gcc/64/2.3.2/bin/mpiexec'
        MPITEST_SET_ENVVARS='
            export MPITRAMPOLINE_DLOPEN_MODE=dlopen
        '
        MPITEST_MPIEXEC_OPTIONS='-verbose -prepend-rank'
        ;;

    OpenMPI)
        # The output states that "send" uses the "openib" BTL. This is good.
        MPITEST_MODULES='openmpi/gcc-9/64/4.1.0'
        MPITEST_CMAKE_OPTIONS="                                                         \
            -DCMAKE_CXX_COMPILER=/cm/shared/apps/openmpi/gcc-9/64/4.1.0/bin/mpic++      \
            -DCMAKE_Fortran_COMPILER=/cm/shared/apps/openmpi/gcc-9/64/4.1.0/bin/mpifort \
            -DMPIEXEC_EXECUTABLE=/cm/shared/apps/openmpi/gcc-9/64/4.1.0/bin/mpiexec     \
        "
        MPITEST_SET_ENVVARS='
            export OMPI_MCA_btl_openib_allow_ib=true
        '
        MPITEST_MPIEXEC_OPTIONS="               \
            -display-allocation                 \
            -display-map                        \
            -report-bindings                    \
            -tag-output                         \
            -mca btl self,vader,openib          \
            -mca btl_base_verbose 100           \
        "

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
module load slurm
cat >runtests.sh <<EOF
#!/bin/bash

# # All but the first scripts exit immediately
# if [ \$SLURM_PROCID -ne 0 ]; then
#    exit
# fi

echo "Starting batch script"

set -euxo pipefail
cd "$path/local/mpitest"
module load $MPITEST_MODULES
env | grep ^SLURM_ | sort

$MPITEST_SET_ENVVARS

export MPITRAMPOLINE_VERBOSE=1
export MPITRAMPOLINE_MPIEXEC="$path/local/mpiwrapper/bin/mpiwrapperexec"
export MPITRAMPOLINE_LIB="$path/local/mpiwrapper/lib/libmpiwrapper.so"

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
    --partition=debugq                          \
    --tasks-per-node=2                          \
    --time=1:0:0                                \
    --wait                                      \
    runtests.sh
sleep 3
kill $tail_pid
cd "$path"

echo "All tests completed successfully."
