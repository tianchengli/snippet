#!/bin/bash

set -eo pipefail

function show(){
	SFRS=$(aws --region ap-southeast-2 ec2 describe-spot-fleet-requests | jq .SpotFleetRequestConfigs[].SpotFleetRequestId -r)
	for SRF in $SFRS
	do
		echo "==== $SRF ===="
		Output=$(aws --region ap-southeast-2 ec2 describe-spot-fleet-instances --spot-fleet-request-id $SRF)

		if  echo $Output | jq '.ActiveInstances[].InstanceId' >/dev/null 2>&1 ; then
			Instances=$(echo $Output| jq .ActiveInstances[].InstanceId -r )

			for Instance in $Instances
			do
				A=$(aws --region ap-southeast-2 ec2 describe-instances --instance-ids ${Instance} | jq '.Reservations[].Instances[]|[.InstanceId,.PublicIpAddress,.PrivateIpAddress, .KeyName, .LaunchTime]' | jq .[] -r)
				AS=($A)
				echo ${AS[0]} ${AS[1]} ${AS[2]} ${AS[3]} ${AS[4]} 
			done
		fi
	done
}




function cancel(){
	echo "canceling $1"
	aws --region ap-southeast-2 ec2 cancel-spot-fleet-requests --terminate-instances --spot-fleet-request-ids $1
}

function usage(){
	echo "Usage:"
	echo "$0 show"
	echo "$0 cancel spot-fleet-request-id"
}
case $1 in 
	"show")
		show
	;;
	"cancel")
		cancel $2
	;;
esac


