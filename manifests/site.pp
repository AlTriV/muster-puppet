node master.puppet {
  file { '/etc/puppetlabs/puppet/autosign.conf':
    ensure => file,
    content => "slave1.puppet\nslave2.puppet",    
  }
  
  exec { 'allow_puppet_connection':
    command => 'firewall-cmd --permanent --add-port=8140/tcp',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  include nginx_reverse_proxy
  
  exec { 'restart firewalld':
    command => 'systemctl restart firewalld.service',
    path => ['/usr/bin', '/usr/sbin',],
  }
}

node slave1.puppet {
  include web_server
  
  file { '/var/www/html/index.html':
    ensure  => present,
    source => "file:///vagrant/pages/index.html",
	replace => true,
  }
}


node slave2.puppet {
  include web_server

  $packages = [ 'php', 'php-fpm' ]
  package { $packages:
    ensure => 'installed',
  }
  
  -> service { 'php-fpm':
    ensure => running,
    enable => true,
  }
  
  -> exec { 'restart httpd':
    command => 'systemctl restart httpd',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  file { '/var/www/html/index.php':
    ensure  => present,
    source => "file:///vagrant/pages/index.php",
	replace => true,
  }
}


class web_server {
  package { 'httpd':
    ensure => 'installed',
  }
  
  exec { 'allow http':
    command => 'firewall-cmd --permanent --add-service=http',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  -> exec { 'restart firewalld':
    command => 'firewall-cmd --reload',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  service { 'httpd':
    ensure => running,
    enable => true,
  }
}

class nginx_reverse_proxy {
  package { 'nginx':
    ensure => 'installed',
  }
  
  -> file { '/etc/nginx/conf.d/':
    ensure  => present,
    source => "file:///vagrant/conf/revers_proxy.conf",
  }
  
  exec { 'allow port 8080':
    command => 'firewall-cmd --permanent --add-service=http',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  exec { 'allow port 9000':
    command => 'firewall-cmd --permanent --add-service=http',
    path => ['/usr/bin', '/usr/sbin',],
  }
  
  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
