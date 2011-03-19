CREATE TABLE ftpgroup (
groupname varchar(16) NOT NULL default '',
gid smallint(6) NOT NULL default '5500',
members varchar(16) NOT NULL default '',
KEY groupname (groupname),
UNIQUE KEY uni_gr_member (groupname, members)
) TYPE=MyISAM COMMENT='ProFTP group table';

CREATE TABLE ftpquotalimits (
name varchar(30) default NULL,
quota_type enum('user','group','class','all') NOT NULL default 'user',
per_session enum('false','true') NOT NULL default 'false',
limit_type enum('soft','hard') NOT NULL default 'soft',
bytes_in_avail int(10) unsigned NOT NULL default '0',
bytes_out_avail int(10) unsigned NOT NULL default '0',
bytes_xfer_avail int(10) unsigned NOT NULL default '0',
files_in_avail int(10) unsigned NOT NULL default '0',
files_out_avail int(10) unsigned NOT NULL default '0',
files_xfer_avail int(10) unsigned NOT NULL default '0'
) TYPE=MyISAM;

CREATE TABLE ftpquotatallies (
name varchar(30) NOT NULL default '',
quota_type enum('user','group','class','all') NOT NULL default 'user',
bytes_in_used int(10) unsigned NOT NULL default '0',
bytes_out_used int(10) unsigned NOT NULL default '0',
bytes_xfer_used int(10) unsigned NOT NULL default '0',
files_in_used int(10) unsigned NOT NULL default '0',
files_out_used int(10) unsigned NOT NULL default '0',
files_xfer_used int(10) unsigned NOT NULL default '0'
) TYPE=MyISAM;

CREATE TABLE ftpuser (
id int(10) unsigned NOT NULL auto_increment,
userid varchar(32) NOT NULL default '',
passwd varchar(32) NOT NULL default '',
uid smallint(6) NOT NULL default '5500',
gid smallint(6) NOT NULL default '5500',
homedir varchar(255) NOT NULL default '',
shell varchar(16) NOT NULL default '/sbin/nologin',
count int(11) NOT NULL default '0',
accessed datetime NOT NULL default '0000-00-00 00:00:00',
modified datetime NOT NULL default '0000-00-00 00:00:00',
PRIMARY KEY (id),
UNIQUE KEY userid (userid)
) TYPE=MyISAM COMMENT='ProFTP user table';

CREATE TABLE IF NOT EXISTS `xferlog` (
`username` varchar(100) NOT NULL,
`timestamp` datetime NOT NULL,
`bytes` int(20) NOT NULL,
`file` varchar(255) NOT NULL,
`direction` varchar(1) NOT NULL,
`ip` varchar(20) NOT NULL,
 KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
              
INSERT INTO `ftpgroup` (`groupname`, `gid`, `members`) VALUES ('www-data', 33, 'www-data');