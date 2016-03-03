define janus::core::setup_dirs (
  $base_dir,
) {

  $config_dir = "${base_dir}/etc/janus"
  $ssl_config_dir = "${base_dir}/etc/janus/ssl"
  $plugins_folder = "${base_dir}/usr/lib/janus/plugins.enabled"
  $transports_folder = "${base_dir}/usr/lib/janus/transports.enabled"

  $base_dirs = "${base_dir}/etc ${base_dir}/var/lib ${base_dir}/var/log ${base_dir}/usr/lib/janus"

  exec { "Create base dirs in ${title}":
    provider    => shell,
    command     => "for i in ${base_dirs}; do mkdir -p \$i; done",
    unless      => "for i in ${base_dirs}; do if ! [ -d \$i ]; then exit 1; fi; done",
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  }
  ->

  file {
    [ $config_dir, "${config_dir}/ssl"]:
      ensure  => directory,
      owner   => '0',
      group   => '0',
      mode    => '0644',
      purge   => true,
      recurse => true,
      require => Exec["Create base dirs in ${title}"];
    [ $plugins_folder, $transports_folder ]:
      ensure  => directory,
      owner   => 'janus',
      group   => 'janus',
      mode    => '0644',
      require => Exec["Create base dirs in ${title}"];
    [ "${base_dir}/var/lib/janus", "${base_dir}/var/lib/janus/recordings", "${base_dir}/var/lib/janus/jobs" ]:
      ensure  => directory,
      owner   => 'janus',
      group   => 'janus',
      mode    => '0666',
      require => Exec["Create base dirs in ${title}"];
    "${base_dir}/var/log/janus":
      ensure  => directory,
      owner   => 'janus',
      group   => 'janus',
      mode    => '0644',
      require => Exec["Create base dirs in ${title}"];
  }
}
