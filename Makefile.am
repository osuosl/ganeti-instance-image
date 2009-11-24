osname=$(subst ganeti-instance-,,$(PACKAGE))

osdir=$(OS_DIR)/$(osname)
variantsdir="$(DESTDIR)${sysconfdir}/ganeti/instance-debootstrap/variants"

dist_os_SCRIPTS = create import export rename
dist_os_DATA = ganeti_api_version variants.list
os_DATA = common.sh

dist_doc_DATA = COPYING NEWS README

EXTRA_DIST = common.sh.in defaults

do_subst = sed \
	-e 's,[@]sysconfdir[@],$(sysconfdir),g' \
	-e 's,[@]localstatedir[@],$(localstatedir),g'

common.sh: common.sh.in Makefile
	$(do_subst) < $< > $@
	chmod +x $@

install-exec-local:
	@mkdir_p@ "$(variantsdir)"
	touch "$(variantsdir)/default.conf"

CLEANFILES = common.sh
