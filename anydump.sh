#!/bin/bash
#===================================================================================
#
# FILE: anydump.sh
# USAGE: anydump.sh [-i interface] [tcpdump-parameters]
# DESCRIPTION: tcpdump on any interface and add the prefix '<Interface>: ' in front of the dump data.
# OPTIONS: same as tcpdump
# REQUIREMENTS: tcpdump, sed, ip, kill, awk, grep, posix regex matching
# BUGS:  ---
#        - 1.3 Use ip utility and fixed length prefix
# FIXED: ---
#        - 1.0 The parameter -w would not work without -i parameter as multiple tcpdumps are started.
#        - 1.1 VLAN's would not be shown if a single interface was dumped.
# NOTES: ---
#        - 1.2 git initial
# AUTHOR: Sebastian Haas
# COMPANY: pharma mall
# VERSION: 1.3
# CREATED: 16.09.2014
# REVISION: 26.09.2022
#
#===================================================================================

# When this exits, exit all background processes:
trap 'kill $(jobs -p) &> /dev/null && sleep 0.2 && echo ' EXIT
# Create one tcpdump output per interface and add an identifier to the beginning of each line:
if [[ $@ =~ -i[[:space:]]?[^[:space:]]+ ]]; then
    tcpdump -l $@ | sed 's/^/'"${BASH_REMATCH[0]:2}"': /' &
else
    L=0
    INTERFACES=$(ip -br a | awk '/UP/{gsub(/@.+/,"",$1);print $1}')
    for i in ${INTERFACES};do [ ${#i} -gt ${L} ] && L=${#i};done
    for interface in ${INTERFACES};do
       prefix=$(printf "%-${L}s" ${interface})
       tcpdump -l -i ${interface} -nn $@ | sed 's/^/'"${prefix}"': /' &
    done
fi
# wait .. until CTRL+C
wait
