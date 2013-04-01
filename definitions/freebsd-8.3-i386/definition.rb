require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-8.3-RELEASE-i386-dvd1.iso"

session =
  FREEBSD_FIXIT_SESSION.merge( :os_type_id => 'FreeBSD',
                               :iso_file => iso,
                               :iso_md5 => "2478c6a7477492c347e80aaf61f48cc1",
                               :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/i386/ISO-IMAGES/8.3/#{iso}" )

Veewee::Session.declare session
