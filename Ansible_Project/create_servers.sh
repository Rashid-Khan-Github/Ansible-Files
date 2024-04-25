#! /bin/bash

NAMES=("mongodb" "catalogue" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-0f3c7d07486cad139
SECURITY_GROUP_ID=sg-03e2563eefcedfe47
DOMAIN_NAME=bsebregistration.com
HOSTED_ZONE_ID=Z0513646AB3WBDGO9A9V


for i in "${NAMES[@]}"
do
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.micro"
    else
        INSTANCE_TYPE="t3.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID  --tag-specifications "ResourceType=instance,Tags= [{Key=Name, Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')

    echo "Creating Instance -> $i----PrivateIP : $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID  --change-batch '
        {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
        }
    '

done

