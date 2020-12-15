FROM 0x01be/yosys as yosys
FROM 0x01be/iverilog as iverilog

FROM 0x01be/swift as build

COPY --from=yosys /opt/yosys/ /opt/yosys/
COPY --from=iverilog /opt/iverilog/ /opt/iverilog/

WORKDIR /fault

ENV PATH=${PATH}:/opt/yosys/bin:/opt/iverilog/bin:/opt/fault/bin \
    PYTHONPATH=/usr/lib/python3.8/site-packages:/opt/fault/lib/python3.8/site-packages \
    PYVERILOG_IVERILOG=/opt/iverilog/bin/iverilog \
    FAULT_IVERILOG=/opt/iverilog/bin/iverilog \
    FAULT_VVP=/opt/iverilog/bin/vvp \
    FAULT_YOSYS=/opt/yosys/bin/yosys \
    FAULT_IVL_BASE=/opt/iverilog/lib/ivl \
    REVISION=master
RUN apk add --no-cache --virtual fault-build-dependencies \
    git \
    build-base \
    tar \
    curl \
    flex \
    bison \
    readline-dev \
    ncurses-dev \
    python3-dev \
    py3-pip &&\
    pip install -U pip &&\
    pip install --prefix=/opt/fault jinja2 https://github.com/PyHDI/Pyverilog/archive/develop.zip &&\
    git clone --depth 1 --branch ${REVISION} https://github.com/Cloud-V/Fault.git /fault  &&\
    git clone --depth 1 https://github.com/hsluoyz/Atalanta.git /atalanta &&\
    cd /atalanta &&\
    make &&\
    mkdir -p /opt/fault/bin &&\
    cp /atalanta/atalanta /opt/fault/bin/ &&\
    cd / &&\
    curl -sL http://tiger.ee.nctu.edu.tw/course/Testing2018/assignments/hw0/podem.tgz  | tar -xz &&\
    cd /podem &&\
    make &&\
    cp /podem/atpg /opt/fault/bin/ &&\
    chmod +x /opt/fault/bin/* &&\
    ln -s ${FAULT_IVL_BASE} /usr/local/lib/ivl

RUN INSTALL_DIR=/opt/fault swift install.swift
 
