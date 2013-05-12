require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-8.2-RELEASE-amd64-dvd1.iso"

session =
  FREEBSD_FIXIT_SESSION.merge({
                         :iso_file => iso,
                         :iso_md5 => "287242976c6593f31049ea454c1a82e9",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/8.2/#{iso}" })

Veewee::Session.declare session
