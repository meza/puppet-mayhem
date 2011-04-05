class git {

    define setup($gitversion="latest", $gitcoreversion="latest") {

	package {
	    "git":
		ensure => $gitversion
	}

	package {
	    "git-core":
		ensure => $gitcoreversion,
		require => Package["git"]
	}
    }

    define clone ( $repository, $targetDir ) {
	exec {
	    "git clone $repository":
	    unless  => "/usr/bin/test -d $targetDir/.git",
	    command => "/usr/bin/git clone -q $repository $targetDir",
	    require => Package["git-core"],
	}
	
	exec {
	    "git pull $repository":
		onlyif  => "/usr/bin/test -d $targetDir/.git",
		cwd     => $targetDir,
		command => "/usr/bin/git pull",
		require => Package["git-core"]
	}
    }
}