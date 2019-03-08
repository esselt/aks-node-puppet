#!/bin/sh
set -e

# Validate env variables
: "${GIT_REPO?Need to set env var GIT_REPO}"
: "${GIT_BRANCH?Need to set env var GIT_BRANCH}"

echo "ENV"
echo "GIT_REPO: $GIT_REPO"
echo "GIT_BRANCH: $GIT_BRANCH"
echo "DEBUG: $DEBUG"
echo

if [ -n "$DEBUG" ] 
then
  set -x
fi

install_ssh() {
  echo "Running apt-get update"
  apt-get update >/dev/null 2>&1

  echo "Installing OpenSSH Client"
  apt-get install -y openssh-client -y >/dev/null
}

install_git() {
  echo "Running apt-get update"
  apt-get update >/dev/null 2>&1

  echo "Installing Git"
  apt-get install -y git -y >/dev/null
}

create_id_rsa() {
  if [ ! $(which ssh) ]
  then
    install_ssh
  fi

  echo "Making sure /root/.ssh exist"
  mkdir -p /root/.ssh

  if [ -n "$GIT_SSH_PRIVATE_KEY" ]
  then

    echo "Creating root SSH private key"
    echo $GIT_SSH_PRIVATE_KEY | base64 -d > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa > /dev/null

    echo "Generating root SSH public key"
    ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub
    echo "Public key (id_rsa): $(cat /root/.ssh/id_rsa.pub)"
  fi

  echo "Getting GitHub SSH fingerprints"
  ssh-keyscan github.com >> /root/.ssh/known_hosts
}

clone_environment() {
  create_id_rsa

  if [ ! $(which git) ]
  then
    install_git
  fi

  if [ -d "/etc/puppetlabs/code" ]
  then
    timenow=$(date +%Y%m%d%H%M%S)
    echo "Backing up /etc/puppetlabs/code to /etc/puppetlabs/code.$timenow"
    mv /etc/puppetlabs/code /etc/puppetlabs/code.$timenow
  fi

  echo "Creating /etc/puppetlabs"
  mkdir -p /etc/puppetlabs

  echo "Cloning git repository $GIT_REPO from branch $GIT_BRANCH into /etc/puppetlabs/code"
  git clone $GIT_REPO /etc/puppetlabs/code -b $GIT_BRANCH > /dev/null
}

install_puppet() {
  . /etc/lsb-release
  majver=$DISTRIB_RELEASE

  case $majver in
    14.04) codename=trusty ;;
    16.04) codename=xenial ;;
    18.04) codename=bionic ;;
    *) echo "Release not supported" ;;
  esac
  echo "Detected Ubuntu Linux $majver (codename $codename)"

  echo "Adding repo for Puppet"
  wget -q "http://apt.puppetlabs.com/puppet-release-${codename}.deb" >/dev/null
  dpkg -i "puppet-release-${codename}.deb" >/dev/null
  rm -rf "puppet-release-${codename}.deb"

  echo "Running apt-get update"
  apt-get update >/dev/null 2>&1

  echo "Installing Puppet and its dependencies"
  apt-get install -y puppet-agent -y >/dev/null
  apt-get install -y apt-transport-https -y >/dev/null
}

run_puppet() {
  echo "Checking if Puppet is installed"
  if [ ! $(which puppet) ] || [ ! $(puppet --version | grep "^[5|6|7]") ]
  then
    install_puppet
  fi

  clone_environment

  echo "Running /opt/puppetlabs/bin/puppet apply -l /var/log/puppetlabs/puppet/apply.log /cron.pp"
  /opt/puppetlabs/bin/puppet apply -l /var/log/puppetlabs/puppet/apply.log /cron.pp
}

run_puppet
