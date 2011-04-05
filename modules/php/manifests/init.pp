class php {
    
    define installPhp5Base(
	$php5version="latest",
	$php5commonversion="latest",
	$cliversion="latest",
	$cgiversion="latest",
	$pearversion="latest"
    )
    {
	package {
	    "php5":
		ensure => $php5version,
	}
	
	package {
	    "php5-common":
		ensure  => $php5commonversion,
		require => Package["php5"]
	}
	
	package {
	    "php5-cli":
		ensure  => $cliversion,
		require => Package["php5-common"]
	}
	
	package {
	    "php5-cgi":
		ensure  => $cgiversion,
		require => Package["php5-common"]
	}
	
	package {
	    "php-pear":
		ensure => $pearversion,
		require => Package["php5-common"]
	}
    }
    
    define installApacheModule($version="latest")
    {
	package {
	    "libapache2-mod-php5":
		ensure => $version
	}
    }
    
    define setup() {
	$packagelist = [
	    "php5-svn",
#	    "php5-dev",
	    "php5-gd",
	    "php5-mcrypt",
	    "php5-curl",
	    "php5-xsl",
	    "php5-memcache",
	    "php5-memcached",
	    "php5-mysql",
	    "php5-sqlite",
	    "php-apc",
#	    "php5-imagick",
	    "php5-xmlrpc",
	]
	package {
	    $packagelist:
		ensure => installed
    	}
    }
}

class php::pear {
    define install()
    {
	package {
	    $name:
		provider => pear,
		ensure   => installed
	}
    }
}

class php::config {
    $confdir = "/etc/php5"
    
    file {
	"$confdir/apache2/php.ini":
	    source => "puppet:///modules/php/apache2-php.ini",
	    ensure => "present",
	    replace => true,
	    owner => "root",
	    group => "www-data",
	    require => Package["libapache2-mod-php5"],
	    notify => Service["apache2"]
    }
    
    file {
	"$confdir/cli/php.ini":
	    source => "puppet:///modules/php/cli-php.ini",
	    ensure => "present",
	    replace => true,
	    owner => "root",
	    group => "www-data",
	    require => Package["php5-cli"],
	    notify => Service["apache2"]
    }
    
    file {
	"$confdir/cgi/php.ini":
	    source => "puppet:///modules/php/cgi-php.ini",
	    ensure => "present",
	    replace => true,
	    owner => "root",
	    group => "www-data",
	    require => Package["php5-cgi"],
	    notify => Service["apache2"]
    }
    
    file {
	"$confdir/conf.d":
	    source => "puppet:///modules/php/conf.d",
	    ensure => "present",
	    owner => "root",
	    group => "www-data",
	    replace => true,
	    recurse => true,
	    notify => Service["apache2"],
    }
    
}