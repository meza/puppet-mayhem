class server {
    define installPackage($version="latest") {
	package {
	    $name:
		ensure => $version
	}
    }
}

class server::iptables {
    
    define runRule($rule) {
	exec {
	    "iptables-$rule":
		command => "/sbin/iptables $rule"
	}
    }

    define setup()
    {
	package {
	    "iptables":
		ensure => "1.4.4-2ubuntu3"
	} ->
	server::iptables::runRule {
	    "accept-all-in":
		rule => "-P INPUT ACCEPT"
	} -> server::iptables::runRule {
	    "accept-all-out":
		rule => "-P OUTPUT ACCEPT"
	} -> server::iptables::runRule {
	    "drop-forward":
		rule => "-P FORWARD DROP"
	} -> server::iptables::runRule {
	    "flush-common":
		rule => "-F"
	} -> server::iptables::runRule {
	    "flush-input":
		rule => "-F INPUT"
	} -> server::iptables::runRule {
	    "flush-output":
		rule => "-F OUTPUT"
	} -> server::iptables::runRule {
	    "flush-forward":
		rule => "-F FORWARD"
	} -> server::iptables::runRule {
	    "mangle":
		rule => "-F -t mangle"
	} -> server::iptables::runRule {
	    "do x":
		rule => "-X"
	} -> server::iptables::runRule {
	    "allow-loop-if":
		rule => "-A INPUT -i lo -j ACCEPT"
	} -> server::iptables::runRule {
	    "block-from-localhost":
		rule => "-A INPUT -d 127.0.0.0/8 -j REJECT"
	} -> server::iptables::runRule {
	    "allow-ftp-20":
		rule => "-A INPUT -p tcp --dport 20 -j ACCEPT"
	} -> server::iptables::runRule {
	    "allow-ftp-21":
		rule => "-A INPUT -p tcp --dport 21 -j ACCEPT"
	} -> server::iptables::runRule {
	    "allow-ftp-passv":
		rule => "-A INPUT -p tcp --dport 60000:60500 -j ACCEPT"
	} -> server::iptables::runRule {
	    "allow-ssh":
		rule => "-A INPUT -p tcp --dport 22 -j ACCEPT"
	}-> server::iptables::runRule {
	    "allow-web-http":
		rule => "-A INPUT -p tcp --dport 80 -j ACCEPT"
	} -> server::iptables::runRule {
	    "allow-web-https":
		rule => "-A INPUT -p tcp --dport 443 -j ACCEPT"
	} -> server::iptables::runRule {
	    "allow-mysql":
		rule => "-A INPUT -p tcp --dport 3306 -j ACCEPT"
	} -> server::iptables::runRule {
	    "allow-currently-active":
		rule => "-A INPUT -m state --state ESTABLISHED -j ACCEPT"
	} -> server::iptables::runRule {
	    "drop-invalid":
		rule => "-A INPUT -m state --state INVALID -j REJECT"
	} -> server::iptables::runRule {
	    "ping":
		rule => "-A INPUT -p icmp -j ACCEPT"
	} -> server::iptables::runRule {
	    "drop-any-other":
		rule => "-A INPUT -j REJECT"
	}
    }
}