node 'pnb.vagrant.example' {

  case $operatingsystem {
      centos, redhat: {
          $tomcat = "tomcat"
          $tomcat_appbase = "/var/lib/${tomcat}"
          $conf_source = "/vagrant-share/config"
          $httpd_conf_dir = "/etc/httpd/conf.modules.d"
          $ajp_conf = "proxy_ajp.conf"
          $ssl_conf = "force_ssl.conf"
          $war = "HelloWorld.war"
          $war_source = "/vagrant-share/helloworld-src/"
          $war_build = "${war_source}/target/${war}"
          $war_destination = "${tomcat_appbase}/${war}"
          }
      default: { fail("Unrecognised operation system for web server") }
  }
  
  class { 'java': 
  }

  class { 'apache':
  }

  class { 'apache::mod::proxy':
  }

  class { 'apache::mod::proxy_ajp': 
  }

  class { 'tomcat': 
  }

  tomcat::instance {'default':
    install_from_source => false,
    package_name        => [
      'tomcat', 
      'tomcat-webapps',
      'tomcat-docs-webapp',
      'tomcat-javadoc',
      'tomcat-admin-webapps'],
  }

  tomcat::service { 'default':
    use_jsvc     => false,
    use_init     => true,
    service_name => 'tomcat',
  }

  package { 'ant':
      ensure => present,
  }

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
    require   => [Package['java'],
                  Package['ant'],
                  Package['tomcat']],
    unless => "ls ${war_build}",
  }

  tomcat::war { 'HelloWorld.war':
    catalina_base => $tomcat_appbase,
    war_source    => $war_build,
    require       => Exec['build war'],
    notify        => Service['tomcat'],
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

  class { 'firewall' :
  }

  firewall { '100 Allow inbound SSH':
    dport     => 22,
    proto    => tcp,
    action   => accept,
  }

  firewall { '110 Allow inbound SSH (v6)':
    dport     => 22,
    proto    => tcp,
    action   => accept,
    provider => 'ip6tables',
  }

  firewall { '200 allow http and https access':
    dport   => [80, 443],
    proto  => tcp,
    action => accept,
  }

  firewall { '210 allow http and https access (v6)':
    dport   => [80, 443],
    proto  => tcp,
    action => accept,
    provider => 'ip6tables',
  }
  
}

