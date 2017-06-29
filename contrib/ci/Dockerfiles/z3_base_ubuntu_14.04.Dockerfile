FROM ubuntu:14.04

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        binutils \
        clang-3.9 \
        cmake \
        doxygen \
        default-jdk \
        gcc-multilib \
        gcc-4.8-multilib \
        git \
        g++-multilib \
        g++-4.8-multilib \
        libasan0 \
        lib32asan0 \
        libgmp-dev \
        libgomp1 \
        lib32gomp1 \
        make \
        mono-devel \
        ninja-build \
        python3 \
        python3-setuptools \
        python2.7 \
        python-setuptools

# Create `user` user for container with password `user`.  and give it
# password-less sudo access
RUN useradd -m user && \
    echo user:user | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'user  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers
USER user
WORKDIR /home/user

ADD / /home/user/z3_src


# Specify defaults. This can be changed when invoking
# `docker build`.
ARG ASAN_BUILD=0
ARG BUILD_DOCS=1
ARG CC=gcc
ARG CXX=g++
ARG DOTNET_BINDINGS=1
ARG JAVA_BINDINGS=1
ARG NO_SUPPRESS_OUTPUT=0
ARG PYTHON_BINDINGS=1
ARG PYTHON_EXECUTABLE=/usr/bin/python2.7
ARG RUN_SYSTEM_TESTS=1
ARG RUN_UNIT_TESTS=1
ARG TARGET_ARCH=x86_64
ARG UBSAN_BUILD=0
ARG USE_LIBGMP=0
ARG USE_LTO=0
ARG USE_OPENMP=1
ARG Z3_BUILD_TYPE=RelWithDebInfo
ARG Z3_CMAKE_GENERATOR=Ninja
ARG Z3_INSTALL_PREFIX=/usr
# Blank default indicates use latest.
ARG Z3_SYSTEM_TEST_GIT_REVISION
ARG Z3_VERBOSE_BUILD_OUTPUT=0
ARG TEST_INSTALL=1

ENV \
  ASAN_BUILD=${ASAN_BUILD} \
  BUILD_DOCS=${BUILD_DOCS} \
  CC=${CC} \
  CXX=${CXX} \
  DOTNET_BINDINGS=${DOTNET_BINDINGS} \
  JAVA_BINDINGS=${JAVA_BINDINGS} \
  NO_SUPPRESS_OUTPUT=${NO_SUPPRESS_OUTPUT} \
  PYTHON_BINDINGS=${PYTHON_BINDINGS} \
  PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} \
  RUN_SYSTEM_TESTS=${RUN_SYSTEM_TESTS} \
  RUN_UNIT_TESTS=${RUN_UNIT_TESTS} \
  TARGET_ARCH=${TARGET_ARCH} \
  TEST_INSTALL=${TEST_INSTALL} \
  UBSAN_BUILD=${UBSAN_BUILD} \
  USE_LIBGMP=${USE_LIBGMP} \
  USE_LTO=${USE_LTO} \
  USE_OPENMP=${USE_OPENMP} \
  Z3_SRC_DIR=/home/user/z3_src \
  Z3_BUILD_DIR=/home/user/z3_build \
  Z3_CMAKE_GENERATOR=${Z3_CMAKE_GENERATOR} \
  Z3_VERBOSE_BUILD_OUTPUT=${Z3_VERBOSE_BUILD_OUTPUT} \
  Z3_SYSTEM_TEST_DIR=/home/user/z3_system_test \
  Z3_SYSTEM_TEST_GIT_REVISION=${Z3_SYSTEM_TEST_GIT_REVISION} \
  Z3_INSTALL_PREFIX=${Z3_INSTALL_PREFIX}

# Build Z3
RUN z3_src/contrib/ci/scripts/build_z3_cmake.sh

# Test building docs
RUN z3_src/contrib/ci/scripts/test_z3_docs.sh

# Test examples
RUN z3_src/contrib/ci/scripts/test_z3_examples_cmake.sh

# Run unit tests
RUN z3_src/contrib/ci/scripts/test_z3_unit_tests_cmake.sh

# Run system tests
RUN z3_src/contrib/ci/scripts/test_z3_system_tests.sh

# Test install
RUN z3_src/contrib/ci/scripts/test_z3_install_cmake.sh
