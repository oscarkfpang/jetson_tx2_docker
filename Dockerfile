FROM dustynv/ros:noetic-ros-base-l4t-r32.7.1

#
# setup environment
#
ENV DEBIAN_FRONTEND=noninteractive
ARG HDF5_DIR="/usr/lib/aarch64-linux-gnu/hdf5/serial/"
ARG MAKEFLAGS=-j$(nproc)

RUN printenv

#
# install prerequisites - https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html#prereqs
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
          python3-pip \
		  python3-dev \
		  gfortran \
		  build-essential \
		  liblapack-dev \ 
		  libblas-dev \
		  libhdf5-serial-dev \
		  hdf5-tools \
		  libhdf5-dev \
		  zlib1g-dev \
		  zip \
		  unzip \
		  libjpeg8-dev \
		  autoconf \ 
		  automake \
		  libtool \
		  curl \
		  make \
		  g++ \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN pip3 install -U pip testresources setuptools==49.6.0 

RUN pip3 install --no-cache-dir setuptools Cython wheel

RUN pip3 install -U pip testresources setuptools==49.6.0 

#
# build protobuf using cpp implementation
# https://jkjung-avt.github.io/tf-trt-revisited/
#
ARG PROTOBUF_VERSION=3.19.4
ARG PROTOBUF_URL=https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}
ARG PROTOBUF_DIR=protobuf-python-${PROTOBUF_VERSION}
ARG PROTOC_DIR=protoc-${PROTOBUF_VERSION}-linux-aarch_64
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

RUN cd /tmp && \
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${PROTOBUF_URL}/$PROTOBUF_DIR.zip && \
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${PROTOBUF_URL}/$PROTOC_DIR.zip && \
    unzip ${PROTOBUF_DIR}.zip -d ${PROTOBUF_DIR} && \
    unzip ${PROTOC_DIR}.zip -d ${PROTOC_DIR} && \
    cp ${PROTOC_DIR}/bin/protoc /usr/local/bin/protoc && \
    cd ${PROTOBUF_DIR}/protobuf-${PROTOBUF_VERSION} && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make check -j4 && \
    make install && \
    ldconfig && \
    cd python && \
    python3 setup.py build --cpp_implementation && \
    python3 setup.py test --cpp_implementation && \
    python3 setup.py bdist_wheel --cpp_implementation && \
    cp dist/*.whl /opt && \
    pip3 install dist/*.whl && \
    cd ../../../ && \
    rm ${PROTOBUF_DIR}.zip && \
    rm ${PROTOC_DIR}.zip && \
    rm -rf ${PROTOBUF_DIR} && \
    rm -rf ${PROTOC_DIR}

RUN pip3 show protobuf && \
    protoc --version


#
# install Python TF dependencies
#
#RUN pip3 install --no-cache-dir --verbose numpy
RUN pip3 install -U --no-deps numpy==1.19.4
RUN H5PY_SETUP_REQUIRES=0 pip3 install --no-cache-dir --verbose h5py==3.1.0
RUN pip3 install --no-cache-dir --verbose future==0.18.2 mock==3.0.5 keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0 futures pybind11 pkgconfig
RUN env H5PY_SETUP_REQUIRES=0 pip3 install -U h5py==3.1.0


#
# TensorFlow 
#
ARG TENSORFLOW_URL=https://nvidia.box.com/shared/static/jfbpcioxcb3d3d3wrm1dbtom5aqq5azq.whl
ARG TENSORFLOW_WHL=tensorflow-2.5.0+nv21.7-cp36-cp36m-linux_aarch64.whl

RUN wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${TENSORFLOW_URL} -O ${TENSORFLOW_WHL} && \
    pip3 install --no-cache-dir --verbose ${TENSORFLOW_WHL} && \
    rm ${TENSORFLOW_WHL}


# 
# PyCUDA
#
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
RUN echo "$PATH" && echo "$LD_LIBRARY_PATH"

RUN pip3 install --no-cache-dir --verbose pycuda six


