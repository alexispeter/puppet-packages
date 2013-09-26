define mount::entry ($source, $target = $name, $type = 'none', $options = 'defaults', $mount = false) {

  include 'mount::common'

  exec {"prepare ${target}":
    command => "mkdir -p ${target}",
    creates => $target,
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  }

  unless $type == 'none' {
    exec {"make ${target} read-only":
      command => "find '${target}' -type d -exec chmod -w {} \;; find '${target}' -type f -exec chmod -w {} \;;",
      unless => "mountpoint ${target}",
      path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      require => Exec["prepare ${target}"],
      before => Mount[$target],
    }
  }

  mount {$target:
    ensure => present,
    fstype => $type,
    device => $source,
    dump => '0',
    pass => '0',
    options => $options,
    require => Exec["prepare ${target}"],
  }

  cron {"mount-check ${target}":
    command => "/usr/sbin/mount-check.sh ${target}",
    user => 'root',
    require => [File['/usr/sbin/mount-check.sh'], Mount[$target]]
  }

  if $mount {
    exec {"/usr/sbin/mount-check.sh ${target}":
      command => "/usr/sbin/mount-check.sh ${target}",
      refreshonly => true,
      require => File['/usr/sbin/mount-check.sh'],
      subscribe => Mount[$target],
    }
  }
}