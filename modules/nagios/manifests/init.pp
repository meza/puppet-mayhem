class nagios::server {

    define fetch($nagiosVersion, $nagiosPluginsVersion) {
	file {
	    "/opt/nagios-$nagiosVersion.tar.gz":
		source  => "puppet:///nagios/nagios-$nagiosVersion.tar.gz",
		ensure  => present
	}
	file {
	    "/opt/nagios-plugins-$nagiosPluginsVersion.tar.gz":
		source  => "puppet:///nagios/nagios-plugins-$nagiosPluginsVersion.tar.gz",
		ensure  => present
	}
    }

    define install($nagiosVersion, $nagiosPluginsVersion) {
	exec {
	    "unpack nagios":
		cwd     => "/opt",
		command => "/bin/tar -xzvf nagios-$nagiosVersion.tar.gz",
		unless  => "/usr/bin/test -f /opt/nagios-$nagiosVersion/configure"
	} -> exec {
	    "configure nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/opt/nagios-$nagiosVersion/configure --with-command-group=$nagiosGroup",
		unless  => "/usr/bin/test -f /opt/nagios-$nagiosVersion/sample-config/nagios.cfg",
		require => [
		    Package["build-essential"],
		    Package["php5-gd"],
		    Package["libgd2-xpm"],
		    Package["libgd2-xpm-dev"],
		]
	} -> exec {
	    "make all nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/usr/bin/make all",
	} -> exec {
	    "make install nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/usr/bin/make install",
		unless  => "/usr/bin/test -d /usr/local/nagios/etc"
	} -> exec {
	    "make install-init nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/usr/bin/make install-init",
		unless  => "/usr/bin/test -f /etc/init.d/nagios"
	} -> exec {
	    "make install-config nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/usr/bin/make install-config",
		unless  => "/usr/bin/test -f /usr/local/nagios/etc/commands.cfg"
	} -> exec {
	    "make install-commandmode nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/usr/bin/make install-commandmode",
		unless  => "/usr/bin/test -d /usr/local/nagios/var/rw"
	} -> exec {
	    "make install-webconf nagios":
		cwd     => "/opt/nagios-$nagiosVersion",
		command => "/usr/bin/make install-webconf",
		unless  => "/usr/bin/test -f /etc/apache2/conf.d/nagios.conf",
		notify  => Service["apache2"]
	} -> service {
	    "nagios":
		ensure     => running,
		hasrestart => true
	} -> exec {
	    "unpack nagios plugins":
		cwd     => "/opt",
		command => "/bin/tar -xzvf nagios-plugins-$nagiosPluginsVersion.tar.gz",
		unless  => "/usr/bin/test -f /opt/nagios-plugins-$nagiosPluginsVersion/configure"
	} -> exec {
	    "configure nagios plugins":
		cwd     => "/opt/nagios-plugins-$nagiosPluginsVersion",
		command => "/opt/nagios-plugins-$nagiosPluginsVersion/configure --with-nagios-group=$nagiosUser --with-nagios-user=$nagiosUser",
		unless  => "/usr/bin/test -f /opt/nagios-plugins-$nagiosPluginsVersion/Makefile",
	} -> exec {
	    "make nagios plugins":
		cwd     => "/opt/nagios-plugins-$nagiosPluginsVersion",
		command => "/usr/bin/make"
	} -> exec {
	    "make install nagios plugins":
		cwd     => "/opt/nagios-plugins-$nagiosPluginsVersion",
		command => "/usr/bin/make install",
		unless  => "/usr/bin/test -f /usr/local/nagios/libexec/check_icmp"
	} -> exec {
	    "chmod init":
		command => "/bin/chmod +x /etc/init.d/nagios"
	} -> exec {
	    "set to run default":
		command => "/usr/sbin/update-rc.d -f nagios defaults",
	}
    }


    define configure(
	$nagiosadminUser="nagiosadmin",
	$nagiosadminPasswd="nagiosadmin"
    ) {
	$file = "/usr/local/nagios/etc/htpasswd.users"
	exec {
	    "htpasswd.users":
		command => "/usr/bin/htpasswd -bc $file $nagiosadminUser $nagiosadminPasswd"
	}
    }

    define setup(
	$nagiosUser="nagios", 
	$nagiosGroup="nagcmd",
	$nagiosadminUser="nagiosadmin",
	$nagiosadminPasswd="nagiosadmin"
    ) {
	exec {
	    "add user: nagios":
		unless  => "/usr/bin/id $nagiosUser",
		command => "/usr/sbin/adduser --system --no-create-home --disabled-login --group $nagiosUser"
	} -> exec {
	    "add group: $nagiosGroup":
		unless  => "/usr/sbin/groupmod $nagiosGroup",
		command => "/usr/sbin/groupadd $nagiosGroup"
	} -> exec {
	    "add $nagiosUser to $nagiosGroup":
		command => "/usr/sbin/usermod -G $nagiosGroup $nagiosUser"
	} -> exec {
	    "add www-data to $nagiosGroup":
		command => "/usr/sbin/usermod -a -G $nagiosGroup www-data",
		require => Package["apache2"]
	} -> nagios::server::fetch {
	    "base":
		nagiosVersion        => "3.2.3",
		nagiosPluginsVersion => "1.4.15"
	} -> nagios::server::install {
	    "base":
		nagiosVersion        => "3.2.3",
		nagiosPluginsVersion => "1.4.15"
	} ->
	nagios::server::configure {
	    "base":
		nagiosadminUser   => $nagiosadminUser,
		nagiosadminPasswd => $nagiosadminPasswd
	}
    }

}