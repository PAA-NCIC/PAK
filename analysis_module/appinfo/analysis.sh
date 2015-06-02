#!/bin/bash
 
source /home/lyl/.bashrc
Rscript $(cd "$(dirname "$0")"; pwd)/appinfo.R $1 



