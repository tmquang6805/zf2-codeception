if $php_values == undef { $php_values = hiera('php', false) }
if $xhprof_values == undef { $xhprof_values = hiera('xhprof', false) }
if $apache_values == undef { $apache_values = hiera('apache', false) }
if $nginx_values == undef { $nginx_values = hiera('nginx', false) }

include puphpet::params

if hash_key_equals($xhprof_values, 'install', 1)
  and hash_key_equals($php_values, 'install', 1)
{
  if $::operatingsystem == 'ubuntu'
    and $::lsbdistcodename in ['lucid', 'maverick', 'natty', 'oneiric', 'precise']
  {
    apt::key { '8D0DC64F': key_server => 'hkp://keyserver.ubuntu.com:80' }
    apt::ppa { 'ppa:brianmercer/php5-xhprof': require => Apt::Key['8D0DC64F'] }
  }

  if hash_key_equals($apache_values, 'install', 1) {
    $xhprof_webroot_location = '/var/www/default'
    $xhprof_webserver_service = 'httpd'
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    $xhprof_webroot_location = $puphpet::params::nginx_webroot_location
    $xhprof_webserver_service = 'nginx'
  } else {
    $xhprof_webroot_location = $xhprof_values['location']
    $xhprof_webserver_service = undef
  }

  if ! defined(Package['graphviz']) {
    package { 'graphviz':
      ensure => present,
    }
  }

  class { 'puphpet::php::xhprof':
    php_version       => $php_values['version'],
    webroot_location  => $xhprof_webroot_location,
    webserver_service => $xhprof_webserver_service
  }
}

