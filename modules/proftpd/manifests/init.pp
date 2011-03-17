class proftpd {

    define setup($database, $username, $password) {
        package { ["proftpd", "proftpd-mod-mysql"]:
	    ensure => "installed",
	}
    
	service {
	    "proftpd":
		ensure => running,
		enable => true,
		require => [Package["proftpd"], Service["mysql"]]
	}

	mysql::server::mysqldb { 
	    $database :
		user => $proftpd_username,
    		password => $proftpd_password,
    		require => Service["mysql"]
	}	
	
	group {
	    "ftpgroup":
		gid    => 2001,
		ensure => "present"
	}
	
	user {
	    "ftpuser":
		uid => 2001,
		gid => 2001,
		ensure => "present",
		comment => "proftpd user",
		shell => "/bin/null"
	}
    
        file {
    	    "/etc/proftpd/modules.conf":
		ensure => "present",
		content => template("proftpd/modules.conf.erb"),
		require => Package["proftpd"]
	}
    
	file {
	    "/etc/proftpd/proftpd-schema.sql":
		require => [Package["proftpd"], User["ftpuser"]],
    		ensure => "present",
        	owner => "root",
        	group => "root",
        	source => "puppet:///proftpd/database/schema.sql",
	}
    
	mysql::server::feedDatabase {
	    "$database-schema":
		database => $database,
        	source => "/etc/proftpd/proftpd-schema.sql",
		username => $username,
        	password => $password,
        	require => [File["/etc/proftpd/proftpd-schema.sql"], Service["mysql"]]
	}
    
        $servername = "ftp server"
        
	file {
	    "/etc/proftpd/proftpd.conf":
		ensure => "present",
		content => template("proftpd/proftpd.conf.erb"),
		require => [
		    Package["proftpd"], 
		    Service["mysql"], 
		    File["/etc/proftpd/modules.conf"], 
		    User["ftpuser"], 
		    Mysql::Server::Mysqldb["$database"],
		    Mysql::Server::Feeddatabase["$database-schema"]
		],
		notify => Service["proftpd"]
	}
    }

    define addFtpUser ( $ftpuser, $ftppass, $homedir, $proftpd_database, $proftpd_username, $proftpd_password) {
	mysql::server::runQuery {
	    "add $ftpuser group":
		database => $proftpd_database,
		username => $proftpd_username,
		password => $proftpd_password,
		query => "INSERT INTO `ftpgroup` (`groupname`, `gid`, `members`) VALUES (\"www-data\", 33, \"$ftpuser\") ON DUPLICATE KEY UPDATE members=CONCAT(members,\", \",VALUES(members));"
	}
	
	mysql::server::runQuery {
	    "add $ftpuser":
		database => $proftpd_database,
		username => $proftpd_username,
		password => $proftpd_password,
		require  => [
		    Mysql::Server::Runquery["add $ftpuser group"]
		],
		query => "INSERT INTO `ftpuser` (`userid`, `passwd`, `uid`, `gid`, `homedir`, `shell`, `count`, `accessed`, `modified`) VALUES (\"$ftpuser\", \"$ftppass\", 2001, 33, \"$homedir\", \"/sbin/nologin\", 0, \"\", \"\") ON DUPLICATE KEY UPDATE userid=VALUES(userid);"
	}
    }
}
