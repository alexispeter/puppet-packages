class nodejs {

  require 'apt'

  apt::source { 'nodesource':
    entries => [
      "deb https://deb.nodesource.com/node_5.x ${::facts['lsbdistcodename']} main",
      "deb-src https://deb.nodesource.com/node_5.x ${::facts['lsbdistcodename']} main",
    ],
    keys    => {
      'nodesource' => {
        key     => '68576280',
        key_url => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
      }
    },
    require => Class['apt::transport_https'],
  }
  ->

  package { 'nodejs':
    ensure   => present,
    provider => 'apt',
  }

}
