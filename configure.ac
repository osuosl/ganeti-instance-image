AC_PREREQ(2.59)
AC_INIT(ganeti-instance-image, 0.7.1, lance@osuosl.org)

AC_CONFIG_AUX_DIR(autotools)
AC_CONFIG_SRCDIR(configure)

AM_INIT_AUTOMAKE([1.9 foreign tar-ustar -Wall -Wno-portability])

# --with-os-dir=...
AC_ARG_WITH([os-dir],
  [AS_HELP_STRING([--with-os-dir=DIR],
    [top-level OS directory under which to install]
    [ [DATADIR/ganeti/os]]
  )],
  [os_dir="$withval"],
  [os_dir="$datadir/ganeti/os"])
AC_SUBST(OS_DIR, $os_dir)

# --with-default-dir=...
AC_ARG_WITH([default-dir],
  [AS_HELP_STRING([--with-default-dir=DIR],
    [top-level default config directory under which to install]
    [ [SYSCONFDIR/default]]
  )],
  [default_dir="$withval"],
  [default_dir="$sysconfdir/default"])
AC_SUBST(DEFAULT_DIR, $default_dir)

# Check common programs
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_AWK
AC_PROG_MKDIR_P

AC_PATH_PROG(DUMP, [dump], [], [$PATH:/usr/sbin:/sbin])
if test -z "$DUMP" ; then
  AC_MSG_ERROR([dump not found in $PATH])
fi

AC_PATH_PROG(LOSETUP, [losetup], [], [$PATH:/usr/sbin:/sbin])
if test -z "$LOSETUP" ; then
  AC_MSG_ERROR([losetup not found in $PATH])
fi

AC_PATH_PROG(KPARTX, [kpartx], [], [$PATH:/usr/sbin:/sbin])
if test -z "$KPARTX" ; then
  AC_MSG_ERROR([kpartx not found in $PATH])
fi

if $KPARTX | grep -q '\-s sync mode'; then
    KPARTX="$KPARTX -s"
fi

AC_PATH_PROG(SFDISK, [sfdisk], [], [$PATH:/usr/sbin:/sbin])
if test -z "$SFDISK" ; then
  AC_MSG_ERROR([sfdisk not found in $PATH])
fi

AC_PATH_PROG(PARTED, [parted], [], [$PATH:/usr/sbin:/sbin])
if test -z "$PARTED" ; then
  AC_MSG_WARN([parted not found in $PATH])
fi

AC_PATH_PROG(QEMU_IMG, [qemu-img], [], [$PATH:/usr/sbin:/sbin])
if test -z "$QEMU_IMG" ; then
  AC_MSG_ERROR([qemu-img not found in $PATH])
fi

AC_PATH_PROG(CURL, [curl], [], [$PATH:/usr/bin:/bin])
if test -z "$CURL" ; then
  AC_MSG_ERROR([curl not found in $PATH])
fi

AC_PATH_PROG(SHA1SUM, [sha1sum], [], [$PATH:/usr/bin:/bin])
if test -z "$SHA1SUM" ; then
  AC_MSG_ERROR([sha1sum not found in $PATH])
fi

AC_CONFIG_FILES([
    Makefile
])

AC_OUTPUT
