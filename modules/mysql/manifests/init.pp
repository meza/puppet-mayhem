class mysql::server {

    define setup(
	$datadir="/var/lib/mysql", 
	$version="latest",
	$rootPasswd="",
	$mode="standalone",
	$serverId=0
	) {
    
	case $mode {
	    "standalone": {
		$template = "my.cnf.erb"
	    }
	    "server": {
		$template = "my.cnf.server.erb"
	    }
	    "slave": {
		$template = "my.cnf.slave.erb"
	    }
	    default: {
		fail("Mode $mode is not supported")
	    }
	}
	package { "mysql-server": 
	    name   => "mysql-server-5.1",
    	    ensure => $version
	}

	service { "mysql":
	    enable  => true,
	    ensure  => running,
	    require => [Package["mysql-server"]],
	}
	
        file { "$datadir/my.cnf":
    	    owner   => "mysql", group => "mysql",
    	    content => template("mysql/mysql/$template"),
	    notify  => Service["mysql"],
	    require => Package["mysql-server"],
	} -> file { "/etc/mysql/my.cnf":
	    replace => true,
	    ensure  => symlink,
	    notify  => Service["mysql"],
	    target  => "$datadir/my.cnf"
	}
    
	exec { "set-mysql-password":
	    unless  => "mysqladmin -uroot -p$rootPasswd status",
	    path    => ["/bin", "/usr/bin"],
	    command => "mysqladmin -uroot password $rootPasswd",
	    require => Service["mysql"],
	}
    }
    
    define mysqldb( $user, $password, $adminPassword ) {
	exec { "create-${name}-db":
	    unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
	    command => "/usr/bin/mysql -uroot -p\"$adminPassword\" -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
	    require => [Service["mysql"]]
	}
    }
    
    define feedDatabase ( $database, $source, $username, $password ) {
	file {
	    "/root/src-$name.sql":
		source => $source,
		ensure => present
	} -> exec {
	    "feed-${name}":
		onlyif  => "/usr/bin/test -z `/usr/bin/mysql -u$username -p\"$password\" $database -e \"show tables;\"`",
		command => "/usr/bin/mysql -u$username -p\"$password\" $database < /root/src-$name.sql",
	}
    }
    
    define runQuery ($query, $username, $password, $database="", unless="/bin/echo > /home") {
	exec { "query-$name":
	    unless  => $unless,
	    command => "/usr/bin/mysql -u$username -p\"$password\" -e'$query' $database"
	}
    }
    
    define addReplicationUser($repuser, $reppass, $adminuser, $adminpass, $host="%")
    {
	mysql::server::runQuery {
	    "replication-user: $repuser":
		unless   => "/usr/bin/mysql -u${repuser} -p${reppass} -e\"SELECT 1\"",
		query    => "CREATE USER \"$repuser\"@\"$host\" IDENTIFIED BY \"$reppass\"",
		username => $adminuser,
		password => $adminpass
	} -> mysql::server::runQuery {
	    "grant replication for $repuser":
		query    => "GRANT REPLICATION SLAVE ON *.* TO \"$repuser\"@\"$host\"",
		username => $adminuser,
		password => $adminpass
	}
    }


}
