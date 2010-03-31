osname=$(subst ganeti-instance-,,$(PACKAGE))

osdir=$(OS_DIR)/$(osname)
customdir="${sysconfdir}/ganeti/instance-image.d"
variantsdir="${sysconfdir}/ganeti/instance-image/variants"
networksdir="${sysconfdir}/ganeti/instance-image/networks"
toolsdir="$(OS_DIR)/$(osname)/tools"

dist_os_SCRIPTS = create import export rename
dist_tools_SCRIPTS = tools/*
dist_os_DATA = ganeti_api_version variants.list
os_DATA = common.sh

dist_custom_DATA = example/hooks/*

dist_doc_DATA = COPYING NEWS README

EXTRA_DIST = common.sh.in defaults

common.sh: common.sh.in 

install-exec-local:
	@mkdir_p@ "$(DESTDIR)$(variantsdir)"
	@mkdir_p@ "$(DESTDIR)$(networksdir)/subnets"
	@mkdir_p@ "$(DESTDIR)$(networksdir)/instances"
	@mkdir_p@ "$(DESTDIR)$(localstatedir)/cache/ganeti-instance-image"
	touch "$(DESTDIR)$(variantsdir)/default.conf"

CLEANFILES = common.sh
