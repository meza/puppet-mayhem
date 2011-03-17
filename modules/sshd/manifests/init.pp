class sshd {

    define setup() {
	$packagelist = ["openssh-server", "openssh-client"]
	package {
	    $packagelist: ensure => installed
	}
    
	service {
	    ssh:
		enable => true,
		ensure => running,
	}
    }
}
