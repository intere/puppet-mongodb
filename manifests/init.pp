class mongodb {
  # URL: http://fastdl.mongodb.org/linux/mongodb-linux-i686-2.4.1.tgz

  file { "/data":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 750
  }

  file { "/data/db":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 750
  }
  
  file { "/etc/init.d/mongod":
    source => "puppet:///modules/mongodb/mongod",
    owner => "root",
    group => "root",
    mode => 755,
  }
  
  file { "/etc/mongodb.conf":
    owner => "root",
    group => "root",
    mode => 755,
    source => "puppet:///modules/mongodb/mongod.conf"
  }
  
  package { "wget":
    ensure => "installed"
  }
  package { "tar":
    ensure => "installed"
  }

  exec {
    "apps_wget_mongo":
      command   => 
      "/usr/bin/wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-2.4.1.tgz -O /tmp/mongodb-linux-i686-2.4.1.tgz",
      logoutput => on_failure, 
      creates => "/tmp/mongodb-linux-i686-2.4.1.tgz",
      require   => [Package["wget"]];

    "apps_unzip_mongo":
      cwd     => "/var/local",
      command => "/bin/tar -xzf /tmp/mongodb-linux-i686-2.4.1.tgz",
      creates => "/var/local/mongodb-linux-i686-2.4.1",
      require => [ Package["tar"], Exec["apps_wget_mongo"] ];
    
    "start_mongodb":
    command => "/etc/init.d/mongod start",
    logoutput => on_failure,
    creates => "/var/run/mongodb.pid",
    require => [ Exec["apps_unzip_mongo"] ];
  }

  service { "mongodb":
    ensure => "running",
    enable => true,
    require => [ Exec["apps_unzip_mongo"] ]
  }
}