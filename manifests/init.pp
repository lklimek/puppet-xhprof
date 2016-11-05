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
# [*ensure*]
#   present, absent (absent only disables the module)
#
# === Examples
#
#   class { 'xhprof': }
#
# === Requirements
#
# This class requires the apache class from PuppetLabs.
class xhprof($version = '0.9.4', $ensure = 'present', $manage_packages = true) {
  Package { [gcc, 'gcc-c++', make, 'openssl-devel', 'which', 'file', 're2c']:}

  exec { 'xhprof-install':
    command => "/usr/bin/pecl install pecl.php.net/xhprof-$version",
    creates => '/usr/share/pear/xhprof_html',
    require => [
        # Package['build-essential'], 
        Package['gcc'],
        Package['php56w-pear']
    ],
  }

  file { '/etc/php.d/xhprof.ini':
    source  => 'puppet:///modules/xhprof/xhprof.ini',
    require => Exec['xhprof-install'],
    notify  => Service['httpd'],
    ensure => $ensure,
  }

  apache::vhost { 'xhprof.drupal.dev':
    docroot     => '/usr/share/pear/xhprof_html',
    port        => '1280',
    ssl         => false,
    serveradmin => 'admin@localhost.com',
    override    => 'All',
    require     => Exec['xhprof-install'],
    ensure      => $ensure,
  }
}
