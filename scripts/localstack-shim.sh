#!/bin/bash

source scripts/config.sh
check_env
source scripts/aws-local.sh

timestamp=$(date +'%Y-%m-%d-%H-%M-%S')
cluster_region=$(cat $MAIN_VAR_FILE | hclq get 'cluster_region' --raw)
cluster_name=$(cat $MAIN_VAR_FILE | hclq get 'cluster_name' --raw)
mld=$(cat $MAIN_VAR_FILE | hclq get 'mld' --raw)
tld=$(cat $MAIN_VAR_FILE | hclq get 'tld' --raw)
domain_name="$cluster_name.$mld.$tld"

create_hosted_zone() {
  hosted_zone=$(aws-local route53 create-hosted-zone \
    --region $cluster_region \
    --name utkusarioglu.com \
    --caller-reference "$timestamp" \
    --output json \
  )
  hosted_zone_id=$(jq --raw-output '.HostedZone.Id' <<< "$hosted_zone")
  echo $hosted_zone_id
}

create_domain_name() {
  created_domain_name=$(aws-local apigatewayv2 create-domain-name \
    --region $cluster_region \
    --domain-name $domain_name \
    --query 'DomainName' \
    --output text \
  )
  echo $created_domain_name
}

delete_domain_name() {
  domain_name=$1
  echo "Deleting domain name '$domain_name'"
  aws-local apigatewayv2 delete-domain-name \
    --region $cluster_region \
    --domain-name $domain_name 
}

delete_all_hosted_zones() {
  hosted_zone_ids=$(aws-local route53 list-hosted-zones \
    --region $cluster_region \
    --query 'HostedZones[*].Id' \
    --output text \
  )

  for hosted_zone_id in $hosted_zone_ids;
  do
    aws-local route53 list-resource-record-sets \
      --region $cluster_region \
      --hosted-zone-id $hosted_zone_id | \
      jq -c '.ResourceRecordSets[]' | 
      while read -r resource_record_set; do
        read -r name type <<<$(echo $(jq -r '.Name,.Type' <<<"$resource_record_set"))
        if [ $type != "NS" -a $type != "SOA" ]; then
          aws-local route53 change-resource-record-sets \
            --region $cluster_region  \
            --hosted-zone-id $hosted_zone_id \
            --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
                '"$resource_record_set"'
              }]}' \
            --output text --query 'ChangeInfo.Id' 1> /dev/null
        fi
      done

    echo "Deleting hosted zone '$hosted_zone_id'…"
    aws-local route53 delete-hosted-zone \
      --region $cluster_region \
      --id $hosted_zone_id 1> /dev/null
  done
}

create_localstack_shim() {
  echo "Creating LocalStack shim:"
  delete_all_hosted_zones
  hosted_zone_id=$(create_hosted_zone)
  created_domain_name=$(create_domain_name $domain_name)
  echo "Created domain name '$created_domain_name'"
  echo "Created hosted zone with the id: '$hosted_zone_id'"
}

destroy_localstack_shim() {
  echo "Destroying LocalStack shim:"
  delete_domain_name $domain_name
  delete_all_hosted_zones
}

shim_creation_required() {
  [ "$1" = "apply" ] || [ "$1" = "plan" ]
}

shim_destruction_required() {
  [ "$1" = "destroy" ]
}
