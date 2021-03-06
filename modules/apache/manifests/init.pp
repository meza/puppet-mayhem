class apache::server {

    define setup(
	$version="latest",
	$modsecurityversion="latest"
    ) {

	package {
	    "apache2":
		ensure => $version,
	} -> package {
	    "libapache-mod-security":
		ensure  => $modsecurityversion,
	} -> service {
	    "apache2":
		ensure     => running,
		hasrestart => true,
		hasstatus  => true
	}

	file {
	    "/etc/apache2/mods-available/mod-security.conf":
		ensure  => present,
		source  => "puppet:///apache/mod-security.conf",
		require => [Package["apache2"],Package["libapache-mod-security"]]
	}
	
	file {
	    "/etc/apache2/mods-enabled/mod-security.conf":
		ensure  => symlink,
		replace => true,
		target  => "/etc/apache2/mods-available/mod-security.conf",
		require => [Package["apache2"],File["/etc/apache2/mods-available/mod-security.conf"],Package["libapache-mod-security"]],
		notify  => Service["apache2"],
	}
	
	file {
	    "/etc/apache2/mods-enabled/rewrite.load":
		ensure  => symlink,
		replace => true,
		target  => "/etc/apache2/mods-available/rewrite.load",
		require => Package["apache2"],
		notify  => Service["apache2"],
	}

        file {
	    "/etc/apache2/mods-enabled/vhost_alias.load":
		ensure  => symlink,
		replace => true,
		target  => "/etc/apache2/mods-available/vhost_alias.load",
		require => Package["apache2"],
		notify  => Service["apache2"],
	}

	file {
	    "/var/www":
		ensure  => directory,
		owner   => "www-data",
		group   => "www-data",
		mode    => 0775,
		require => Package["apache2"]
	}


    }

    define vhost( $host="*", $port="80", $root="", $phpinidir="/etc/php5/apache2") {
	
	if $root == "" {
	    $docroot    = "/var/www/$name"
	} else {
	    $docroot = $docroot
	}
	$errorLog   = "/var/log/apache2/$name-error.log"
	$accessLog  = "/var/log/apache2/$name-access.log"
	$logFiles   = [$errorLog, $accessLog]
	$configFile = "/etc/apache2/sites-available/$name.conf"

	file {
	    $docroot:
		ensure  => "directory",
		owner   => "www-data",
		group   => "www-data",
		mode    => 775,
		require => Package["apache2"],
	}

	file {
	    $logFiles:
		ensure  => "present",
		owner   => "root",
		group   => "www-data",
		require => Package["apache2"]
	}

	file {
	    $configFile:
		ensure  => "present",
		owner   => "root",
		group   => "www-data",
		mode    => 664,
		content => template("apache/vhost.conf.erb"),
		require => Package["apache2"]
	}

	file {
	    "/etc/apache2/sites-enabled/$name.conf":
		ensure  => symlink,
		target  => $configFile,
		require => [
		    File["$configFile"], 
		    File["$errorLog"], 
		    File["$accessLog"], 
		    File["$docroot"], 
		    Package["apache2"]
		],
		notify  => Service["apache2"]
	}

    }
}