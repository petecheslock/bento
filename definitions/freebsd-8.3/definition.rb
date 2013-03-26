require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-8.3-RELEASE-amd64-dvd1.iso"

session =
  FREEBSD_FIXIT_SESSION.merge({
                         :iso_file => iso,
                         :iso_md5 => "70089656058e74962cbedad1a2181daa",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/8.3/#{iso}" })

Veewee::Session.declare session
