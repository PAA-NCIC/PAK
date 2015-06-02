#!/bin/bash
source /home/lyl/.bashrc
export PATH=/home/lyl/tools/tau2.23_icpc_pdt_papi/x86_64/bin:$PATH


export TAU_MAKEFILE=/home/lyl/tools/tau2.23_icpc_pdt_papi/x86_64/lib/Makefile.tau-icpc-papi-pdt
export TAU_THROTTLE=0

i=1
for f in `env |grep ENABLE_ | grep TRUE`
do
    FNAME=${f#ENABLE_}
    FNAME=${FNAME%%=*}
    export COUNTER${i}=$FNAME
    let i+=1
done




icpc_flag=$icpc_flag
icpc_flag=$icpc_flag
icpc_flag=$icpc_flag
icpc_flag=$icpc_flag
icpc_flag=$icpc_flag



#CC=icc
CC=tau_cxx.sh
rm MULTI__P* -rf
$CC $icpc_flag -c  -vec-report2  $1 -o mid.o  2>/dev/null 1>/dev/null
$CC $icpc_flag mid.o main.cpp  -o myexe 2>/dev/null 1>/dev/null

./myexe 2>/dev/null 1>/dev/null


Rscript $(cd "$(dirname "$0")"; pwd)/outputformat.R

rm *.o
rm myexe



