#!/bin/bash
echo -e "\n ******************* $1/$2 ******************************\n"
echo "Total_Transactions    : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | wc -l )"
                echo -e "\nInbound_Total    : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -wE 'i|\j|\k' | wc -l )"
                echo "Inbound_OK       : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -w i | wc -l )"
                echo "Inbound_ERROR    : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -w j | wc -l )"
                echo "Inbound_Aborted  : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -w k | wc -l )"
                echo -e "\nOutbound_Total   : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -wE 'o|\p|\q' | wc -l )"
                echo "Outbound_OK      : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -w o | wc -l )"
                echo "Outbound_ERROR   : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -w p | wc -l )"
                echo "Outbound_Aborted : $(cat xferlog.20$1$2* | grep -v axway  |grep -v SyncplicityArchAccount | grep -w q |wc -l )"
echo -e "\n *************************************************\n"

