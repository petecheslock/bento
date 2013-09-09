require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-7.3-RELEASE-amd64-dvd1.iso"

session =
  FREEBSD_FIXIT_SESSION.merge({
                         :iso_file => iso,
                         :iso_md5 => "7b9c2e7766c5e7684d6b305cb05be7f8",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/7.3/#{iso}" })

Veewee::Session.declare session
