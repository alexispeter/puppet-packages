class lightdm {

  require 'apt'

  package { 'lightdm':
    ensure   => present,
    provider => 'apt',
  }

  service { 'lightdm':
    enable   => true,
    require  => Package['lightdm'],
    provider => $::service_provider, # Workaround for https://github.com/cargomedia/puppet-packages/issues/1071
  }

  file { '/etc/lightdm/lightdm.conf.d':
    ensure  => directory,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    purge   => true,
    recurse => true,
    require => Package['lightdm'],
    notify  => Service['lightdm'],
  }

  file { '/usr/share/xsessions':
    ensure  => directory,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Service['lightdm'],
  }

}
