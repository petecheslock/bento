require File.dirname(__FILE__) + "/../.freebsd/session.rb"

iso = "FreeBSD-8.1-RELEASE-amd64-dvd1.iso"

session =
  FREEBSD_FIXIT_SESSION.merge({
                         :iso_file => iso,
                         :iso_md5 => "3dc2f3131c390f3d8312349cd945aa24",
                         :iso_src => "ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/8.1/#{iso}" })

Veewee::Session.declare session
