require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-9.1-RELEASE-amd64-dvd1.iso"

session =
  FREEBSD_SESSION.merge( :iso_file => iso,
                         :iso_md5 => "5da132138da8360491eb0efa24760859",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/9.1/#{iso}" )

Veewee::Session.declare session
