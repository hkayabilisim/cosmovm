FROM debian

WORKDIR /tmp

RUN apt-get update && apt-get install -y wget gcc g++ gfortran make apt-utils automake
RUN wget http://www.mpich.org/static/downloads/1.5rc3/mpich2-1.5rc3.tar.gz && tar zxvf mpich2-1.5rc3.tar.gz
WORKDIR /tmp/mpich2-1.5rc3
RUN ./configure --prefix=/usr/local && make && make install

WORKDIR /tmp
RUN wget http://www.fftw.org/fftw-2.1.5.tar.gz && tar zxvf fftw-2.1.5.tar.gz
WORKDIR /tmp/fftw-2.1.5
RUN ./configure --enable-mpi --enable-float --enable-type-prefix --prefix=/usr/local 
RUN make && make install && make clean
RUN ./configure --enable-mpi --enable-type-prefix --prefix=/usr/local 
RUN make && make install 

WORKDIR /tmp
RUN apt-get install -y git
RUN git clone https://charm.cs.illinois.edu/gerrit/charm
WORKDIR /tmp/charm
RUN ./build ChaNGa netlrts-linux-x86_64 --with-production

WORKDIR /tmp
RUN git clone https://charm.cs.illinois.edu/gerrit/cosmo/utility.git
RUN git clone https://charm.cs.illinois.edu/gerrit/cosmo/changa.git
WORKDIR /tmp/changa
RUN ./configure && make

WORKDIR /tmp
RUN git clone https://github.com/N-BodyShop/tests.git
RUN git clone https://github.com/N-BodyShop/direct.git

WORKDIR /tmp/direct
RUN make
WORKDIR /tmp/tests/array
RUN make
WORKDIR /tmp/tests/forces/periodic
RUN sed -i 's|charmrun|/../charm/netlrts-linux-x86_64/bin/charmrun|' tstforce_ChaNGa.sh
RUN sed -i 's|ChaNGa|/../changa/ChaNGa|' tstforce_ChaNGa.sh
RUN echo "cat lambs_30K.000000.acc2" >> tstforce_ChaNGa.sh
RUN apt-get install -y vim
