node master.puppet {
  file { '/etc/puppetlabs/puppet/autosign.conf':
    ensure => file,
    content => "slave1.puppet",    
  }
  
  firewalld::custom_service { 'puppet':
    short => 'puppet',
    description => 'Puppet Client access Puppet Server',
	port => {
            'port'     => '8140',
            'protocol' => 'tcp',
    },
  }
}
