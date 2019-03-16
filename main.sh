#!/bin/bash

##############################
##      ENV SETTING         ##
##############################
data_from="./target_record.txt"
data_to="./result.txt"
LOGFILE="./log/$(date '+%Y-%m-%d')_auto-resolve.log"

##############################
##      FUNC SETTING        ##
##############################
function LOGGING() {
  echo -e "$(date '+%Y-%m-%d_%H:%M:%S') $@" >> ${LOGFILE}
}

##############################
##      CLEAN UP            ##
##############################
if [ -f "${data_to}" ]; then
    `rm ${data_to}`
    `touch ${data_to}`
fi

##############################
##      MAIN PROCESS        ##
##############################
LOGGING "MAIN PROCESS START"
while read name
do
    LOGGING "READ FQDN[${name}] FROM target_record"
    
    # GET AUTHORITATIVE NAME SERVER
    # DELETE HOSTNAME
    ns=`echo ${name} | sed -e 's/^[a-zA-Z_0-9-]*\.//'`
    ns=`dig ${ns} NS +short | head -n 1 | sed -e 's/\.$//'`

    # CHECK AUTHORITATIVE NAME SERVER
    if [ -z "${ns}" ]; then
    # DELETE NETWORK NAME AND RETRY GET AUTHORITATIVE NAME SERVER
        ns=`echo ${name} |sed -e 's/^[a-zA-Z_0-9-]*\.//' | sed -e 's/^[a-zA-Z_0-9-]*\.//'`
        ns=`dig ${ns} NS +short | head -n 1 | sed -e 's/\.$//'`
    fi
    LOGGING "${name}'s AUTHORITATIVE NAME SERVER is ${ns}"

    # GET FQDN's IP ADDRESS
    result=`dig @${ns} ${name} +short`
    LOGGING "${name}'s IPADDRESS is ${result}"

    # OUTPUT FOR FILE
    if [ -n "${result}" ]; then
        if [ -z "${result}" ]; then
            :
        else
            #echo "${name},${result}" >> ${data_to}
            echo "${result}" >> ${data_to}
        fi
    else
        #echo "${name},N/A" >> ${data_to}
        :
    fi
    LOGGING "OUTPUT DONE"
done < ${data_from}

LOGGING "MAIN PROCESS END"