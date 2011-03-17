class php {
    define setup() {
	$packagelist = [
	    "libapache2-mod-php5",
	    "php5",
	    "php5-svn",
	    "php5-dev",
	    "php5-cli",
	    "php5-cgi",
	    "php-pear",
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