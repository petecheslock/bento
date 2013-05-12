require File.dirname(__FILE__) + "/../.common/session.rb"

FREEBSD_COMMON_SESSION =
  COMMON_SESSION.merge({
    :kickstart_file => "install.sh",
    :memory_size=> "1024",
    :os_type_id => 'FreeBSD_64',
    :postinstall_files => [
      "update.sh",
      "vagrant.sh",
      "cleanup.sh",
      "minimize.sh"
    ],
    :ssh_login_timeout => "4000",
    :shutdown_cmd => "shutdown -p -o now"
  })

# Default FreeBSD boot session
FREEBSD_SESSION =
  FREEBSD_COMMON_SESSION.merge({
    :boot_cmd_sequence =>
    [
      '<Esc>',
      'load geom_mbr',
      '<Enter>',
      'load zfs',
      '<Enter>',
      'boot -s',
      '<Enter>',
      '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
      '/bin/sh<Enter>',
      'mdmfs -s 100m md1 /tmp<Enter>',
      'dhclient -l /tmp/dhclient.lease.em0 em0<Enter>',
      '<Wait><Wait><Wait>',
      'sleep 10 ; fetch -o /tmp/install.sh http://%IP%:%PORT%/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh %NAME%<Enter>'
    ]
  })

# LiveCD/Fixit boot session (needed for FreeBSD 8)
FREEBSD_FIXIT_SESSION =
  FREEBSD_COMMON_SESSION.merge({
    :boot_cmd_sequence =>
    [
      '6<Enter>',
      '<Wait>',
      'load geom_mbr',
      '<Enter>',
      'load geom_nop',
      '<Enter>',
      'load zfs',
      '<Enter>',
      'boot -s',
      '<Enter>',
      '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
      '<Enter>',
      'f<Enter>2<Enter>',
      '<Wait><Enter><Wait>',
      'dhclient -l /tmp/dhclient.lease.em0 em0<Enter>',
      '<Wait><Wait><Wait>',
      'sleep 10 ; fetch -o /tmp/install.sh http://%IP%:%PORT%/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh %NAME%<Enter>'
    ],
    :shutdown_cmd => "shutdown -p now"
  })
