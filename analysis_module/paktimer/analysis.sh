#!/bin/bash
#export ENABLE_PAKTIME=TRUE
TIMEENABLE=`env |grep ENABLE_PAKTIME | grep TRUE`
if [ $TIMEENABLE = "ENABLE_PAKTIME=TRUE" ];then   
    $(cd "$(dirname "$0")"; pwd)/paktimer $1 1>/dev/null 2>/dev/null
    time=`cat temp.time`
    rm temp.time result.xml
    echo "<features>  
    <feature>
    <name>time</name>
    <value>"$time"</value>
    </feature> 
    </features>">>result.xml 
    echo "result.xml"
fi




