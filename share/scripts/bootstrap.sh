#!/usr/bin/env bash

PUPPETLABS_REPO="https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm"

if [ "$EUID" -ne "0" ]; then
    echo "This bootstrap script must be run as root"
    exit 1
fi

# Install the puppetlabs repo details in the RPM database
echo "Configuring PuppetLabs repository details..."
repo_temp_path=$(mktemp)
wget --output-document=${repo_temp_path} ${PUPPETLABS_REPO} 2>/dev/null
rpm -i ${repo_temp_path} > /dev/null

# Install or upgrade puppet agent
yum upgrade -y puppet-agent > /dev/null

echo "Puppet installed"

# Install puppet modules
puppet module install puppetlabs/java --verbose --target-dir "/puppet/modules"
puppet module install puppetlabs/apache --verbose --target-dir "/puppet/modules"
puppet module install puppetlabs/tomcat --verbose --target-dir "/puppet/modules"
