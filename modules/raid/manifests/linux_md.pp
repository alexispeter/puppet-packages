class raid::linux_md {

  require 'apt'

  file { '/etc/mdadm':
    ensure => directory,
    group  => '0',
    owner  => '0',
    mode   => '0755',
  }

  file { '/etc/mdadm/mdadm.conf':
    ensure  => file,
    content => template("${module_name}/linux_md/mdadm.conf"),
    group   => '0',
    owner   => '0',
    mode    => '0644',
    notify  => Service['mdadm'],
    before  => Package['mdadm'],
  }

  file { '/tmp/mdadm.preseed':
    ensure  => file,
    content => template("${module_name}/linux_md/mdadm.preseed"),
    mode    => '0644',
  }

  package { 'mdadm':
    ensure       => present,
    provider     => 'apt',
    responsefile =>  '/tmp/mdadm.preseed',
    require      => File['/tmp/mdadm.preseed'],
  }
  ->

  service { 'mdadm':
    hasstatus => false,
    enable    => true,
  }

  @monit::entry { 'mdadm-status':
    content => template("${module_name}/linux_md/monit.${::service_provider}.erb"),
    require => Service['mdadm'],
  }
}
