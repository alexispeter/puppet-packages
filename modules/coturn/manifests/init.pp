class coturn (
  $realm,
  $port = 3478,
  $port_alt = 0,
  $listening_ip = [],
  $relay_ip = [],
  $external_ip = [],
  $no_multicast_peers = true,
  $relay_port_min = 49152,
  $relay_port_max = 65535,
  $mice = true,
  $static_user_accounts = [],
  $lt_cred_mech = true
) {

  require 'apt'
  require 'apt::source::cargomedia'

  class { 'ulimit':
    limits => [
      {
        'domain' => 'turnserver',
        'type' => '-',
        'item' => 'nofile',
        'value' => 65536,
      }
    ]
  }

  user { 'turnserver':
    ensure => present,
    system => true,
  }
  ->

  file {
    '/var/log/coturn':
      ensure => directory,
      owner  => 'turnserver',
      group  => 'turnserver',
      mode   => '0644';
    '/etc/coturn':
      ensure => directory,
      owner  => '0',
      group  => '0',
      mode   => '0644';
    '/var/log/coturn/turnserver.log':
      ensure => file,
      owner  => 'turnserver',
      group  => 'turnserver',
      mode   => '0644';
    '/etc/coturn/turnserver.conf':
      ensure  => file,
      content => template("${module_name}/config"),
      owner   => '0',
      group   => '0',
      mode    => '0644',
      notify  => Service['coturn'];
  }

  logrotate::entry{ $module_name:
    content => template("${module_name}/logrotate")
  }

  package { 'coturn':
    provider => 'apt',
  }
  ->

  daemon { 'coturn':
    binary  => '/usr/bin/turnserver',
    args    => "-c /etc/coturn/turnserver.conf -v -l /var/log/coturn/turnserver.log --simple-log --no-dtls --no-tls --no-stdout-log",
    user    => 'turnserver',
    require => [ File['/etc/coturn/turnserver.conf'], File['/var/log/coturn/turnserver.log'] ]
  }
}
