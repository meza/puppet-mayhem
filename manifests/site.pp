import "sites/*.pp"


node 'a-host-for-nagios.domain.com' {
    include nagios-server-example
}