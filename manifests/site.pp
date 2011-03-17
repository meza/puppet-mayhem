import "sites/*.pp"
import "php"
import "apache"
import "proftpd"

$mysql_password   = "secret"
$mysql_datadir    = "/var/lib/mysql"
$proftpd_database = "ftp"
$proftpd_username = "proftpd"
$proftpd_password = "*#V3rYS3cr33T%"

$filebucketServer = "filebucket.server.com"

filebucket {
    main: server => "$filebucketServer"
}

File { 
    backup => main 
}
