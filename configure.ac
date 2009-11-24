AC_PREREQ(2.59)
AC_INIT(ganeti-instance-debootstrap, 0.7, ganeti@googlegroups.com)

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

AC_CONFIG_FILES([ Makefile ])

AC_OUTPUT
