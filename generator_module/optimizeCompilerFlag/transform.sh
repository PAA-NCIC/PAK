#!/bin/bash
CC=clang
#export ENABLE_COMPILERFLAG="-O3"
CFLAGENABLE=`env |grep ENABLE_COMPILERFLAG`
    FNAME=${CFLAGENABLE#ENABLE_}
    FNAME=${FNAME%%=*}
    SUFFIX=${FNAME##*_}
    FNAME=${FNAME%%_*}
    
if [ $FNAME = "COMPILERFLAG" ] ; then   
   
    CFLAG=${CFLAGENABLE#*=} 
    clang $CFLAG $1 -o $2
fi
echo $2




