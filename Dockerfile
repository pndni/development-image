FROM centos:7.6.1810

RUN yum install -y epel-release
RUN yum install -y wget file bc tar gzip libquadmath which bzip2 libgomp tcsh perl less vim zlib zlib-devel hostname Lmod
RUN yum groupinstall -y "Development Tools"
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh
RUN mkdir -p /opt/cmake
RUN /bin/bash cmake-3.14.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN rm cmake-3.14.0-Linux-x86_64.sh

# ANTs
# it doesn't look like the libraries are needed. no RPATH or
# RUNPATH used. as determined by running
# for i in `ls`; do if [ $(file $i | awk '{print $2}') == "ELF" ]; then objdump -x $i | awk -v FS='\n' -v RS='\n\n' '$1 == "Dynamic Section:" {print}' | grep -i path ; fi; done;
# in /scif/apps/ants/bin
# and the documentation doesn't say to alter LD_LIBRARY_PATH
RUN tmpdir=$(mktemp -d) && \
    pushd $tmpdir && \
    git clone --branch v2.3.1 https://github.com/ANTsX/ANTs.git ANTs_src && \
    mkdir ANTs_build && \
    pushd ANTs_build && \
    /opt/cmake/bin/cmake ../ANTs_src -DITK_BUILD_MINC_SUPPORT=ON && \
    make -j 2 && \
    popd && \
    mkdir -p /opt/ants/bin && \
    cp ANTs_src/Scripts/* /opt/ants/bin/ && \
    cp ANTs_build/bin/* /opt/ants/bin/ && \
    popd && \
    rm -rf $tmpdir

ENV PATH /opt/cmake/bin:$PATH
# MINC
RUN tmpdir=$(mktemp -d) && \
    pushd $tmpdir && \
    git clone --recursive --branch release-1.9.17 https://github.com/BIC-MNI/minc-toolkit-v2.git minc-toolkit-v2_src && \
    mkdir minc_build && \
    pushd minc_build && \
    cmake ../minc-toolkit-v2_src \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/opt/minc \
    -DMT_BUILD_ABC:BOOL=OFF \
    -DMT_BUILD_ANTS:BOOL=OFF \
    -DMT_BUILD_C3D:BOOL=OFF \
    -DMT_BUILD_ELASTIX:BOOL=OFF \
    -DMT_BUILD_IM:BOOL=OFF \
    -DMT_BUILD_ITK_TOOLS:BOOL=OFF \
    -DMT_BUILD_LITE:BOOL=OFF \
    -DMT_BUILD_OPENBLAS:BOOL=ON \
    -DMT_BUILD_QUIET:BOOL=OFF \
    -DMT_BUILD_SHARED_LIBS:BOOL=OFF \
    -DMT_BUILD_VISUAL_TOOLS:BOOL=OFF \
    -DMT_USE_OPENMP:BOOL=ON \
    -DUSE_SYSTEM_FFTW3D:BOOL=OFF \
    -DUSE_SYSTEM_FFTW3F:BOOL=OFF \
    -DUSE_SYSTEM_GLUT:BOOL=OFF \
    -DUSE_SYSTEM_GSL:BOOL=OFF \
    -DUSE_SYSTEM_HDF5:BOOL=OFF \
    -DUSE_SYSTEM_ITK:BOOL=OFF \
    -DUSE_SYSTEM_NETCDF:BOOL=OFF \
    -DUSE_SYSTEM_NIFTI:BOOL=OFF \
    -DUSE_SYSTEM_PCRE:BOOL=OFF \
    -DUSE_SYSTEM_ZLIB:BOOL=OFF \
    -DBUILD_TESTING=ON && \
    make && \
    make test && \
    make install && \
    popd && \
    rm -rf minc_build && \
    rm -rf minc-toolkit-v2_src && \
    popd

# FSL
RUN wget --output-document=/root/fslinstaller.py https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py 
RUN python /root/fslinstaller.py -p -V 6.0.1 -d /opt/fsl
RUN rm /root/fslinstaller.py

# for fsleyes
RUN yum -y install libpng12 libmng

# FreeSurfer
RUN wget --no-verbose --output-document=/root/freesurfer.tar.gz https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.1/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.1.tar.gz
RUN tar -C /opt -xzvf /root/freesurfer.tar.gz
RUN rm /root/freesurfer.tar.gz

COPY ants /etc/modulefiles/ants
COPY freesurfer /etc/modulefiles/freesurfer
COPY fsl /etc/modulefiles/fsl
COPY minc /etc/modulefiles/minc

# python and dcm2niix stuff
RUN yum install -y python36 python36-pip python36-devel libstdc++-static pigz python36-virtualenv
RUN virtualenv-3.6 /opt/pyenv

COPY pyenv /etc/modulefiles/pyenv
RUN /opt/pyenv/bin/pip install numpy==1.16.3 scipy==1.2.1 bids-validator==1.2.3 pybids==0.8.0 heudiconv==0.5.4 nibabel==2.4.0 nipype==1.1.9

# dcm2niix
RUN git clone --branch v1.0.20190410 https://github.com/rordenlab/dcm2niix.git
RUN mkdir /dcm2niix/build
RUN cd /dcm2niix/build && /opt/cmake/bin/cmake -DCMAKE_INSTALL_PREFIX=/opt/dcm2niix .. && make && make install
RUN rm -r /dcm2niix
COPY dcm2niix /etc/modulefiles/dcm2niix

# this script should be sourced to initiate lmod from inside a bash script if
# not used interactively
COPY set_up_lmod.sh /opt/set_up_lmod.sh

# make a bunch of files for potential mount points so that we don't rely on overlayFS
RUN mkdir /scratch
RUN mkdir -p /gpfs/fs0/scratch
RUN mkdir /project
RUN mkdir -p /gpfs/fs0/project
RUN mkdir -p /gpfs/fs1/home

LABEL Maintainer="Steven Tilley"
LABEL Version=2.0.0

