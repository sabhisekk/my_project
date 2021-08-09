#!/bin/bash
read ip
fld=`echo $ip | awk -F '.' '{print NF}'`

echo $ip | grep -q "^[0-9]*.[0-9]*.[0-9]*.[0-9]*$"
status=$?
if [ $fld -ne 4 ];then
	echo "wrong format of IP"
	exit 1
elif [ $status -ne 0 ];then
	echo "please enter only number"
	exit 1
fi

cip[0]=`echo $ip | awk -F '.' '{print $1}'`
cip[1]=`echo $ip | awk -F '.' '{print $2}'`
cip[2]=`echo $ip | awk -F '.' '{print $3}'`
cip[3]=`echo $ip | awk -F '.' '{print $4}'`


for i in {0..3};do
if [ ${cip[$i]} -ge 1 ] && [ ${cip[$i]} -le 255 ];then
	flag=0
else 
	flag=1
	break
fi
done
if [ $flag -eq 0 ];then
	echo "valid IP"
else
	echo "Invalid IP"
fi

