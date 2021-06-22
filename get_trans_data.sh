#!/bin/bash

Usage() {
 echo -e "\e[0;31mcp_st2_st1: mandatory option is missing\e[0m"
 tput bold
 echo -e "\e[0;34mcp_st2_st1: -y <year> -m <month>\e[0m"
 tput sgr0
 echo "where:"
 echo "Year in YYYY format and month in MM format"
 exit 1
}
while getopts y:m: arg
do
  case $arg in
    y) year=$OPTARG ;;
    m) month=$OPTARG ;;
esac
done
rm -f *.tar* xfer* 2>/dev/null
if [ ! -z $year ] && [ ! -z $month ];then
 cp /Cloud/apps/SecureTransport/var/db/hist/logs/xferlog.${year}${month}* .
 echo $2,$4 > duration.txt
 tar --transform='flags=r;s|xferlog|xferlog_1|' -czf file_s2.tar.gz xfer*
 cp file_s2.tar.gz duration.txt /Cloud/data/transaction_data
else
 echo -e "\e[0;31m Invalid Argument given\e[0m"
 Usage
fi

