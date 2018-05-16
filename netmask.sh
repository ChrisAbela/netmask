#!/bin/bash
# netmask.sh - A BASH script to determine the range of IP address of a nework.

# Copyright 2018 Chris Abela <kristofru@gmail.com>, Malta
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Read the network address in the form of:
# 192.268.1.0/24
#
# So I expect a four . separated fields
# The first fields are numeric ranging from 0 to 255
# The last field is a numerical value, also ranging from 0 to 255,
# then a / and a value from 0 to 32

validate() {
  # Check that we only have numbers
  if echo "$1" | grep  -q '^[[:digit:]]*$' ; then
    #$1 is a number
    if [ "$1" -gt 255 -o "$1" -lt 0 ]; then
      # $1 is also less than or equal to 255 and greater than or equal to 0
      echo "$1 is not a valid integer"
      exit 1
    fi
  else echo "$1 does not look like a integer"
    exit 1
  fi
}

noctet() {
  echo "Octet $1 was not found"
  exit 1
}

getoctet() {
  L4=$(( $1/16777216 ))
  L3=$(( $1/65536 - $L4*256))
  L2=$(( $1/256 - $L3*256 - $L4*65536 ))
  L1=$(( $1 - $L2*256 - $L3*65536 - $L4*16777216 ))
}

# Let this script take an argument, or solicit an IPP
if [ "$#" == 0 ]; then 
  read -p "Enter the IP address: "
  IP="$REPLY"
else IP="$1"
fi

# Read the IP octets
F1=$( echo "$IP" | awk -F . '{print $1}' )
F2=$( echo "$IP" | awk -F . '{print $2}' )
F3=$( echo "$IP" | awk -F . '{print $3}' )
F4=$( echo "$IP" | awk -F . '{print $4}' )
F4=$( echo "$F4" | sed 's/\/.*$//g' )
# Read the netmask
NETMASK=$( echo "$IP" | awk -F / '{print $2}')

[ -n "$F1" ] && validate $F1 || noctet 1
[ -n "$F2" ] && validate $F2 || noctet 2
[ -n "$F3" ] && validate $F3 || noctet 3
[ -n "$F4" ] && validate $F4 || noctet 4
[ -z "$NETMASK" ] && echo "Netmask was not parsed well" && exit 1

if echo "$NETMASK" | grep  -q '^[[:digit:]]*$'; then
  #NETMASK is a number
  if [ "$NETMASK" -gt 32 -o "$NETMASK" -lt 0 ]; then
    # NETMASK is also less than or equal to 32 and greater than or equal to 0
    echo "$NETMASK is not a valid integer"
    exit 1
  fi
else echo "$NETMASK is not a valid integer"
  exit 1
fi

# Convert the IP address to a single integer
IP=$(( $F4 + $F3*256 + $F2*65536 + $F1*16777216 ))
N=$( echo "2^(32-$NETMASK)" | bc )
LOWER=$(( ($IP/N)*N))
UPPER=$(( LOWER+N-1 ))
# Convert the LOWER and HIGHEST IP to octets
getoctet $LOWER
echo "Lowest IP: ${L4}.${L3}.${L2}.${L1}"
getoctet $UPPER
echo "Highest IP: ${L4}.${L3}.${L2}.${L1}"
