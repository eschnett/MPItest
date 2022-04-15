#!/bin/bash

# Test MPItrampoline on Redshift, a macOS laptop

set -euxo pipefail

path="$HOME/test-mpitrampoline"
rm -rf "$path"
mkdir "$path"
cd "$path"
mkdir "$path/local"

# Install MPItrampoline
rm -rf "$path/MPItrampoline"
git clone https://github.com/eschnett/MPItrampoline
cd "$path/MPItrampoline"
cmake -S . -B build                                             \
      -DCMAKE_BUILD_TYPE=Debug                                  \
      -DCMAKE_C_COMPILER=/opt/local/bin/gcc                     \
      -DCMAKE_CXX_COMPILER=/opt/local/bin/g++                   \
      -DCMAKE_Fortran_COMPILER=/opt/local/bin/gfortran          \
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

# Install MPIwrapper
case MPICH in

    MPICH)
        # MPITEST_CMAKE_OPTIONS="                                                 \
        #     -DMPIEXEC_EXECUTABLE=/Users/eschnett/mpich-3.4.2/bin/mpiexec        \
        # "
        MPITEST_CMAKE_OPTIONS="                                                 \
            -DCMAKE_C_COMPILER=/Users/eschnett/mpich-3.4.2/bin/mpicc            \
            -DCMAKE_CXX_COMPILER=/Users/eschnett/mpich-3.4.2/bin/mpicxx         \
            -DCMAKE_Fortran_COMPILER=/Users/eschnett/mpich-3.4.2/bin/mpifort    \
        "
        MPITEST_SET_ENVVARS=''
        MPITEST_MPIEXEC_OPTIONS='-prepend-rank'
        ;;

    MPICH-macports)
        # Avoid the flag `-flat_namespace` in MPICH's mpicxx.
        # This makes C/C++ work, but some Fortran tests still fail.
        MPITEST_CMAKE_OPTIONS="                                                         \
            -DCMAKE_CXX_COMPILER=g++-mp-10                                              \
            -DCMAKE_Fortran_COMPILER=gfortran-mp-10                                     \
            -DMPI_CXX_ADDITIONAL_INCLUDE_DIRS=/opt/local/include/mpich-gcc10            \
            -DMPI_CXX_LIB_NAMES='mpicxx;mpi;pmpi'                                       \
            -DMPI_Fortran_ADDITIONAL_INCLUDE_DIRS=/opt/local/include/mpich-gcc10        \
            -DMPI_Fortran_LIB_NAMES='mpifort;mpi;pmpi'                                  \
            -DMPI_mpi_LIBRARY=/opt/local/lib/mpich-gcc10/libmpi.dylib                   \
            -DMPI_mpicxx_LIBRARY=/opt/local/lib/mpich-gcc10/libmpicxx.dylib             \
            -DMPI_mpifort_LIBRARY=/opt/local/lib/mpich-gcc10/libmpifort.dylib           \
            -DMPI_pmpi_LIBRARY=/opt/local/lib/mpich-gcc10/libpmpi.dylib                 \
            -DMPIEXEC_EXECUTABLE=/opt/local/bin/mpiexec-mpich-gcc10                     \
        "
        MPITEST_SET_ENVVARS=''
        MPITEST_MPIEXEC_OPTIONS='-prepend-rank'
        ;;

    OpenMPI)
        MPITEST_CMAKE_OPTIONS="                                         \
            -DMPIEXEC_EXECUTABLE=/opt/local/bin/mpiexec-openmpi-gcc11   \
            -DCMAKE_CXX_COMPILER=mpicxx-openmpi-gcc11                   \
            -DCMAKE_Fortran_COMPILER=mpifort-openmpi-gcc11              \
        "
        MPITEST_SET_ENVVARS=''
        MPITEST_MPIEXEC_OPTIONS='-tag-output'
        ;;

    *)
        echo 'Unknown MPI variant' 1>&2
        exit 1
        ;;
esac

rm -rf "$path/MPIwrapper"
git clone https://github.com/eschnett/MPIwrapper
cd "$path/MPIwrapper"
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

$MPITEST_SET_ENVVARS

export MPITRAMPOLINE_VERBOSE=1
export MPITRAMPOLINE_MPIEXEC="$path/local/mpiwrapper/bin/mpiwrapperexec"
export MPITRAMPOLINE_LIB="$path/local/mpiwrapper/lib/libmpiwrapper.so"
# export MPITRAMPOLINE_DLOPEN_MODE=dlopen
# export MPITRAMPOLINE_DLOPEN_BINDING=now

export MPITEST_COMM_WORLD_SIZE=4

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
        -n 4                                    \
        $MPITEST_MPIEXEC_OPTIONS                \
        "\$exe"
    echo "Finished \$exe."
done

echo "Batch script done."
EOF
chmod a+x runtests.sh
./runtests.sh 2>&1 | tee runtests.out
cd "$path"

echo "All tests completed successfully."
