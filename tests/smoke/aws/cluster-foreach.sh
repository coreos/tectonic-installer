#!/usr/bin/env bash
set -x
set -e

if [ $# -eq 0 ]
then
  echo "usage: $0 command"
  echo "Make sure your AWS creds & env vars are set (\$AWS_REGION, \$CLUSTER)"
fi

if [ -z "$CLUSTER" ]
then
  echo "\$CLUSTER not set"
  exit 1
fi
if [ -z "$AWS_REGION" ]
then
  echo "\$AWS_REGION not set"
  exit 1
fi

CMD=$*

ASG_NAME="${CLUSTER}-masters"
INSTANCES=$(aws autoscaling describe-auto-scaling-groups --region="$AWS_REGION" --auto-scaling-group-names="$ASG_NAME" | jq -r .AutoScalingGroups[0].Instances[].InstanceId)
# shellcheck disable=SC2086
HOSTS=$(aws ec2 describe-instances --region="$AWS_REGION" --instance-ids $INSTANCES | jq -r .Reservations[].Instances[].PublicIpAddress)

set +e
for HOST in $HOSTS
do
  ssh -vv -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null "core@${HOST}" 'bash -s' < "$CMD"
done
