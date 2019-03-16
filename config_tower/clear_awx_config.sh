#!/usr/bin/env bash

declare awx_host="10.52.206.88"
declare awx_username="admin"
declare awx_password="password"

# This script is disruptive. Ensure that the end user is aware of what they are doing.
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

    curl -X DELETE -u "$awx_username:$awx_password" "http://$awx_host/api/v2/job_templates/$template_id/"
  done

else
  echo "No job templates found."
fi

# Check again to ensure that templates were removed. $template_count should be zero.
template_reponse=$(curl -s -u $awx_username:$awx_password "http://$awx_host/api/v2/job_templates/")
template_count="$(echo $template_reponse | jq -r '.results | length')"

if [[ $template_count -gt 0 ]]; then
  echo "Failed to remove job templates!"
fi

echo ""
