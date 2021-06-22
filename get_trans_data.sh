#!/bin/bash
#Author: Abhisek
#Requirement: This tool is required to fectch prod data and transaction count for the given year and month

Usage() {
 echo -e "\e[0;31mget_trans_data: mandatory option is missing\e[0m"
 tput bold
 echo -e "\e[0;34mget_trans_data -t <Type> -y <year> -m <month> -a <account> -h <No Arg needed>\e[0m"
 tput sgr0
 echo "Where:"
 echo "-t is used for the type of data to fetch ex:-data/transaction/both"
 echo "-y is used for the year in format 20,21,22..etc"
 echo "-m is used for the month in format 12,01,02..etc"
 echo "-a is used for the account name"
 echo "-h is used to print this info"
 exit 1
}
usr=`whoami`
if [ $usr != root ];then echo "Current user is not root, exiting";exit 0;fi
remove_tmp_file(){
rm -f xferlog* 

}
handle_signal()
{
 echo ""
 echo -n "Deleting temporary files, please wait"
 for i in `seq 1 2`; do
   sleep 0.3
   echo -n "."
   remove_tmp_file
 done
 echo ""
 kill -9 $$
 exit 1
}
customer_array ()
{

select item; do
# Check the selected menu item number
if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ];

then
echo "The selected customer is $item"
break;
else
echo "Wrong selection: Select any number from 1-$#"
fi
done
if [ "$item" == "BrightHouse" ];then
   LOG_HOME='/Cloud/apps/SecureTransport/var/db/hist/logs/'
elif [ "$item" == "GoldManSachs" ];then
   LOG_HOME='/Cloud/apps/ST/SecureTransport/var/db/hist/logs/'
elif [ "$item" == "JM Family" ];then
  echo "Work in progress"
elif [ "$item" == "'Citi Bank" ];then
  echo "Work in progress"
fi
}

file_op(){
 yr=`awk -F ',' '{print $1}' duration.txt`
 year=`expr $yr % 100`
 month=`awk -F ',' '{print $2}' duration.txt`
 cp $LOG_HOME/xferlog.${yr}${month}* .
 tar -xzf file_s2.tar.gz
 file_name=`date -d 20$year-$month-1 '+%b_%Y'`
}


client=('BrightHouse' 'GoldManSachs' 'JM Family' 'Citi Bank')
echo -e "Choose from the following partner\n"
customer_array "${client[@]}"

while getopts a:t:h arg
do
  case $arg in
    a) account=$OPTARG ;;
    t) select=$OPTARG ;;
    h) Usage ;;
    *) Usage ;;
  esac
done

trap handle_signal EXIT
#file_name=`date -d $yr-$month-1 '+%b_%Y'`
#file_name=`date -d 20$year-$month-1 '+%b_%Y'`

if [ -z $select ];then
 echo "Please select the type of data to fetch ex:-data/transaction/both"
 Usage
 exit 1
else


 if [ "XX$select" == "XXdata" ];then
  file_op
  if [ ! -z $year ] && [ ! -z $month ] && [ ! -z $account ];then
   #source ./Data_M.sh $year $month > Monthly_Data.txt 2>&1
   source ./Data.sh $account $year $month >> BHF_Detail_Report_$file_name.txt 2>&1
  elif [ ! -z $year ] && [ ! -z $month ];then
   source ./Data_M.sh $year $month >> BHF_Detail_Report_$file_name.txt 2>&1
  fi 
 elif [ "XX$select" == "XXtransaction" ];then
  file_op
  if [ ! -z $year ] && [ ! -z $month ] && [ ! -z $account ];then
   #source ./Transaction_M.sh $year $month > BHF_Detail_Report_$file_name.txt 2>&1
   source ./Transaction.sh $year $month $account >> BHF_Detail_Report_$file_name.txt 2>&1
  elif  [ ! -z $year ] && [ ! -z $month ];then
   source ./Transaction_M.sh $year $month >> BHF_Detail_Report_$file_name.txt 2>&1
  fi
 elif [ "XX$select" == "XXboth" ];then
  file_op
  if [ ! -z $year ] && [ ! -z $month ] && [ ! -z $account ];then
   source ./Data.sh $account $year $month >> BHF_Detail_Report_$file_name.txt 2>&1
   source ./Transaction.sh $year $month $account >> BHF_Detail_Report_$file_name.txt 2>&1
  elif  [ ! -z $year ] && [ ! -z $month ];then
   source ./Data_M.sh $year $month >> BHF_Detail_Report_$file_name.txt 2>&1
   source ./Transaction_M.sh $year $month >> BHF_Detail_Report_$file_name.txt 2>&1
  fi
 else
   echo -e "\e[0;31m Invalid Argument given\e[0m"
   Usage
 fi
 echo "***************Transaction Report count according to username for 2021/05 (TOP 5)***************"  >>  BHF_Detail_Report_$file_name.txt 2>&1 
 cat xferlog* | grep -v axway | grep -v SyncplicityArchAccount | rev | awk '{print $4}'|rev|sort|uniq -c|sort -nr | head -5 >> BHF_Detail_Report_$file_name.txt 2>&1
echo -e "\n *************************************************\n" >>  BHF_Detail_Report_$file_name.txt 2>&1 
# cat xferlog*| grep -v axway |grep -v SyncplicityArchAccount | awk 'BEGIN{FS=" "} {print $8 " " $(NF-3)}'|uniq|awk '{ a[$2]+=$1 }END{ for(i in a) print a[i],i }'|sort -nr | head -5 | awk 'BEGIN{FS=" "} {print $1/1024/1024/1024 "GB" " " $2}'>> BHF_Detail_Report_$file_name.txt 2>&1
 
 fi
 

 

