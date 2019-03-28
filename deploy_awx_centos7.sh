#!/bin/bash

###############################################################################
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
# 1. LICENSE GRANT: Subject to the terms and conditions of this License, Cisco
#    hereby grants to you a perpetual, worldwide, non-exclusive,
#    non-transferable, non-sublicensable, royalty-free license to copy and modify
#    the Sample Code in source code form, and compile and redistribute the Sample
#    Code in binary/object code or other executable forms, in whole or in part,
#    solely for use with Cisco products and services. For interpreted languages
#    like Java and Python, the executable form of the software may include source
#    code and compilation is not required.
#
# 2. CONDITIONS: You shall not use the Sample Code independent of, or to
#    replicate or compete with, a Cisco product or service. Cisco products and
#    services are licensed under their own separate terms and you shall not use
#    the Sample Code in any way that violates or is inconsistent with those terms
#    (for more information, please visit: www.cisco.com/go/terms).
#
# 3. OWNERSHIP: Cisco retains sole and exclusive ownership of the Sample Code,
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
# 6. GENERAL: This License shall be governed by and interpreted in accordance
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
###############################################################################

###############################################################################
#
#  AWX Minimum requirements:
#
#  Ansible 2.4+
#  Docker
#  docker-py
#  GNU Make
#  Git 1.8.4+
#  Node 8.x+ LTS version
#  NPM 6.x+ LTS
#
###############################################################################

declare http_proxy=""
declare https_proxy=""
declare no_proxy=""


if [[ $# -ge 1 ]]; then
  while [[ $1 ]]; do
    if [[ $1 == "-h" ]]; then
      echo -e "\n  Usage: sudo ./deploy_awx_centos7.sh"
      echo -e "\n  Options: --http_proxy http://myproxy:port"
      echo -e "           --https_proxy http://myproxy:port"
      echo -e "           --no_proxy domains,ip_addresses"
      echo -e "\n  e.g. sudo ./deploy_awx_centos7.sh --https_proxy http://proxy.esl.cisco.com:80 --no_proxy cisco.com,192.168.3.1\n"
      exit 0
    elif [[ $1 == "--http_proxy" ]]; then
      shift
      http_proxy="$1"
      continue
    elif [[ $1 == "--no_proxy" ]]; then
      shift
      no_proxy="$1"
      continue
    elif [[ $1 == "--https_proxy" ]]; then
      shift
      https_proxy="$1"
      continue
    fi
    shift
  done
fi

if ! [ $(id -u) = 0 ]; then
  echo -e "\nThis script requires root privileges.\n"
  echo -e "\n  Usage: sudo ./deploy_awx_centos7.sh"
  echo -e "\nOptions: --http_proxy http://myproxy:port"
  echo -e "         --https_proxy http://myproxy:port"
  echo -e "         --no_proxy domains,ip_addresses"
  echo -e "\ne.g. sudo ./deploy_awx_centos7.sh --https_proxy http://proxy.esl.cisco.com:80 --no_proxy cisco.com,192.168.3.1\n"
  exit 0
fi

declare sudo_user_homedir="$(eval echo ~${SUDO_USER})"
declare start_time=$(date +'%d:%m:%Y %H:%M')

echo "###############################################################################"
echo "#"
if [[ ${#https_proxy} -eq 0 ]]; then
  echo "# No HTTPS proxy configured."
else
  echo "# HTTPS proxy [$https_proxy] configured."
fi
echo "#"
if [[ ${#http_proxy} -eq 0 ]]; then
  echo "# No HTTP proxy configured."
else
  echo "# HTTP proxy [$http_proxy] configured."
fi
echo "#"
if [[ ${#no_proxy} -eq 0 ]]; then
  echo "# No entries for no proxy configured."
else
  echo "# no proxy [$no_proxy] configured."
fi
echo "#"
echo "###############################################################################"

if [ -f /etc/yum.repos.d/cliqr.repo ]; then
  echo -e "\nThis appears to be a CloudCenter deployed system. Disabling the cliqr repo."

  if [ $(grep "enabled" /etc/yum.repos.d/cliqr.repo) == "enabled=1" ]; then
    echo -e "cliqr repo is currently enabled. Disabling.\n"
    sed -i "s/enabled=1/enabled=0/" /etc/yum.repos.d/cliqr.repo 2>&1
  elif [ $(grep "enabled" /etc/yum.repos.d/cliqr.repo) == "enabled=0" ]; then
    echo -e "cliqr repo is already disabled. Skipping.\n"
  else
    echo -e "Couldn't find enabled status in cliqr repo. Please check /etc/yum.repos.d/cliqr.repo. Exiting.\n"
    exit 1
  fi
fi

if [ ! $http_proxy == "" ]; then
  echo -e "\nSetting HTTP proxy: $http_proxy"
  if [[ ! $(egrep "^http_proxy=.*$" /etc/environment) ]]; then
    echo "http_proxy=$http_proxy" >> /etc/environment
  else
    echo "http_proxy already configured. Skipping."
  fi
fi

if [ ! $https_proxy == "" ]; then
  echo "Setting HTTPS proxy: $https_proxy"
  if [[ ! $(egrep "^https_proxy=.*$" /etc/environment) ]]; then
    echo "https_proxy=$https_proxy" >> /etc/environment
  else
    echo "https_proxy already configured. Skipping."
  fi
fi

if [ ! $no_proxy == "" ]; then
  echo "Setting no proxy: $no_proxy"
  if [[ ! $(egrep "^no_proxy=.*$" /etc/environment) ]]; then
    echo "no_proxy=$no_proxy" >> /etc/environment
  else
    echo "no_proxy already configured. Skipping."
  fi
fi

# Export the new environment variables for curl, used later in this script.
for line in $( cat /etc/environment )
do
  export $line
done


if [ ! $https_proxy == "" ]; then
  echo -e "\nConfiguring proxy in /etc/yum.conf."
  if [[ ! $(egrep "^proxy=.*$" /etc/yum.conf) ]]; then
    echo "proxy=$https_proxy" >> /etc/yum.conf
  else
    echo -e "Yum proxy already configured. Skipping."
  fi
fi

# Check if Ansible is running and install/upgrade as required.
echo -e "\nInstalling Ansible...\n"

declare -i ansible_min_reqd_major_version=2
declare -i ansible_min_reqd_minor_version=4

#declare ansible_revision=( $(ansible --version | egrep "^ansible" | awk '{print $2}' | awk -F "." '{print $1, $2}') )
declare ansible_installed="$(which ansible 2>/dev/null)"

if [ ! $ansible_installed == "" ]; then
  echo "Ansible is installed. Checking versions..."
  declare -i ansible_major_release=$(ansible --version | egrep "^ansible" | awk '{print $2}' | awk -F "." '{print $1}')
  if [[ $ansible_major_release -gt $ansible_min_reqd_major_version ]]; then
    echo "Ansible major version [$ansible_major_release] is above the minimum required ${ansible_min_reqd_major_version}."
  elif [[ $ansible_major_release -lt $ansible_min_reqd_major_version ]]; then
    yum -y upgrade ansible 2>&1
    if [ $? -eq 0 ]; then
      echo -e "\nUpgraded Ansible.\n"
    else
      echo -e "\nFailed to upgrade Ansible. Exiting.\n"
      exit 1
    fi
  else
    echo "Ansible major version [$ansible_major_release] matches the minimum required ${ansible_min_reqd_major_version}. Checking minor version."
    declare -i ansible_minor_release=$(ansible --version | egrep "^ansible" | awk '{print $2}' | awk -F "." '{print $2}')
    if [[ $ansible_minor_release -ge $ansible_min_reqd_minor_version ]]; then
      echo "Ansible minor version [$ansible_minor_release] is above the minimum required ${ansible_min_reqd_minor_version}."
    else
      yum -y upgrade ansible 2>&1
      if [ $? -eq 0 ]; then
        echo -e "\nUpgraded Ansible.\n"
      else
        echo -e "\nFailed to upgrade Ansible. Exiting.\n"
        exit 1
      fi
    fi
  fi
else
  yum -y install ansible 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled Ansible.\n"
  else
    echo -e "\nFailed to install Ansible. Exiting.\n"
    exit 1
  fi
fi

# Check whether epel.repo is installed already and install if not.
echo -e "\nInstalling epel-release...\n"

declare epel_repo_installed="$(ls /etc/yum.repos.d/epel.repo 2>/dev/null)"

if [ ! $epel_repo_installed == "" ]; then
  echo "/etc/yum.repos.d/epel.repo already exists. Skipping..."
else
  yum -y install epel-release 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled epel-release.\n"
  else
    echo -e "\nFailed to install epel-release. Exiting.\n"
    exit 1
  fi
fi

echo -e "\nUpdating CentOS...\n"
yum -y update 2>&1
if [ $? -eq 0 ]; then
  echo -e "\nUpdated CentOS.\n"
else
  echo -e "\nFailed to update CentOS. Exiting.\n"
  exit 1
fi

# Check whether pip is installed already and install if not.
echo -e "\nInstalling Python pip...\n"

declare pip_installed="$(which pip 2>/dev/null)"

if [ ! $pip_installed == "" ]; then
  echo "pip installed already. Skip to upgrade for latest release."
else
  yum -y install python-pip 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled Python pip\n"
  else
    echo -e "\nFailed to install Python pip. Exiting.\n"
    exit 1
  fi
fi

echo -e "\nUpgrading Python pip...\n"
if [ ! $https_proxy == "" ]; then
    pip install --upgrade pip --proxy $https_proxy 2>&1
else
    pip install --upgrade pip 2>&1
fi

if [ $? -eq 0 ]; then
  echo -e "\nUpgraded Python pip\n"
else
  echo -e "\nFailed to upgrade Python pip. Exiting.\n"
  exit 1
fi


: << EOF
echo -e "\nInstalling Docker...\n"

declare docker_installed="$(which docker 2>/dev/null)"

if [ ! $docker_installed == "" ]; then
  echo "Docker already installed. Skipping..."
else
  yum -y install docker python-docker 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled Docker\n"
  else
    echo -e "\nFailed to install Docker. Exiting.\n"
    exit 1
  fi
fi
EOF

echo -e "\nInstalling Docker...\n"

declare docker_installed="$(which docker 2>/dev/null)"

if [ ! $docker_installed == "" ]; then
  echo "Docker already installed. Skipping..."
else
  pip install docker 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled Docker\n"
  else
    echo -e "\nFailed to install Docker. Exiting.\n"
    exit 1
  fi
fi

echo -e "\nInstalling Docker Compose...\n"

declare compose_installed="$(which docker-compose 2>/dev/null)"

if [ ! $compose_installed == "" ]; then
  echo "Docker Compose already installed. Skipping..."
else
  pip install docker-compose 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled Docker Compose\n"
  else
    echo -e "\nFailed to install Docker Compose. Exiting.\n"
    exit 1
  fi
fi

echo -e "\nInstalling net-tools...\n"
yum -y install net-tools 2>&1
if [ $? -eq 0 ]; then
  echo -e "\nInstalled net-tools\n"
else
  echo -e "\nFailed to install net-tools. Exiting.\n"
  exit 1
fi


echo -e "\nInstalling Development Tools...\n"
yum -y group install "Development Tools" 2>&1
if [ $? -eq 0 ]; then
  echo -e "\nInstalled Development Tools\n"
else
  echo -e "\nFailed to install Development Tools. Exiting.\n"
  exit 1
fi

echo -e "\nInstalling wget...\n"
yum -y install wget 2>&1
if [ $? -eq 0 ]; then
  echo -e "\nInstalled wget\n"
else
  echo -e "\nFailed to install wget. Exiting.\n"
  exit 1
fi

echo -e "\nConfiguring wget proxy settings (If required)...\n"

if [ ! $https_proxy == "" ]; then
  if [ ! "$(egrep "^https_proxy.*" /etc/wgetrc)" == "" ]; then
    echo "Proxy entry already exists in /etc/wgetrc."
    echo "Current proxy configuration: $(egrep "^https_proxy.*" /etc/wgetrc)"
    echo "Skipping..."
  else
    sed -i "s|#https_proxy = http:\/\/proxy.yoyodyne.com:18023|https_proxy = $https_proxy|" /etc/wgetrc 2>&1
  fi

  if [ ! "$(egrep "^use_proxy.*" /etc/wgetrc)" == "" ]; then
    echo "Proxy already enabled in /etc/wgetrc. Skipping..."
  else
    sed -i "s/#use_proxy = on/use_proxy = on/" /etc/wgetrc 2>&1
  fi
fi

echo -e "\nInstalling zlib-devel...\n"

declare zlib_installed="$(rpm -qa | grep zlib-devel)"

if [ ! $zlib_installed == "" ]; then
  echo "Development Tools already installed. Skipping..."
else
  yum -y install zlib-devel 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled zlib-devel\n"
  else
    echo -e "\nFailed to install zlib-devel. Exiting.\n"
    exit 1
  fi
fi

echo -e "\nInstalling curl-devel...\n"

declare curl_devel_installed="$(rpm -qa | grep curl-devel)"

if [ ! $curl_devel_installed == "" ]; then
  echo "Development Tools already installed. Skipping..."
else
  yum -y install curl-devel 2>&1
  if [ $? -eq 0 ]; then
    echo -e "\nInstalled curl-devel\n"
  else
    echo -e "\nFailed to install curl-devel. Exiting.\n"
    exit 1
  fi
fi

echo -e "\nInstalling tcpdump...\n"

declare tcpdump_installed="$(which tcpdump 2>/dev/null)"

if [ ! $tcpdump_installed == "" ]; then
  echo "tcpdump installed already. Skipping..."
else
  yum -y install tcpdump
fi

if [ $? -eq 0 ]; then
  echo -e "\nInstalled tcpdump\n"
else
  echo -e "\nFailed to install tcpdump. Exiting.\n"
  exit 1
fi

echo -e "\nInstalling jq...\n"

declare jq_installed="$(which jq 2>/dev/null)"

if [ ! $jq_installed == "" ]; then
  echo "jq installed already. Skipping..."
else
  yum -y install jq 2>&1
fi

if [ $? -eq 0 ]; then
  echo -e "\nInstalled jq\n"
else
  echo -e "\nFailed to install jq. Exiting.\n"
  exit 1
fi

echo -e "\nInstalling bind-utils...\n"

declare bind_utils_installed="$(which nslookup 2>/dev/null)"

if [ ! $bind_utils_installed == "" ]; then
  echo "bind-utils installed already. Skipping..."
else
  yum -y install bind-utils 2>&1
fi

if [ $? -eq 0 ]; then
  echo -e "\nInstalled bind-utils\n"
else
  echo -e "\nFailed to install bind-utils. Exiting.\n"
  exit 1
fi

echo -e "\nInstalling Git...\n"

declare -i git_min_reqd_major_version=1
declare -i git_min_reqd_minor_version=8
declare -i git_min_reqd_build_version=4

declare git_path="/usr/local/bin"

declare -i git_upgrade_required=0

#declare git_revision=( $(git --version | egrep "^git" | awk '{print $3}' | awk -F "." '{print $1, $2}') )
declare git_installed="$(ls $git_path/git 2>/dev/null)"

if [ ! $git_installed == "" ]; then
  echo "Git is installed. Checking versions..."
  declare -i git_major_release=$($git_path/git --version | egrep "^git" | awk '{print $3}' | awk -F "." '{print $1}')
  if [[ $git_major_release -gt $git_min_reqd_major_version ]]; then
    echo "Git major version [$git_major_release] is above the minimum required [${git_min_reqd_major_version}]."
  elif [[ $git_major_release -lt $git_min_reqd_major_version ]]; then
    git_upgrade_required=1
  else
    echo "Git major version [$git_major_release] matches the minimum required [${git_min_reqd_major_version}]. Checking minor version."
    declare -i git_minor_release=$($git_path/git --version | egrep "^git" | awk '{print $3}' | awk -F "." '{print $2}')
    if [[ $git_minor_release -gt $git_min_reqd_minor_version ]]; then
      echo "Git minor version [$git_minor_release] is above the minimum required [${git_min_reqd_minor_version}]."
    elif [[ $git_minor_release -lt $git_min_reqd_minor_version ]]; then
      git_upgrade_required=1
    else
      echo "Git minor version [$git_minor_release] matches the minimum required [${git_min_reqd_minor_version}]. Checking build version."
      declare -i git_build_release=$($git_path/git --version | egrep "^git" | awk '{print $3}' | awk -F "." '{print $3}')
      if [[ $git_build_release -ge $git_min_reqd_build_version ]]; then
        echo "Git build version [$git_build_release] is above or equal to the minimum required []${git_min_reqd_build_version}]."
      else
        git_upgrade_required=1
      fi
    fi
  fi
else
  git_upgrade_required=1
fi

if [[ $git_upgrade_required -eq 1 ]]; then

  declare gitfiles_dir=$(date +'%Y%m%d%H%M'_gitfiles)

  if [ -d $sudo_user_homedir/$gitfiles_dir ]; then
    echo "$sudo_user_homedir/$gitfiles_dir already exists. Exiting."
    exit 1
  else
    echo -e "\nDownloading Git source...\n"
    sudo -u $SUDO_USER mkdir $sudo_user_homedir/$gitfiles_dir
    wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.21.0.tar.gz -P $sudo_user_homedir/$gitfiles_dir
    if [ $? -eq 0 ]; then
      echo -e "\nDownloaded Git source\n"
    else
      echo -e "\nFailed to Download Git source. Exiting.\n"
      exit 1
    fi
    echo -e "\nCompiling Git...\n"
    cd $sudo_user_homedir/$gitfiles_dir
    sudo -u $SUDO_USER tar -zxvf ./git-2.21.0.tar.gz
    cd ./git-2.21.0
    sudo -u $SUDO_USER ./configure
    sudo -u $SUDO_USER make
    make install
  fi
else
  echo "Git upgrade not required. Skipping..."
fi

echo -e "\nInstalling nodejs and npm...\n"

cd $sudo_user_homedir

yum remove -y nodejs npm
wget https://rpm.nodesource.com/setup_10.x
bash ./setup_10.x
yum -y install nodejs
if [ $? -eq 0 ]; then
  echo -e "\nInstalled nodejs and npm\n"
else
  echo -e "\nFailed to install nodejs and npm. Exiting.\n"
  exit 1
fi

echo -e "\nStarting and persisting Docker service...\n"
systemctl start docker
#systemctl status docker
systemctl enable docker

# Configure Docker proxy if required.
if [ ! $https_proxy == "" ]; then
  if ! [ -d /etc/systemd/system/docker.service.d ]; then
    mkdir /etc/systemd/system/docker.service.d
  fi

  bash -c 'echo -e "[Service]\nEnvironment=\"HTTPS_PROXY=$https_proxy\"" > /etc/systemd/system/docker.service.d/http-proxy.conf'
  systemctl daemon-reload
  systemctl restart docker
fi

# Provide no sudo privileges to current user.
if [ ! $(cat /etc/group | egrep "^docker:") == "" ]; then
  echo -e "\nGroup docker already exists. No need to create..."
else
  groupadd docker
fi

usermod -aG docker $SUDO_USER

declare awx_dir=$(date +'%Y%m%d%H%M'_awx)

if [ -d $sudo_user_homedir/$awx_dir ]; then
  echo "Directory $sudo_user_homedir/$awx_dir aleady exists. Exiting."
  exit 1
else
  sudo -u $SUDO_USER mkdir $sudo_user_homedir/$awx_dir
fi

echo -e "\nGit Cloning AWX files...\n"

if [ ! $https_proxy == "" ]; then
  $git_path/git clone https://github.com/ansible/awx --config "http.proxy=$https_proxy" $sudo_user_homedir/$awx_dir
else
  $git_path/git clone https://github.com/ansible/awx $sudo_user_homedir/$awx_dir
fi

if [ $? -eq 0 ]; then
  echo -e "\nGit clone of AWX successful\n"
else
  echo -e "\nFailed to Git clone AWX. Exiting.\n"
  exit 1
fi

echo -e "\nInstalling AWX files...\n"
cd "$sudo_user_homedir/$awx_dir/installer"

# Build without preloaded data.
sed -i "s/create_preload_data=True/create_preload_data=False/" ./inventory

if [ ! $https_proxy == "" ]; then
  if [ ! $(egrep "^https_proxy=" ./inventory) == "" ]; then
    echo "https_proxy is already configured in inventory file. Skipping..."
  elif [ ! $(egrep "^#https_proxy=" ./inventory) == "" ]; then
    sed -i "s|^#https_proxy=.*$|https_proxy=$https_proxy|" ./inventory
  else
    echo "https_proxy=$https_proxy" >> ./inventory
  fi
fi

if [ ! $http_proxy == "" ]; then
  if [ ! $(egrep "^http_proxy=" ./inventory) == "" ]; then
    echo "http_proxy is already configured in inventory file. Skipping..."
  elif [ ! $(egrep "^#http_proxy=" ./inventory) == "" ]; then
    sed -i "s|^#http_proxy=.*$|http_proxy=$http_proxy|" ./inventory
  else
    echo "http_proxy=$http_proxy" >> ./inventory
  fi
fi

if [ ! $no_proxy == "" ]; then
  if [ ! $(egrep "^no_proxy=" ./inventory) == "" ]; then
    echo "no_proxy is already configured in inventory file. Skipping..."
  elif [ ! $(egrep "^#no_proxy=" ./inventory) == "" ]; then
    sed -i "s|^#no_proxy=.*$|no_proxy=$no_proxy|" ./inventory
  else
    echo "no_proxy=$no_proxy" >> ./inventory
  fi
fi

ansible-playbook -i inventory install.yml

if [ $? -eq 0 ]; then
  echo -e "\nAWX installation was successful\n"
else
  echo -e "\nFailed to install AWX. Exiting.\n"
  exit 1
fi

declare -i max_tries=10


echo -e "\nWaiting for AWX services to come up.\n"

for (( i=1; i<=$max_tries; i++ ))
do
  echo  "Checking to see if AWX services are up (Try [$i] of [$max_tries])."

  if [[ "$(docker logs awx_task | grep "Successfully registered instance awx")" ]]; then
    echo -e "\nAWX services are up.\n"
    break
  fi

  sleep 60
done

if [[ ! "$(docker logs awx_task | grep "Successfully registered instance awx")" ]]; then
  echo -e "\nAWX services are likely still coming up. Check with: sudo docker logs awx_task | grep \"Successfully registered instance awx\"\n"
fi

echo -e "\nInstalling tower-cli...\n"

declare tower_cli_installed="$(which tower-cli 2>/dev/null)"

if [ ! $tower_cli_installed == "" ]; then
  echo "tower-cli installed already. Skipping..."
else
  pip install ansible-tower-cli 2>&1
fi

if [ $? -eq 0 ]; then
  echo -e "\nInstalled tower-cli\n"
else
  echo -e "\nFailed to install tower-cli. Exiting.\n"
  exit 1
fi

echo -e "\nCreating and installing nginx SSL termination container...\n"

declare nginx_dir=$(date +'%Y%m%d%H%M'_nginx_ssl_termination)

sudo -u "$SUDO_USER" mkdir "$sudo_user_homedir"/"$nginx_dir"

cat > "$sudo_user_homedir"/"$nginx_dir"/Dockerfile << EOF
FROM nginx:alpine
RUN mkdir -p /etc/ssl
COPY awx.crt /etc/ssl/awx.crt
COPY awx.key /etc/ssl/awx.key
COPY nginx.conf /etc/nginx/nginx.conf
EOF

chown "$SUDO_USER":"$SUDO_USER" "$sudo_user_homedir"/"$nginx_dir"/Dockerfile

cat > "$sudo_user_homedir"/"$nginx_dir"/nginx.conf << EOF
user nginx;
worker_processes 1;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    server {
        listen              443;
        server_name         awx.uktme.cisco.com;
        ssl                 on;
        ssl_certificate     /etc/ssl/awx.crt;
        ssl_certificate_key /etc/ssl/awx.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
        location / {
            proxy_set_header    Host \$host;
            proxy_pass          http://awx_web:8052;
            proxy_http_version  1.1;
            proxy_set_header    Upgrade \$http_upgrade;
            proxy_set_header      Connection "upgrade";
        }
    }
}
EOF

chown "$SUDO_USER":"$SUDO_USER" "$sudo_user_homedir"/"$nginx_dir"/nginx.conf

cd "$sudo_user_homedir"/"$nginx_dir"

sudo -u $SUDO_USER openssl genrsa -out awx.key 2048
sudo -u $SUDO_USER openssl rsa -in awx.key -out awx.key
sudo -u $SUDO_USER openssl req -sha256 -new -key awx.key -out awx.csr -subj '/CN=awx.uktme.cisco.com'
sudo -u $SUDO_USER openssl x509 -req -sha256 -days 365 -in awx.csr -signkey awx.key -out awx.crt

docker build -t awx_https_proxy .

docker run -d --restart always --name awx_https_proxy -p 443:443 --link awx_web:awx_web awx_https_proxy

if [[ ! $(docker ps | grep awx_https_proxy) == "" ]]; then
  echo -e "\nInstalled and started nginx SSL termination container."
  echo -e "\nCheck with \"sudo docker ps\"\n"
else
  echo -e "\nnginx SSL termination container may not have started correctly."
  echo -e "\nCheck with \"sudo docker ps\"\n"
fi

declare end_time=$(date +'%d:%m:%Y %H:%M')

echo -e "Summary:\n"
echo "      Start time: $start_time"
echo "        End time: $end_time"
echo ""
echo " Ansible version: $(ansible --version | egrep "^ansible" | awk '{print $2}')"
echo "     pip version: $(pip --version | awk '{print $2}')"
echo "  Docker version: $(docker --version | awk '{print $3}')"
echo "     Git version: $(/usr/local/bin/git --version | awk '{print $3}')"
echo "  nodejs version: $(node --version | sed "s/^v\(.*\)/\1/")"
echo "     npm version: $(npm --version)"
echo ""
