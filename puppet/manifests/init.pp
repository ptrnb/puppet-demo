
# Set some useful variables
case $operatingsystem {
    centos, redhat: {
        $apache = 'httpd'
        $tomcat = 'tomcat'
        $tomcat_webapps = 'tomcat-webapps'
        $tomcat_admin = 'tomcat-admin-webapps'
        $tomcat_appbase = "/var/lib/${tomcat}/webapps"
        $tomcat_user = 'tomcat'
        $tomcat_group = 'tomcat'
        $conf_source = '/vagrant-share/config'
        $httpd_conf_dir = '/etc/httpd/conf.d'
        $ajp_conf = 'proxy_ajp.conf'
        $ssl_conf = 'force_ssl.conf'
        }
    default: { fail("Unrecognised operation system for web server") }
}

# Variables for building and deploying the HelloWorld war
$war = 'HelloWorld.war'
$war_source = '/vagrant-share/helloworld-src/'
$war_build = "${war_source}/target/${war}"
$war_destination = "${tomcat_appbase}/${war}"

# Setup Apache with SSL and tomcat connector
package { 'httpd' :
    name   => $apache,
    ensure => present,
}

package { 'mod_ssl':
    ensure  => present,
    require => Package['httpd'],
    notify  => Service['httpd'], # Apache will restart if this file is edited
}

file { 'proxy_ajp.conf' :
    path    => "${httpd_conf_dir}/${ajp_conf}",
    ensure  => present,
    source  => "${conf_source}/${ajp_conf}",
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    notify  => Service['httpd'], # Apache will restart if this file is edited
    require => Package['httpd'],
}

# Rewrite rules to force all requests to SSL
# Also remaps / to context root of our app ie. /HelloWorld
file { 'force_ssl.conf' :
    path    => "${httpd_conf_dir}/${ssl_conf}",
    ensure  => present,
    source  => "${conf_source}/${ssl_conf}",
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    notify  => Service['httpd'], # Apache will restart if this file is edited
    require => [
                Package['httpd'],
                Package['mod_ssl'],
                ],
}

service { 'httpd':
    name       => $httpd,
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
}

# Install ant to build HelloWorld war
package { 'ant':
    ensure => present,
}

# Install Tomcat
package { 'tomcat':
    name   => $tomcat,
    ensure => present,
}

package { 'tomcat-webapps':
    name    => $tomcat_webapps,
    ensure  => present,
    require => Package['tomcat'],
}

package { 'tomcat-admin':
    name    => $tomcat_admin,
    ensure  => present,
    require => Package['tomcat'],
}

service { 'tomcat' :
    name       => $tomcat,
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
}

# Build the WAR application
exec { 'build war':
    command => 'ant war',
    cwd     => $war_source,
    path    => ['usr/local/bin',
                '/usr/local/sbin',
                '/usr/bin',
                '/usr/sbin',
                '/bin',
                '/sbin'],
    logoutput => true,
    require   => [Package['ant'],
                  Package['tomcat']],
    unless    => "ls ${war_build}",
}

# Deploy the WAR application
file { 'HelloWorld.war':
    name    => $war_destination,
    ensure  => present,
    replace => true,
    source  => $war_build,
    owner   => $tomcat_user,
    group   => $tomcat_group,
    mode    => '664',
    notify  => Service['tomcat'], # Tomcat will restart if this file is updated
    require => Exec['build war'],
}

# Need this to allow access through bundled and active
# firewalld service in the puppet-labs/centos image
exec { 'firewalld add source':
    command => 'firewall-cmd --zone=trusted --add-source=10.0.2.0/24',
    cwd     => $war_source,
    path    => ['usr/local/bin',
                '/usr/local/sbin',
                '/usr/bin',
                '/usr/sbin',
                '/bin',
                '/sbin'],
    logoutput => true,
    require   => [File['proxy_ajp.conf'],
                  File['force_ssl.conf']],
}

# Order of execution
Package['httpd'] -> Service['httpd'] -> Package['ant'] -> Package['tomcat'] -> Service['tomcat'] -> Exec['firewalld add source']
