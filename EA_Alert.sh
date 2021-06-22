#!/bin/bash
#Author: Abhisek
#Requirement: This tool is required to configure the File transfer as well as Punctuality alert in Prod EA server

Usage() {
 echo -e "\e[0;31mEA_Alert: mandatory option is missing\e[0m"
 tput bold
 echo -e "\e[0;34mEA_Alert -s <No Arg needed> -r <No Arg needed> -f <file name> -h <No Arg needed>\e[0m"
 tput sgr0
 echo "Where:"
 echo "-s is used to enable/disable the sso"
 echo "-r is used to restart the platform service"
 echo "-f is used to provide the file name where alert config details are mentioned in below format"
 tput bold
 echo "Feature|Accout|Filename|Function|Schedule|Email"
 tput sgr0
 echo "-h is used to print this info"
 exit 1
}

if [ "$#" -eq 0 -o  "$1" == -h ]; then
 Usage
fi

usr=`whoami`
if [ $usr != root ];then echo "Current user is not root, exiting";exit 0;fi

remove_temp_file()
{
 rm -f $dt_file $punct_file_ui $punct_file_srv $filter_list $dt_duplicate $punct_duplicate 2>/dev/null
 rm -f /tmp/check_f_num.$$ 2>/dev/null
 rm -f /tmp/check_field.$$ 2>/dev/null
 rm -f /tmp/check_schedule.$$ 2>/dev/null
}

handle_signal()
{
 echo ""
 echo -n "Deleting temporary files, please wait"
 for i in `seq 1 5`; do
   sleep 0.5
   echo -n "."
   remove_temp_file
 done
 echo ""
 kill -9 $$
 exit 1
}

start_stop()
{
 if [ ! -f "$PID_FILE" ]; then echo -e "\nPID file does not exist: $PID_FILE"; exit 1; fi
 if [ ! -f "$HOME_DIR/bin/service.log.$(cat $HOME_DIR/pid)" ];then echo -e "\nservice log file does not exist"; exit 1;fi
 trap '' 2
 source $HOME_DIR/bin/tnd-stop.sh > $HOME_DIR/bin/service.log.$(cat $HOME_DIR/pid) 2>&1 &
 echo -n "Platform is being stopped"
 wait_period=`date -ud "90 sec" +%s`
 while true
 do
   if grep -q "PLATFORM STOPPED" $HOME_DIR/bin/service.log.$(cat $HOME_DIR/pid) 2>/dev/null;then
     echo -e "\nPlatform stopped going to start the service"
     break
   else
     if [ $wait_period -le $(date +%s) ];then
       echo -e "\e[0;31m\nCould not stop platform wihin 1 min.Exiting\e[0m"
       exit 1
     fi
    echo -n "."
    sleep 2.5
 fi
 done
 rm -f $HOME_DIR/bin/service.log.$(cat $HOME_DIR/pid)
 echo $$ > $HOME_DIR/pid
 
 source $HOME_DIR/bin/START.sh >> $HOME_DIR/bin/service.log.$$ 2>&1 &
 echo -n "Platform is being start"
 wait_period=`date -ud "150 sec" +%s`
 while true
 do
   if grep -q "PLATFORM STARTED" $HOME_DIR/bin/service.log.$$ 2>/dev/null;then
     echo -e "\nPlatform has been started successfully"
     break
   else
     if [ $wait_period -le $(date +%s) ];then
       echo -e "\e[0;31m\nCould not start platform wihin 3 min.Exiting\e[0m"
       exit 1
     fi
     echo -n "."
     sleep 2.5
   fi
 done
 trap 2
}

disable_sso()
{
 ln=`grep -n "To disable SSO" $HOME_DIR/conf/platform.properties | awk -F : '{print $1}'`
 for i in {1..4};do 
   ln=`expr $ln + 1`
   sed -i -e ''$ln's/./#&/' $HOME_DIR/conf/platform.properties
 done
 start_stop
 echo -e "SSO is \e[1;34mdisabled\e[0m"
}

enable_sso()
{
 ln=`grep -n "To disable SSO" $HOME_DIR/conf/platform.properties | awk -F : '{print $1}'`
 for i in {1..4};do
   ln=`expr $ln + 1`
   sed -i -e ''$ln's/^#//' $HOME_DIR/conf/platform.properties
 done
 start_stop
 echo -e "SSO is \e[1;32menabled\e[0m"
}

check_sso() 
{
 if ! grep  -A 4 "To disable SSO" $HOME_DIR/conf/platform.properties | tail -n+2 | grep -q ^#
 then
   echo "SSO is Enable"
   echo -n "Disable[y/n]:"
   for i in {1..3};do
     read usr_in
     if [ "XX$usr_in" == "XXn" ] || [ "XX$usr_in" == "XXN" ];then
       exit 0
     elif [ "XX$usr_in" == "XXy" ] || [ "XX$usr_in" == "XXY" ];then
       disable_sso
       break
     else
       if [ "$i" == "3" ];then echo -e "Valid Inp not provided, Hence exiting..\n";exit 1;fi 
       echo "Please enter valid Input"
       echo -n "Disable[y/n]:"
     fi
   done
 else 
   echo "SSO is Disable"
   echo -n "Enable[y/n]:"
   for i in {1..3};do
     read usr_in
     if [ "XX$usr_in" == "XXn" ] || [ "XX$usr_in" == "XXN" ];then
       exit 0
     elif [ "XX$usr_in" == "XXy" ] || [ "XX$usr_in" == "XXY" ];then
       enable_sso
       break
     else
       if [ "$i" == "3" ];then echo -e "Valid Inp not provided, Hence exiting..\n";exit 1;fi
       echo "Please enter valid Input"
       echo -n "Enable[y/n]:"
     fi
   done
 fi
}

validate_file()
{
 awk -F"|" '{if($1=="")print $0}' /tmp/filter_list.$$ > /tmp/check_f_num.$$
 if [ $(cat /tmp/check_f_num.$$ | wc -l) -ge 1 ];then
   echo -e "\n\e[0;31mFeature Number field can not be empty. Check below wrong entries\e[0m\n"
   cat /tmp/check_f_num.$$
   exit 1
 else
   awk -F"|" '{if($2==""||$3==""||$4=="")print $0}' /tmp/filter_list.$$ > /tmp/check_field.$$
   if [ $(cat /tmp/check_field.$$ | wc -l) -ge 1 ];then
     echo -e "\n\e[0;31mAccount,Filename or Function field can not be empty. Check below wrong entries\e[0m\n"
     cat /tmp/check_field.$$
     exit 1
   else
     awk -F"|" '{if($4=="pull"&&$5=="")print $0}' /tmp/filter_list.$$ > /tmp/check_schedule.$$
     if [ $(cat /tmp/check_schedule.$$ | wc -l) -ge 1 ];then	
       echo -e "\n\e[0;31mSchedule is not defined for pull function.Check below wrong entries\e[0m\n"
       cat /tmp/check_schedule.$$
       exit 1
     fi
   fi
 echo -e "\nFile validation complete,going to configure Alert\n";sleep 1
 fi
}

dt_alert()
{
 if ! grep -w "$file_name" $dt_file_org | grep -q "$account";then
   for i in `seq 1 4`;do
     eval mode=\$$i
     if [ "XX$mail" != "XX" ];then
       echo "$mode;$account;<any>;SFTP;Contains($file_name);<any>;<any>;<any>;bhf.cloudmft.operations@axway.com,BHF-MFT-SUPPORT@brighthousefinancial.com,$mail" >> $dt_file
     else
       echo "$mode;$account;<any>;SFTP;Contains($file_name);<any>;<any>;<any>;bhf.cloudmft.operations@axway.com,BHF-MFT-SUPPORT@brighthousefinancial.com" >> $dt_file
     fi
   done
 else
   echo "$file_name | $account" >> $dt_duplicate
 fi
}

punct_alert_gui()
{
 if [ "XX$srv_flag" != "XX0" ];then
 date=`date +"%Y-%m-%d"`
 echo "CK_$f_num,$account,RECEIVED,$schedule:00,1,$date" >> $punct_file_ui
 fi
}
punct_alert_srv()
{
 if ! grep -w "$file_name" $punct_file_srv_org | grep -q "$account";then
   echo "StartsWith($file_name);<any>;$account;RECEIVED;CK_$f_num" >> $punct_file_srv
   srv_flag=1
 else
   echo "$file_name | $account" >> $punct_duplicate
   srv_flag=0
 fi
}

set_alert()
{
 if [ ! -e $file ];then
   echo -e "\e[0;31m $file file is not present\e[0m"
    exit 1
 fi
 sed -e 's/\t/|/g' $file > /tmp/filter_list.$$
 sed -i -e '/^$/d' /tmp/filter_list.$$
 sed -i -e 's/\s*|\s*/|/g' /tmp/filter_list.$$
 sed -i -e 's/[[:space:]]/:/g' /tmp/filter_list.$$
 list=($(cat $filter_list))
 if [ "${#list[@]}" -eq 0 ]; then
   echo -e "\e[0;31mlist is empty\e[0m"
   exit 1
 else
   validate_file		
   for (( j=0;j<${#list[@]};j++ ))
   do
     f_num=($(grep -w ${list[$j]} $filter_list|cut -d '|' -f 1))
     account=($(grep -w ${list[$j]} $filter_list|cut -d '|' -f 2))
     file_name=($(grep -w ${list[$j]} $filter_list|cut -d '|' -f 3))
     function=($(grep -w ${list[$j]} $filter_list|cut -d '|' -f 4))
     schedule=($(grep -w ${list[$j]} $filter_list|cut -d '|' -f 5))
     mail=($(grep -w ${list[$j]} $filter_list|cut -d '|' -f 6))
     dt_alert SENT RECEIVED FAILED PERMANENTLYFAILED
     if [ "XX$function" == "XXpull" ];then
       punct_alert_srv
       punct_alert_gui
     fi 
   done
 fi
 
 if [ ! -f "$dt_file_org" ]; then echo -e "\ndtFileTransferAlert.txt file does not exist: $dt_file_org"; exit 1; fi
 if [ -s "$dt_file" ];then 
   sed -i -e "1 s/^/\n#FileTransfer alert start on $(date +"%m-%d-%Y")\n\n/" $dt_file
   echo -e "\n#FileTransfer alert end on $(date +"%m-%d-%Y")" >> $dt_file
   cp $dt_file_org "$HOME_DIR/var/dtFileTransferAlert.txt_$(date +"%m%d%Y%H%M")"
   sed -i -e 's/:/ /g' $dt_file
   sed -i -e 's/PERMANENTLYFAILED/PERMANENTLY FAILED/g' $dt_file
   cat $dt_file >> $dt_file_org
   echo "File transfer alert has been configured"
   ls -t ${dt_file_org}_* | tail -n +3 | xargs rm 2>/dev/null
   if [ -s "$dt_duplicate" ];then
     echo "Check below duplicate entry for file transfer alert"
     cat $dt_duplicate
     echo -e "\n"
   fi
 else
   echo "Check below duplicate entry for file transfer alert"
   cat $dt_duplicate
   echo -e "\n"
 fi

 if grep -q "pull" $filter_list;then
   if [ ! -f "$punct_file_srv_org" ]; then echo -e "\ndtPunctualityCheck.txt does not exist: $punct_file_srv_org"; exit 1; fi
   if [ -s "$punct_file_srv" ];then
     cp $punct_file_srv_org "$HOME_DIR/var/dtPunctualityCheck.txt_$(date +"%m%d%Y%H%M")"
     sed -i -e 's/:/ /g' $punct_file_srv
     cat $punct_file_srv >> $punct_file_srv_org 
     echo -e "Punctuality Alert has been configured in Server side\n\nPlease use below entries for UI\n"
     ls -t ${punct_file_srv_org}_* | tail -n +3 | xargs rm 2>/dev/null
     cat $punct_file_ui
     echo -e "\n"
     if [ -s "$punct_duplicate" ];then
       echo "Check below duplicate entry for punctuality alert"
       cat $punct_duplicate
       echo -e "\n"
     fi
   else
     echo "Check below duplicate entry for punctuality alert"
     cat $punct_duplicate
     echo -e "\n"
   fi
 fi 
}

HOME_DIR=/Axway/DecisionInsight
PID_FILE="$HOME_DIR/pid"
dt_file=/tmp/dt_alert.$$
punct_file_ui=/tmp/punct_ui.$$
punct_file_srv=/tmp/punct_srv.$$
filter_list=/tmp/filter_list.$$
dt_file_org="$HOME_DIR/var/dtFileTransferAlert.txt"
punct_file_srv_org="$HOME_DIR/var/dtPunctualityCheck.txt"
dt_duplicate=/tmp/dt_duplicate.$$
punct_duplicate=/tmp/punct_duplicate.$$

while getopts f:srh arg
do
  case $arg in
    f) file=$OPTARG ;;
    s) flag='0' ;;
    r) flag='1' ;;
    h) Usage ;;
    *) Usage ;;
  esac
done

trap handle_signal 2
trap handle_signal EXIT

if [ "XX$flag" == "XX0" ];then
  check_sso
elif [ ! -z $file ];then
  set_alert
  check_sso  
elif [ "XX$flag" == "XX1" ];then
 start_stop
else
  echo -e "\e[0;31m Invalid Argument given\e[0m"
  Usage
fi
