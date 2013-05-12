require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-9.1-RELEASE-i386-dvd1.iso"

session =
  FREEBSD_SESSION.merge( :os_type_id => 'FreeBSD',
                         :iso_file => iso,
                         :iso_md5 => "dd07dc30035806cabd136f99ccab7eac",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/i386/ISO-IMAGES/9.1/#{iso}" )

Veewee::Session.declare session
