# https://hub.docker.com/neurons/openpose:v1
FROM nvidia/cuda:10.0-cudnn7-devel

ADD pip.conf /root/.pip/pip.conf
ADD sources.list /etc/apt/sources.list
ENV LANG=C.UTF-8

#get deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                                                    python3-dev \
                                                    python3-pip \
                                                    git g++ wget make \
                                                    libprotobuf-dev  \
                                                    protobuf-compiler \ 
                                                    libopencv-dev \
                                                    libgoogle-glog-dev \
                                                    libboost-all-dev \
                                                    libcaffe-cuda-dev \
                                                    libhdf5-dev \
                                                    libatlas-base-dev && \
    rm -rf /var/lib/apt/lists/*

#for python api
RUN pip3 install --upgrade pip && \
    pip3 install numpy opencv-python 

COPY cmake-3.16.0-Linux-x86_64.tar.gz /
RUN tar xzf /cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
    rm -rf /cmake-3.16.0-Linux-x86_64.tar.gz
    
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

#get openpose
WORKDIR /openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

# install caffe
RUN bash ./scripts/ubuntu/install_deps.sh

#build it
WORKDIR /openpose/build
RUN cmake -DBUILD_PYTHON=ON .. && make -j `nproc`
WORKDIR /openpose
