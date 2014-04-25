# == Class: xhprof
#
# This class installs the xhprof package along with the necessary configuration
# files and a virtual host for accessing the output.
#
# === Parameters
#
# [*version*]
#   The version of the package to install. Defaults to '0.9.2'.
#
# === Examples
#
#   class { 'xhprof': }
#
# === Requirements
#
# This class requires the apache class from PuppetLabs.
class xhprof($version = '0.9.2') {  

  if ! defined(Package['build-essential']) {
    package { 'build-essential':
      ensure => present,
    }
  }

  if ! defined(Package['php5-common']) {
    package { 'php5-common':
      ensure => present,
    }
  }  

  if ! defined(Package['php-pear']) {
    package { 'php-pear':
      ensure => present,
    }
  }

  exec { 'xhprof-install':
    command => "pecl install pecl.php.net/xhprof-{$version}",
    creates => '/usr/share/php/xhprof_html',
    require => [Package['build-essential'], Package['php-pear']],
  }

  file { '/etc/php5/conf.d/xhprof.ini':
    source  => 'puppet:///modules/xhprof/xhprof.ini',
    require => Exec['xhprof-install'],
    notify  => Service['httpd'],
  }

  apache::vhost { 'xhprof.drupal.dev':
    docroot     => '/usr/share/php/xhprof_html',
    port        => '80',
    ssl         => false,
    serveradmin => 'admin@localhost.com',
    override    => 'All',
    require     => Exec['xhprof-install'],
  }
}
