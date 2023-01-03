node master.puppet {
  file { '/etc/puppetlabs/puppet/autosign.conf':
    ensure => file,
    content => "slave1.puppet",    
  }
  
  exec { 'allow_puppet_connection':
    command => 'firewall-cmd --permanent --add-port=8140/tcp',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  service { 'firewalld':
    ensure => running,
  }
}
