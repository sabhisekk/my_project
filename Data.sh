#!/bin/bash

#Function for converting size to a human readable
SC()
{
BYTE=$1
if [[ -z $BYTE ]]; then
    BYTE=0
fi

if [[ $BYTE -lt 1024 ]]; then
        echo "$BYTE bytes"

elif [[ $BYTE -lt 1048576 ]]; then
        (echo "scale=2;$BYTE /1024 " | bc ; echo KB)|tr '\n' ' '

elif [[ $BYTE -lt 1073741824 ]]; then
        (echo "scale=2;$BYTE /1024 /1024" | bc ; echo MB)|tr '\n' ' '

else
        (echo "scale=2;$BYTE /1024 /1024 /1024" | bc ; echo GB)|tr '\n' ' '

fi
}
echo -e "\n\n******************* $1 ******************************\n"
(echo -e " <<----- Total_Data/Volume_Used ----->>  ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )" )|tr '\n' ' '
echo -e "\n"
(echo -e "Inbound_Total    : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -wE 'i|\j|\k' | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo
(echo -e "Inbound_OK       : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -w i | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo
(echo -e "Inbound_ERROR    : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -w j | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo
(echo -e "Inbound_Aborted  : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -w k | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo -e "\n"
(echo -e "Outbound_Total   : ";SC "$(cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -wE 'o|\p|\q' | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo
(echo -e "Outbound_OK      : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -w o | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo
(echo -e "Outbound_ERROR   : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -w p | awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '
echo
(echo -e "Outbound_Aborted : ";SC "$( cat xferlog.20$2$3* | grep -v axway | grep -w $1 |grep -v SyncplicityArchAccount | grep -w q |awk 'BEGIN{FS=" "} {print $8 " " $9}'|uniq|awk '{sum+=$1;} END {print sum}' )")|tr '\n' ' '

echo -e "\n\n *************************************************\n"


