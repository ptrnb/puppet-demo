node 'pnb.vagrant.example' {

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
      'tomcat-javadoc'],
  }

  tomcat::service { 'default':
    use_jsvc     => false,
    use_init     => true,
    service_name => 'tomcat',
  }

  file { 'proxy_ajp.conf' :
    path    => "/etc/httpd/conf.modules.d/proxy_ajp.conf",
    ensure  => present,
    source  => "/vagrant-share/config/proxy_ajp.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    notify  => Service['httpd'], # Apache will restart if this file is edited
    require => Package['httpd'],
  }
}
