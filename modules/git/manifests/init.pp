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
	    unless  => "/usr/bin/test -d $targetDir",
	    command => "/usr/bin/git clone -q $repository $targetDir",
	    require => Package["git-core"],
	}
	
	exec {
	    "git pull":
		onlyif  => "/usr/bin/test -d $targetDir",
		cwd     => $targetDir,
		command => "/usr/bin/git pull",
		require => Package["git-core"]
	}
    }
}