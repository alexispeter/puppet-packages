class pulsar_rest_api (
  $version = latest,
  $port = 8080,

  $mongodb_host = 'localhost',
  $mongodb_port = 27017,
  $mongodb_db = 'pulsar-rest-api',

  $log_dir = '/var/log/pulsar-rest-api',

  $pulsar_repo = undef,
  $pulsar_branch = undef,

  $auth = undef,
) {

  require bower
  require pulsar
  require nodejs
  include pulsar_rest_api::service

  user { 'pulsar-rest-api':
    ensure     => present,
    system     => true,
    managehome => true,
    home       => '/home/pulsar-rest-api',
  }

  if $mongodb_host == 'localhost' {
    class { 'mongodb::role::standalone':
      hostname => $mongodb_host,
      port     => $mongodb_port,
    }
  }

  file { '/etc/pulsar-rest-api':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0644',
  }

  file { '/etc/pulsar-rest-api/config.yml':
    ensure  => file,
    content => template('pulsar_rest_api/config.yml'),
    owner   => 'pulsar-rest-api',
    group   => '0',
    mode    => '0440',
    before  => Package['pulsar-rest-api'],
    notify  => Service['pulsar-rest-api'],
  }

  file { $log_dir:
    ensure  => directory,
    owner   => 'pulsar-rest-api',
    group   => 'pulsar-rest-api',
    mode    => '0644',
    before  => Package['pulsar-rest-api'],
  }


  file { '/etc/init.d/pulsar-rest-api':
    ensure  => file,
    content => template("${module_name}/init.sh"),
    owner   => '0',
    group   => '0',
    mode    => '0755',
    before  => Package['pulsar-rest-api'],
    notify  => Service['pulsar-rest-api'],
  }

  package { 'pulsar-rest-api':
    ensure   => $version,
    provider => 'npm',
    require  => Class['nodejs'],
    notify   => [
      Service['pulsar-rest-api'],
      Exec['pulsar-rest-api bower install']
    ],
  }

  exec { 'pulsar-rest-api bower install':
    command     => 'bower install --production --allow-root',
    cwd         => '/usr/lib/node_modules/pulsar-rest-api',
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
  }

  sysvinit::script { 'pulsar-rest-api':
    content => template("${module_name}/init.sh")
    require => Package['pulsar-rest-api'],
  }

  logrotate::entry{ $module_name:
    content => template("${module_name}/logrotate")
  }

  @monit::entry { 'pulsar-rest-api':
    content => template("${module_name}/monit"),
    require => Service['pulsar-rest-api'],
  }
}
