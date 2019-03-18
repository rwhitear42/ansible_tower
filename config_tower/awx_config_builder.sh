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

declare awx_host="10.52.206.88"
declare awx_username="admin"
declare awx_password="password"

declare build_template_file="./awx_build_template.json"

declare build_config=$(cat $build_template_file)

declare organization_count=$(cat $build_template_file | jq '.organizations | length')
declare inventories_count=$(cat $build_template_file | jq '.inventories | length')
declare projects_count=$(cat $build_template_file | jq '.projects | length')
declare job_templates_count=$(cat $build_template_file | jq '.job_templates | length')

echo -e "\nPlanning to create the following:\n"
echo -e "$organization_count organizations."
echo -e "$inventories_count inventories."
echo -e "$projects_count projects."
echo -e "$job_templates_count job templates."

echo ""

echo -e "Creating organizations...\n"

for (( i=0; i<$organization_count; i++ ))
do
  echo "Creating organization: $(cat $build_template_file | jq ".organizations[$i].name")"

  declare post_data=$(cat $build_template_file | jq -r ".organizations[$i]")
  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/organizations/" > /dev/null
done




echo -e "\nCreating projects...\n"

for (( i=0; i<$projects_count; i++ ))
do
  declare project_name=$(cat $build_template_file | jq -r ".projects[$i].name")
  declare project_org=$(cat $build_template_file | jq -r ".projects[$i].organization")
  declare project=$(cat $build_template_file | jq -r ".projects[$i]")

  echo "Creating project: $project_name"

  # Replace organization name with its id.
  declare awx_organizations=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/organizations/")

  # Retrieve the job template count.
  declare -i awx_organizations_count="$(echo $awx_organizations | jq -r '.results | length')"

  declare -i organization_id=0
  for (( j=0; j<$awx_organizations_count; j++ ))
  do
    awx_org_name=$(echo $awx_organizations | jq -r ".results[$j].name")
    awx_org_id=$(echo $awx_organizations | jq -r ".results[$j].id")

    echo "awx_org_name: $awx_org_name"
    echo "project_org: $project_org"

    if [ $awx_org_name == $project_org ]; then
      echo "Found a match for $project_org"
      organization_id=$awx_org_id
      break;
    fi
  done

  #echo $project

  declare post_data=$(echo $project | jq -r ". | {name: .name, organization: $organization_id, scm_type: .scm_type, scm_url: .scm_url, scm_update_on_launch: .scm_update_on_launch}")

  echo $post_data

  echo "organization_id = $organization_id"

  echo -e "\n"

  #declare post_data=$(cat $build_template_file | jq -r ".projects[$i]")
  curl -s -X POST -H "Content-Type: application/json" -d "$post_data" -u "$awx_username:$awx_password" "http://$awx_host/api/v2/projects/" > /dev/null
  
done
