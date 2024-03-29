%define         instancename    image
Name:		ganeti-instance-image
Version:	0.7.3
Release:	1%{?dist}
Summary:	Guest OS definition for Ganeti based on Linux-based images

Group:		System Environment/Daemons
License:	GPLv2
URL:		http://code.osuosl.org/projects/ganeti-image
Source0:	http://ftp.osuosl.org/pub/osl/ganeti-instance-image/%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:	qemu-img, dump, tar, kpartx, curl
Requires:       qemu-img, dump, tar, kpartx, curl, ganeti
BuildArch:      noarch

%description
This is a guest OS definition for Ganeti (http://code.google.com/p/ganeti). It
will install a Linux-based image using either a tarball, filesystem dump, or a
qemu-img disk image file. This definition also allows for manual creation of an
instance by simply setting only the disks up and allowing you to boot via the
install cd manually.  The goal of this instance is to allow fast and flexible
installation of instances without the need for external tools such as
debootstrap.


%prep
%setup -q


%build
%configure \
    --prefix=%{_prefix} \
    --sysconfdir=%{_sysconfdir} \
    --localstatedir=%{_localstatedir}
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

# Next part covered by %doc in %files
rm -rf $RPM_BUILD_ROOT/%{_datadir}/doc/%{name}

# Workaround issue #92 http://code.google.com/p/ganeti/issues/detail?id=92
# The install scripts create a symlink using the fully qualified path
# that includes the build root path.
pushd $RPM_BUILD_ROOT%{_datadir}/ganeti/os/%{instancename}
rm -f variants.list
ln -s ../../../../..%{_sysconfdir}/ganeti/instance-%{instancename}/variants.list variants.list
popd


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc COPYING README.markdown NEWS example/hooks/*
%config(noreplace) %{_sysconfdir}/ganeti/instance-%{instancename}/variants/default.conf
%config(noreplace) %{_sysconfdir}/ganeti/instance-%{instancename}/variants.list
%config(noreplace) %{_sysconfdir}/ganeti/instance-%{instancename}/hooks/*
%{_datadir}/ganeti/os/%{instancename}/*
%{_localstatedir}/cache/ganeti-instance-image

%changelog
* Thu Apr 27 2032 Lance Albertson <lance osuosl org>
- Released 0.7.3
- Fixes Include:
  - Remove datasource_list from generated cloud-init config (#31)

* Thu Jul 20 2017 Lance Albertson <lance osuosl org>
- Released 0.7.2
- Fixes Include:
  - Add /var/cache/ganeti-instance-image directory to package (#29)
  - bug fix: can't create instance if swap=no and disk size is < memory (25)

* Wed Jul 19 2017 Lance Albertson <lance osuosl org>
- Released 0.7.1
- Fixes include:
  - Properly set variable checks for IMAGE_CLEANUP (#27)
  - Vagrant environment fixes (#28)

* Fri Jul 14 2017 Lance Albertson <lance osuosl org>
- Version bump to 0.7.0

* Tue Jun 02 2015 Lance Albertson <lance osuosl org>
- Version bump to 0.7beta1
- Vagrant+Chef development environment
- Image URL support (imported from GRNET)
- Support for qcow2 images
- Cloud init support

* Mon Jul 08 2013 Lance Albertson <lance osuosl org>
- Version bump to 0.6

* Thu May 26 2011 Stephen Fromm <stephenf nero net>
- Fix dependencies and Source0 URL.
- Default to %datadir for os-dir.  Eliminates the arch problem with %libdir

* Wed May 25 2011 Lance Albertson <lance osuosl org>
- Bugfix release
- Ticket #4785 - blkid sometimes didn't return a value
- Ticket #5685 - baselayout-2.x support for gentoo guests

* Fri Apr  1 2011 Lance Albertson <lance osuosl org>
- Version bump to 0.5

* Tue Nov  9 2010 Stephen Fromm <stephenf nero net>
- Fix handling of variants.list in /usr/lib/ganeti/os/<name>

* Thu Nov  4 2010 Stephen Fromm <stephenf nero net>
- Initial package for version 0.4
