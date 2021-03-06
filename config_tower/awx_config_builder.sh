#!/usr/bin/env bash

#
#                      CISCO SAMPLE CODE LICENSE
#                             Version 1.1
#             Copyright (c) 2017 Cisco and/or its affiliates
#
# These terms govern this Cisco Systems, Inc. (“Cisco”), example or demo source
# code and its associated documentation (together, the “Sample Code”). By
# downloading, copying, modifying, compiling, or redistributing the Sample Code,
#  you accept and agree to be bound by the following terms and conditions
#  (the “License”). If you are accepting the License on behalf of an entity, you
#  represent that you have the authority to do so
#  (either you or the entity, “you”). Sample Code is not supported by Cisco TAC
#  and is not tested for quality or performance. This is your only license to the
#  Sample Code and all rights not expressly granted are reserved.
#
# 1. LICENSE GRANT:   Subject to the terms and conditions of this License, Cisco
#    hereby grants to you a perpetual, worldwide, non-exclusive,
#    non-transferable, non-sublicensable, royalty-free license to copy and modify
#    the Sample Code in source code form, and compile and redistribute the Sample
#    Code in binary/object code or other executable forms, in whole or in part,
#    solely for use with Cisco products and services. For interpreted languages
#    like Java and Python, the executable form of the software may include source
#    code and compilation is not required.
#
# 2. CONDITIONS:      You shall not use the Sample Code independent of, or to
#    replicate or compete with, a Cisco product or service. Cisco products and
#    services are licensed under their own separate terms and you shall not use
#    the Sample Code in any way that violates or is inconsistent with those terms
#    (for more information, please visit: www.cisco.com/go/terms).
#
# 3. OWNERSHIP:       Cisco retains sole and exclusive ownership of the Sample Code,
#    including all intellectual property rights therein, except with respect to
#    any third-party material that may be used in or by the Sample Code. Any such
#    third-party material is licensed under its own separate terms
#    (such as an open source license) and all use must be in full accordance with
#    the applicable license. This License does not grant you permission to use
#    any trade names, trademarks, service marks, or product names of Cisco. If
#    you provide any feedback to Cisco regarding the Sample Code, you agree that
#    Cisco, its partners, and its customers shall be free to use and incorporate
#    such feedback into the Sample Code, and Cisco products and services, for any
#    purpose, and without restriction, payment, or additional consideration of
#    any kind. If you initiate or participate in any litigation against Cisco,
#    its partners, or its customers (including cross-claims and counter-claims)
#    alleging that the Sample Code and/or its use infringe any patent, copyright,
#    or other intellectual property right, then all rights granted to you under
#    this License shall terminate immediately without notice.
#
# 4. LIMITATION OF LIABILITY: CISCO SHALL HAVE NO LIABILITY IN CONNECTION WITH OR
#    RELATING TO THIS LICENSE OR USE OF THE SAMPLE CODE, FOR DAMAGES OF ANY KIND,
#    INCLUDING BUT NOT LIMITED TO DIRECT, INCIDENTAL, AND CONSEQUENTIAL DAMAGES,
#    OR FOR ANY LOSS OF USE, DATA, INFORMATION, PROFITS, BUSINESS, OR GOODWILL,
#    HOWEVER CAUSED, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
#
# 5. DISCLAIMER OF WARRANTY: SAMPLE CODE IS INTENDED FOR EXAMPLE PURPOSES ONLY
#    AND IS PROVIDED BY CISCO “AS IS” WITH ALL FAULTS AND WITHOUT WARRANTY OR
#    SUPPORT OF ANY KIND. TO THE MAXIMUM EXTENT PERMITTED BY LAW, ALL EXPRESS AND
#    IMPLIED CONDITIONS, REPRESENTATIONS, AND WARRANTIES INCLUDING, WITHOUT
#    LIMITATION, ANY IMPLIED WARRANTY OR CONDITION OF MERCHANTABILITY, FITNESS
#    FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, SATISFACTORY QUALITY,
#    NON-INTERFERENCE, AND ACCURACY, ARE HEREBY EXCLUDED AND EXPRESSLY DISCLAIMED
#    BY CISCO. CISCO DOES NOT WARRANT THAT THE SAMPLE CODE IS SUITABLE FOR
#    PRODUCTION OR COMMERCIAL USE, WILL OPERATE PROPERLY, IS ACCURATE OR COMPLETE,
#    OR IS WITHOUT ERROR OR DEFECT.
#
# 6. GENERAL:         This License shall be governed by and interpreted in accordance
#    with the laws of the State of California, excluding its conflict of laws
#    provisions. You agree to comply with all applicable United States export
#    laws, rules, and regulations. If any provision of this License is judged
#    illegal, invalid, or otherwise unenforceable, that provision shall be
#    severed and the rest of the License shall remain in full force and effect.
#    No failure by Cisco to enforce any of its rights related to the Sample Code
#    or to a breach of this License in a particular situation will act as a
#    waiver of such rights. In the event of any inconsistencies with any other
#    terms, this License shall take precedence.
#

declare awx_host=""
declare awx_username=""
declare awx_password=""
declare build_template_file="./awx_build_template.json"

if [[ $# -ge 1 ]]; then
  while [[ $1 ]]; do
    if [[ $1 == "-h" ]]; then
      echo -e "\n  Usage: awx_config_builder.sh --awx_host <AWX FQDN or IP> --awx_username <AWX Username> --awx_password <AWX Password> [--buildfile <path to build_template.json file>]"
      echo -e "\n  Default build template file location is ./awx_build_template.json"
      echo -e "\n  e.g. ./awx_config_builder.sh --awx_host \"192.168.3.1\" --awx_username \"admin\" --awx_password \"password\" --buildfile \"./mybuildfile.json\"\n"
      exit 0
    elif [[ $1 == "--awx_host" ]]; then
      shift
      awx_host="$1"
      continue
    elif [[ $1 == "--awx_username" ]]; then
      shift
      awx_username="$1"
      continue
    elif [[ $1 == "--awx_password" ]]; then
      shift
      awx_password="$1"
      continue
    elif [[ $1 == "--buildfile" ]]; then
      shift
      build_template_file="$1"
      continue
    fi
    shift
  done
fi

if [[ "$awx_host" == ""  || "$awx_username" == "" || "$awx_password" == "" ]]; then
  echo -e "\n  Usage: awx_config_builder.sh --awx_host <AWX FQDN or IP> --awx_username <AWX Username> --awx_password <AWX Password> [--buildfile <path to build_template.json file>]"
  echo -e "\n  Default build template file location is ./awx_build_template.json"
  echo -e "\n  e.g. ./awx_config_builder.sh --awx_host \"192.168.3.1\" --awx_username \"admin\" --awx_password \"password\" --buildfile \"./mybuildfile.json\"\n"
  exit 0
fi

declare build_config=$(cat $build_template_file)

declare new_projects_cnt="$(cat $build_template_file | jq '.projects | length')"
declare new_orgs_cnt=$(cat $build_template_file | jq '.organizations | length')
declare new_inventories_cnt=$(cat $build_template_file | jq '.inventories | length')
declare new_inventory_host_cnt=$(cat $build_template_file | jq '.inventory_hosts | length')
declare new_job_templates_cnt=$(cat $build_template_file | jq '.job_templates | length')
declare new_surveys_cnt=$(cat $build_template_file | jq '.surveys | length')

echo -e "\nPlanning to create the following:\n"
echo -e "$new_orgs_cnt organizations."
echo -e "$new_inventories_cnt inventories."
echo -e "$new_inventory_host_cnt inventory hosts."
echo -e "$new_projects_cnt projects."
echo -e "$new_job_templates_cnt job templates."
echo -e "$new_surveys_cnt job template surveys."


echo -e "\nCreating organizations...\n"

for (( i=0; i<$new_orgs_cnt; i++ ))
do
  echo "Creating organization: $(cat $build_template_file | jq ".organizations[$i].name")"

  declare post_data=$(cat $build_template_file | jq -r ".organizations[$i]")
  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/organizations/" > /dev/null
done


echo -e "\nCreating projects...\n"

declare existing_orgs="$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/organizations/")"
declare -i existing_orgs_cnt="$(echo $existing_orgs | jq -r '.results | length')"

for (( i=0; i<$new_projects_cnt; i++ ))
do
  declare project_name=$(cat $build_template_file | jq -r ".projects[$i].name")
  declare project_org_name=$(cat $build_template_file | jq -r ".projects[$i].organization")
  declare project=$(cat $build_template_file | jq -r ".projects[$i]")

  echo "Creating project: $project_name"

  declare -i project_org_id=0

  for (( j=0; j<$existing_orgs_cnt; j++ ))
  do
    awx_org_name=$(echo $existing_orgs | jq -r ".results[$j].name")
    awx_org_id=$(echo $existing_orgs | jq -r ".results[$j].id")

    if [ $awx_org_name == $project_org_name ]; then
      project_org_id=$awx_org_id
      break;
    fi
  done

  if [[ $project_org_id -eq 0 ]]; then
    echo -e "\nCouldn't find organisation name configured for project [$project_name].\nPlease rectify and retry.\nExiting...\n"
    exit 0
  fi

  declare post_data=$(echo $project | jq -r ". | {name: .name, organization: $project_org_id, scm_type: .scm_type, scm_url: .scm_url, scm_update_on_launch: .scm_update_on_launch}")

  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/projects/" > /dev/null

done

echo -e "\nPausing for 30 seconds in order to allow Git repo synchronisation..."
sleep 30

echo -e "\nCreating inventories...\n"

declare existing_orgs="$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/organizations/")"
declare -i existing_orgs_cnt="$(echo $existing_orgs | jq -r '.results | length')"

for (( i=0; i<$new_inventories_cnt; i++ ))
do
  declare inventory_name=$(cat $build_template_file | jq -r ".inventories[$i].name")
  declare inventory_org_name=$(cat $build_template_file | jq -r ".inventories[$i].organization")
  declare inventory=$(cat $build_template_file | jq -r ".inventories[$i]")

  echo "Creating inventory: $inventory_name"

  declare -i inventory_org_id=0

  for (( j=0; j<$existing_orgs_cnt; j++ ))
  do
    awx_org_name=$(echo $existing_orgs | jq -r ".results[$j].name")
    awx_org_id=$(echo $existing_orgs | jq -r ".results[$j].id")

    if [ $awx_org_name == $inventory_org_name ]; then
      inventory_org_id=$awx_org_id
      break;
    fi
  done

  if [[ $inventory_org_id -eq 0 ]]; then
    echo -e "\nCouldn't find organisation name configured for inventory [$inventory_name].\nPlease rectify and retry.\nExiting...\n"
    exit 0
  fi

  declare post_data=$(echo $inventory | jq -r ". | {name: .name, organization: $inventory_org_id, variables: .variables}")

  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/inventories/" > /dev/null

done

echo ""

echo -e "\nCreating inventory hosts...\n"

declare existing_inventories="$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/inventories/")"
declare -i existing_inventories_cnt="$(echo $existing_inventories | jq -r '.results | length')"

for (( i=0; i<$new_inventory_host_cnt; i++ ))
do
  declare inventory_host_name=$(cat $build_template_file | jq -r ".inventory_hosts[$i].name")
  declare inventory_name=$(cat $build_template_file | jq -r ".inventory_hosts[$i].inventory")
  declare inventory_hosts=$(cat $build_template_file | jq -r ".inventory_hosts[$i]")

  echo "Creating inventory host: $inventory_host_name"

  declare -i inventory_host_id=0

  for (( j=0; j<$existing_inventories_cnt; j++ ))
  do
    existing_inventory_name=$(echo $existing_inventories | jq -r ".results[$j].name")
    existing_inventory_id=$(echo $existing_inventories | jq -r ".results[$j].id")

    if [ $existing_inventory_name == $inventory_name ]; then
      inventory_host_id=$existing_inventory_id
      break;
    fi
  done

  if [[ $inventory_host_id -eq 0 ]]; then
    echo -e "\nCouldn't find inventory name configured for inventory host [$inventory_host_name].\nPlease rectify and retry.\nExiting...\n"
    exit 0
  fi

  declare post_data=$(echo $inventory_hosts | jq -r ". | {name: .name, enabled: true, inventory: $inventory_host_id}")

  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/hosts/" > /dev/null

done

echo ""

echo -e "\nCreating job templates...\n"

declare existing_inventories="$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/inventories/")"
declare -i existing_inventories_cnt="$(echo $existing_inventories | jq -r '.results | length')"
declare existing_projects="$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/projects/")"
declare -i existing_projects_cnt="$(echo $existing_projects | jq -r '.results | length')"

for (( i=0; i<$new_job_templates_cnt; i++ ))
do
  declare job_templates_name=$(cat $build_template_file | jq -r ".job_templates[$i].name")
  declare job_templates_inventory_name=$(cat $build_template_file | jq -r ".job_templates[$i].inventory")
  declare job_templates_project_name=$(cat $build_template_file | jq -r ".job_templates[$i].project")
  declare job_templates=$(cat $build_template_file | jq -r ".job_templates[$i]")

  echo "Creating job template: $job_templates_name"

  declare -i job_templates_inventory_id=0

  for (( j=0; j<$existing_inventories_cnt; j++ ))
  do
    existing_inventory_name=$(echo $existing_inventories | jq -r ".results[$j].name")
    existing_inventory_id=$(echo $existing_inventories | jq -r ".results[$j].id")

    if [ $existing_inventory_name == $job_templates_inventory_name ]; then
      job_templates_inventory_id=$existing_inventory_id
      break;
    fi
  done

  if [[ $job_templates_inventory_id -eq 0 ]]; then
    echo -e "\nCouldn't find inventory name configured for jobs_template [$job_templates_name].\nPlease rectify and retry.\nExiting...\n"
    exit 0
  fi

  declare -i job_templates_projects_id=0

  for (( j=0; j<$existing_projects_cnt; j++ ))
  do
    existing_projects_name=$(echo $existing_projects | jq -r ".results[$j].name")
    existing_projects_id=$(echo $existing_projects | jq -r ".results[$j].id")

    if [ $existing_projects_name == $job_templates_project_name ]; then
      job_templates_projects_id=$existing_projects_id
      break;
    fi
  done

  if [[ $job_templates_projects_id -eq 0 ]]; then
    echo -e "\nCouldn't find project name configured for jobs_template [$job_templates_name].\nPlease rectify and retry.\nExiting...\n"
    exit 0
  fi

  declare post_data=$(echo $job_templates | jq -r ". | {name: .name, job_type: \"run\", inventory: $job_templates_inventory_id, project: $job_templates_projects_id, playbook: .playbook, use_fact_cache: true, survey_enabled: true}")

  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/job_templates/" > /dev/null

done

echo ""


echo -e "\nCreating surveys...\n"

declare existing_job_templates="$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/job_templates/")"
declare -i existing_job_templates_cnt="$(echo $existing_job_templates | jq -r '.results | length')"

for (( i=0; i<$new_surveys_cnt; i++ ))
do
  declare survey_job_template_name=$(cat $build_template_file | jq -r ".surveys[$i].job_template")
  declare survey_spec=$(cat $build_template_file | jq -r ".surveys[$i].survey_spec")

  echo "Creating survey for job template: $survey_job_template_name"

  declare -i survey_job_template_id=0

  for (( j=0; j<$existing_job_templates_cnt; j++ ))
  do
    existing_job_template_name=$(echo $existing_job_templates | jq -r ".results[$j].name")
    existing_job_template_id=$(echo $existing_job_templates | jq -r ".results[$j].id")

    if [ "$existing_job_template_name" == "$survey_job_template_name" ]; then
      survey_job_template_id=$existing_job_template_id
      break;
    fi
  done

  if [[ $survey_job_template_id -eq 0 ]]; then
    echo -e "\nCouldn't find job template name [$survey_job_template_name] in order to configure survey.\nPlease rectify and retry.\nExiting...\n"
    exit 0
  fi

  curl -s -X POST -H "Content-Type: application/json" -d "$survey_spec" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/job_templates/$survey_job_template_id/survey_spec/" > /dev/null

done

echo ""
