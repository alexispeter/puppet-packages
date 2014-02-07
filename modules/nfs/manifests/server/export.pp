define nfs::server::export($publicPath = $name, $localPath, $configuration, $owner = 'root', $group = 'root', $permissions = '640') {

  include 'nfs::server'

  $path = shellquote("/nfsexport${publicPath}")
  $lpath = shellquote($localPath)

  $filename = md5($name)

  exec {$lpath:
    command => "mkdir -p ${lpath}",
    creates => $lpath,
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  }
  ->

  mount::entry {$path:
    source => $localPath,
    options => 'bind',
    mount => true,
  }
  ->

  exec {$path:
    command => "chown ${owner}:${group} ${path} && chmod ${permissions} ${path}",
    creates => $path,
    path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  }
  ->


  file {"/etc/exports.d/${filename}":
    ensure => file,
    content => template('nfs/export'),
    owner => '0',
    group => '0',
    mode => '644',
    notify => Exec['/etc/exports'],
  }
}
