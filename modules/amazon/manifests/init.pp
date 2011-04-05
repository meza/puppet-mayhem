class amazon::s3 {
    
    define setup(
	$buildEssentialVersion="latest",
	$libcurl4OpensslDevVersion="latest",
	$libxml2DevVersion="latest",
	$libfuseDevVersion="latest",
	$comerrDevVersion="latest",
	$libfuse2Version="latest",
	$libidn11DevVersion="latest",
	$libkdn54Version="latest",
	$libgssrpc4Version="latest",
	$libkrb5DevVersion="latest",
	$libldap2DevVersion="latest",
	$libselinux1DevVersion="latest",
	$libsepol1DevVersion="latest",
	$pkgConfigVersion="latest",
	$fuseUtilsVersion="latest"
    )
    {
	package {
	    "build-essential":
		ensure => $buildEssentialVersion
	}
	
	package {
	    "libcurl4-openssl-dev":
		ensure => $libcurl4OpensslDevVersion
	}
	
	package {
	    "libxml2-dev":
		ensure => $libxml2DevVersion
	}
	
	package {
	    "libfuse-dev":
		ensure => $libfuseDevVersion
	}
	
	package {
	    "libfuse2":
		ensure => $libfuse2Version
	}
	
	package {
	    "libidn11-dev":
		ensure => $libidn11DevVersion
	}
	
	package {
	    "libkdb5-4":
		ensure => $libkdb54Version
	}
	
	package {
	    "libgssrpc4":
		ensure => $libgssrpc4Version
	}
	
	package {
	    "libkrb5-dev":
		ensure => $libkrb5DevVersion
	}
	
	package {
	    "libldap2-dev":
		ensure => $libldap2DevVersion
	}
	
	package {
	    "libselinux1-dev":
		ensure => $libselinux1DevVersion
	}
	
	
	package {
	    "libsepol1-dev":
		ensure => $libsepol1DevVersion
	}
	
	package {
	    "pkg-config":
		ensure => $pkgConfigVersion
	}
	
	package {
	    "fuse-utils":
		ensure => $fuseUtilsVersion
	}
	
	file {
	    "/root/s3fs-src.tar.gz":
		require => [
		    Package["build-essential"], 
		    Package["libcurl4-openssl-dev"], 
		    Package["libxml2-dev"], 
		    Package["libfuse-dev"], 
		    Package["libfuse2"], 
		    Package["libidn11-dev"], 
		    Package["libkdb5-4"], 
		    Package["libgssrpc4"], 
		    Package["libkrb5-dev"],
		    Package["libldap2-dev"],
		    Package["libselinux1-dev"], 
		    Package["libsepol1-dev"], 
		    Package["pkg-config"], 
		    Package["fuse-utils"]
		],
		source => "puppet:///amazon/s3fs-1.40.tar.gz",
		ensure => present
	} -> exec {
	    "unpack s3fs":
		onlyif  => "/usr/bin/test -f /root/s3fs-src.tar.gz",
		unless  => "/usr/bin/test -d /root/s3fs-1.40",
		cwd     => "/root",
		command => "/bin/tar xzf s3fs-src.tar.gz"
	} -> exec {
	    "configure s3fs":
		onlyif  => "/usr/bin/test -d /root/s3fs-1.40",
		unless  => "/usr/bin/test -f /usr/local/bin/s3fs",
		cwd     => "/root/s3fs-1.40",
		command => "/root/s3fs-1.40/configure"
	} -> exec {
	    "make s3fs":
		unless  => "/usr/bin/test -f /usr/local/bin/s3fs",
		cwd     => "/root/s3fs-1.40",
		command => "/usr/bin/make"
	} -> exec {
	    "install s3fs":
		unless  => "/usr/bin/test -f /usr/local/bin/s3fs",
		cwd     => "/root/s3fs-1.40",
		command => "/usr/bin/make install"
	}
    }
    
    
    define mount(
	$accessId,
	$accessKey
    )
    {
	$bucket = $name
	
	file {
	    "/etc/passwd-s3fs-$bucket":
		ensure => present,
		owner  => root,
		group  => root,
		mode   => 600,
		content => "$bucket:$accessId:$accessKey"
	} -> file {
	    "/mnt/s3":
		ensure => directory,
		mode   => 0777
	} -> file {
	    "/mnt/s3/$bucket":
		ensure => directory,
		mode   => 0777
	} -> mount {
	    "/mnt/s3/$bucket":
		device  => "s3fs#$bucket",
		fstype  => "fuse",
		options => "default_acl=public-read,allow_other,url=https://s3.amazonaws.com,passwd_file=/etc/passwd-s3fs-$bucket",
		dump    => 0,
		pass    => 0,
		ensure  => present,
		atboot  => true,
	} -> exec {
	    "mount all":
		unless  => "/bin/mount -l | /bin/grep /mnt/s3/$bucket",
		command => "/bin/mount -a"
	}
	
    }

}