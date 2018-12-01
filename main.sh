#!/bin/bash
data_from="./target_record"
data_to="./result"
if [ -f "${data_to}" ]; then
    `rm ${data_to}`
    `touch ${data_to}`
fi
while read name
do
    ns=`echo ${name} | sed -e 's/^[a-zA-Z_0-9-]*\.//'`
    ns=`dig ${ns} NS +short | head -n 1 | sed -e 's/\.$//'`
    if [ -z "${ns}" ]; then
        ns=`echo ${name} |sed -e 's/^[a-zA-Z_0-9-]*\.//' | sed -e 's/^[a-zA-Z_0-9-]*\.//'`
        ns=`dig ${ns} NS +short | head -n 1 | sed -e 's/\.$//'`
    fi
    result=`dig @${ns} ${name} +short`
    if [ -n "${result}" ]; then
        echo "${name},${result}" >> ${data_to}
    else
        echo "${name},N/A" >> ${data_to}
    fi
#    `sleep 1`
done < ${data_from}
