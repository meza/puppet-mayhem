class sshd {

    define setup($version="latest") {

	package {
	    "openssh-server": 
		ensure => $version
	} -> service {
	    ssh:
		enable  => true,
		ensure  => running
	} -> file {
	    "/etc/ssh/sshd_config":
		source  => "puppet:///sshd/sshd_config",
		ensure  => present,
		replace => true
	}

    }
}
