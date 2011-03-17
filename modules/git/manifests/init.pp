class git {

    define setup() {
	$packages = ["git-core"]
    
	package {
	    $packages:
		ensure => installed
	}
    }
    
    define clone ( $repository, $targetDir ) {
	exec {
	    "git clone":
	    command => "/usr/bin/git clone -q $repository $targetDir",
	    require => Package["git-core"],
	}
    }
}