node 'pnb.vagrant.example' {

  class { 'java': }

  include apache

  apache::vhost { 'personal_site': 
    port    => 80,
    docroot => '/var/www/personal',
    options => 'Indexes MultiViews',
  }
}
