FROM 0x01be/yosys as yosys
FROM 0x01be/iverilog as iverilog

FROM 0x01be/fault:build as build

FROM 0x01be/base

COPY --from=yosys /opt/yosys/ /opt/yosys/
COPY --from=iverilog /opt/iverilog/ /opt/iverilog/
COPY --from=build /opt/fault/ /opt/fault/

ENV PATH=${PATH}:/opt/yosys/bin:/opt/iverilog/bin:/opt/fault/bin \
    PYTHONPATH=/usr/lib/python3.8/site-packages:/opt/fault/lib/python3.8/site-packages
RUN apk add --no-cache --virtual fault-runtime-dependencies \
    libstdc++
 
