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

if [[ $# -ge 1 ]]; then
  while [[ $1 ]]; do
    if [[ $1 == "-h" ]]; then
      echo -e "\n  Usage: clear_awx_config.sh --awx_host <AWX FQDN or IP> --awx_username <AWX Username> --awx_password <AWX Password>"
      echo -e "\n  e.g. ./clear_awx_config.sh --awx_host \"192.168.3.1\" --awx_username \"admin\" --awx_password \"password\"\n"
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
    fi
    shift
  done
else
  echo -e "\n  Usage: clear_awx_config.sh --awx_host <AWX FQDN or IP> --awx_username <AWX Username> --awx_password <AWX Password>"
  echo -e "\n  e.g. ./clear_awx_config.sh --awx_host \"192.168.3.1\" --awx_username \"admin\" --awx_password \"password\"\n"
  exit 0
fi

if [[ "$awx_host" == ""  || "$awx_username" == "" || "$awx_password" == "" ]]; then
  echo -e "\n  Usage: clear_awx_config.sh --awx_host <AWX FQDN or IP> --awx_username <AWX Username> --awx_password <AWX Password>"
  echo -e "\n  e.g. ./clear_awx_config.sh --awx_host \"192.168.3.1\" --awx_username \"admin\" --awx_password \"password\"\n"
  exit 0
fi

# This script is disruptive. Ensure that the end user is aware of what they are doing.
echo -e "\nYou have chosen to clear the configuration from the following AWX host:\n"
echo -e "AWX host: $awx_host\nUsername: $awx_username\nPassword: $awx_password"
echo -n -e "\nThis script will clear configuration AWX elements. Are you sure you want to do this (y/n)? "
read confirmation

case $confirmation in
     y|Y)
          echo ""
          ;;
     n|N)
          echo ""
          exit 0
          ;;
     *)
          echo -e "\nValid responses are y or n.\n"
          exit 0
          ;;
esac

# Retrieve job template entries
declare template_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/job_templates/")

# Retrieve the job template count.
declare -i template_count="$(echo $template_reponse | jq -r '.results | length')"

# Delete job templates.
if [[ $template_count -gt 0 ]]; then

  echo -e "Deleting $template_count job templates.\n"

  for (( i=0; i<$template_count; i++ ))
  do
    echo "Deleting job template [$(echo $template_reponse | jq -r ".results[$i].name")], id: [$(echo $template_reponse | jq -r ".results[$i].id")]"

    template_id="$(echo $template_reponse | jq -r ".results[$i].id")"

    curl -s -X DELETE -u "$awx_username:$awx_password" "http://$awx_host/api/v2/job_templates/$template_id/"
  done
  echo ""
else
  echo "No job templates found."
fi

# Check again to ensure that templates were removed. $template_count should be zero.
template_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/job_templates/")
template_count="$(echo $template_reponse | jq -r '.results | length')"

if [[ $template_count -gt 0 ]]; then
  echo "Failed to remove job templates!"
fi

# Retrieve project entries
declare project_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/projects/")

# Retrieve the project count.
declare -i project_count="$(echo $project_reponse | jq -r '.results | length')"

# Delete projects.
if [[ $project_count -gt 0 ]]; then

  echo -e "Deleting $project_count projects.\n"

  for (( i=0; i<$project_count; i++ ))
  do
    echo "Deleting project [$(echo $project_reponse | jq -r ".results[$i].name")], id: [$(echo $project_reponse | jq -r ".results[$i].id")]"

    project_id="$(echo $project_reponse | jq -r ".results[$i].id")"

    curl -s -X DELETE -u "$awx_username:$awx_password" "http://$awx_host/api/v2/projects/$project_id/"
  done
  echo ""
else
  echo "No projects found."
fi

# Retrieve inventories entries
declare inventories_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/inventories/")

# Retrieve the inventories count.
declare -i inventories_count="$(echo $inventories_reponse | jq -r '.results | length')"

# Delete inventories.
if [[ $inventories_count -gt 0 ]]; then

  echo -e "Deleting $inventories_count inventories.\n"

  for (( i=0; i<$inventories_count; i++ ))
  do
    echo "Deleting inventories [$(echo $inventories_reponse | jq -r ".results[$i].name")], id: [$(echo $inventories_reponse | jq -r ".results[$i].id")]"

    inventories_id="$(echo $inventories_reponse | jq -r ".results[$i].id")"

    curl -s -X DELETE -u "$awx_username:$awx_password" "http://$awx_host/api/v2/inventories/$inventories_id/"
  done
  echo ""
else
  echo "No inventories found."
fi

# Retrieve organizations entries
declare organizations_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/organizations/")

# Retrieve the organizations count.
declare -i organizations_count="$(echo $organizations_reponse | jq -r '.results | length')"

# Delete organizations.
if [[ $organizations_count -gt 0 ]]; then

  echo -e "Deleting $organizations_count organizations.\n"

  for (( i=0; i<$organizations_count; i++ ))
  do
    echo "Deleting organizations [$(echo $organizations_reponse | jq -r ".results[$i].name")], id: [$(echo $organizations_reponse | jq -r ".results[$i].id")]"

    organizations_id="$(echo $organizations_reponse | jq -r ".results[$i].id")"

    curl -X DELETE -u "$awx_username:$awx_password" "http://$awx_host/api/v2/organizations/$organizations_id/"
  done
  echo ""
else
  echo "No organizations found."
fi

# Retrieve credentials entries
declare credentials_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/credentials/")

# Retrieve the credentials count.
declare -i credentials_count="$(echo $credentials_reponse | jq -r '.results | length')"

# Delete credentials.
if [[ $credentials_count -gt 0 ]]; then

  echo -e "Deleting $credentials_count credentials.\n"

  for (( i=0; i<$credentials_count; i++ ))
  do
    echo "Deleting credentials [$(echo $credentials_reponse | jq -r ".results[$i].name")], id: [$(echo $credentials_reponse | jq -r ".results[$i].id")]"

    credentials_id="$(echo $credentials_reponse | jq -r ".results[$i].id")"

    curl -X DELETE -u "$awx_username:$awx_password" "http://$awx_host/api/v2/credentials/$credentials_id/"
  done
  echo ""
else
  echo "No credentials found."
fi

# Retrieve current jobs
declare unified_jobs_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/unified_jobs/?order_by=-finished&not__launch_type=sync")

# Retrieve the unified jobs count.
declare -i unified_jobs_count="$(echo $unified_jobs_reponse | jq -r '.results | length')"

# Delete unified jobs.
if [[ $unified_jobs_count -gt 0 ]]; then

  echo -e "Deleting $unified_jobs_count unified jobs.\n"

  for (( i=0; i<$unified_jobs_count; i++ ))
  do
    echo "Deleting jobs [$(echo $unified_jobs_reponse | jq -r ".results[$i].name")], id: [$(echo $unified_jobs_reponse | jq -r ".results[$i].id")]"

    unified_jobs_url="$(echo $unified_jobs_reponse | jq -r ".results[$i].url")"

    curl -X DELETE -u "$awx_username:$awx_password" "http://${awx_host}${unified_jobs_url}"
  done
  echo ""
else
  echo "No unified jobs found."
fi

echo ""
