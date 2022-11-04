#!/usr/bin/env bash

set -ueo pipefail

profile=""
environment=""

function usage() {
  echo "Usage:"
  echo "  Required Arguments:"
  echo "    -e <environment name> # required. Elastic Beanstalk env."
  echo
  echo "  Optional Arguments:"
  echo "    -p <aws profile name> # optional"
  echo "    -x                    # optional. verbose mode."
  echo "    -h"
  echo
  echo "  Required programs:"
  echo "    - jq"
  echo "    - awscli"
  exit ${1:-0}
}

while getopts :e:hp:x flag
do
  case ${flag} in
    x) set -x;;
    p) profile="--profile ${OPTARG}";;
    e) environment="${OPTARG}";;
    h) usage;;
    :) echo "arg required for: -${OPTARG}"; usage 1;;
    ?) echo "invalid arg: -${OPTARG}"; usage 1;;
  esac
done

if [[ -z "$environment" ]]; then
  usage 1
fi

lbarn=$(aws $profile elasticbeanstalk describe-environment-resources --environment-name $environment | jq .EnvironmentResources.LoadBalancers[0].Name | tr -d '"')
targetgrouparn=$(aws $profile elbv2 describe-target-groups --load-balancer-arn $lbarn | jq .TargetGroups[0].TargetGroupArn | tr -d '""')

truncate -s 0 target-deploy.log

while true; do
  sclear="true"
  for x in {1..10}; do
    state=$(aws $profile elbv2 describe-target-health --target-group-arn $targetgrouparn | jq .TargetHealthDescriptions[0].TargetHealth.State)

    if [[ -n "${sclear}" ]]; then
      clear
      sclear=""
    fi

    printf "$(date) - ${state}\n" | tee -a target-deploy.log > /dev/null
    echo ${state}
  done
done
