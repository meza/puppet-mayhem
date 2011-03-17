class mysql::server {
    $mysql_datadir = "/var/lib/mysql"
    
    define setup($datadir) {
    
	package { "mysql-server": 
    	    ensure => installed
	}

	service { "mysql":
	    enable  => true,
	    ensure  => running,
	    require => [Package["mysql-server"]],
	}
	
        file { "$datadir/my.cnf":
    	    owner   => "mysql", group => "mysql",
    	    content => template("mysql/mysql/my.cnf.erb"),
	    notify  => Service["mysql"],
	    require => Package["mysql-server"],
	}
    
	file { "/etc/my.cnf":
	    require => File["$datadir/my.cnf"],
	    ensure  => "$datadir/my.cnf",
	}
    
	exec { "set-mysql-password":
	    unless  => "mysqladmin -uroot -p$mysql_password status",
	    path    => ["/bin", "/usr/bin"],
	    command => "mysqladmin -uroot password $mysql_password",
	    require => Service["mysql"],
	}
    }
    
    define mysqldb( $user, $password ) {
	exec { "create-${name}-db":
	    unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
	    command => "/usr/bin/mysql -uroot -p\"$mysql_password\" -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
	    require => [Service["mysql"]]
	}
    }
    
    define feedDatabase ( $database, $source, $username, $password ) {
	exec {	"feed-${name}":
	    command     => "/usr/bin/mysql -u$username -p\"$password\" $database < $source",
	    require     => [File[$source], Service["mysql"]],
	    refreshonly => true,
	    subscribe   =>File[$source]
	}
    }
    
    define runQuery ( $database, $query, $username, $password) {
	exec { "query-$name":
	    command => "/usr/bin/mysql -u$username -p\"$password\" -e'$query' $database",
	    require => [Service["mysql"]]
	}
    }


}
