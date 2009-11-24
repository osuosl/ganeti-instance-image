AC_PREREQ(2.59)
AC_INIT(ganeti-instance-image, 0.1, lance@osuosl.org)

AC_CONFIG_AUX_DIR(autotools)
AC_CONFIG_SRCDIR(configure)

AM_INIT_AUTOMAKE([1.9 foreign tar-ustar -Wall -Wno-portability])

# --with-os-dir=...
AC_ARG_WITH([os-dir],
  [AS_HELP_STRING([--with-os-dir=DIR],
    [top-level OS directory under which to install]
    [ (default is $datadir/ganeti/os)]
  )],
  [os_dir="$withval"],
  [os_dir="$datadir/ganeti/os"])
AC_SUBST(OS_DIR, $os_dir)

# Check common programs
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_AWK
AC_PROG_MKDIR_P

AC_PATH_PROG(DUMP, [dump])
if test -z "$DUMP" ; then
  AC_MSG_ERROR([dump not found in $PATH])
fi

AC_PATH_PROG(LOSETUP, [losetup])
if test -z "$LOSETUP" ; then
  AC_MSG_ERROR([losetup not found in $PATH])
fi

AC_PATH_PROG(KPARTX, [kpartx])
if test -z "$KPARTX" ; then
  AC_MSG_ERROR([kpartx not found in $PATH])
fi

AC_PATH_PROG(SFDISK, [sfdisk])
if test -z "$SFDISK" ; then
  AC_MSG_ERROR([sfdisk not found in $PATH])
fi

AC_CONFIG_FILES([
    Makefile
    common.sh
])

AC_OUTPUT
