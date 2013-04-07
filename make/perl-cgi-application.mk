###########################################################
#
# perl-cgi-application
#
###########################################################
#http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-3.31.tar.gz
PERL-CGI-APPLICATION_SITE=http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS
PERL-CGI-APPLICATION_VERSION=3.31
PERL-CGI-APPLICATION_SOURCE=CGI-Application-$(PERL-CGI-APPLICATION_VERSION).tar.gz
PERL-CGI-APPLICATION_DIR=CGI-Application-$(PERL-CGI-APPLICATION_VERSION)
PERL-CGI-APPLICATION_UNZIP=zcat

PERL-CGI-APPLICATION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CGI-APPLICATION_DESCRIPTION=Framework for building reusable web-applications
PERL-CGI-APPLICATION_SECTION=util
PERL-CGI-APPLICATION_PRIORITY=optional
PERL-CGI-APPLICATION_DEPENDS=perl, perl-html-template

PERL-CGI-APPLICATION_IPK_VERSION=2

PERL-CGI-APPLICATION_CONFFILES=

PERL-CGI-APPLICATION_PATCHES=

PERL-CGI-APPLICATION_BUILD_DIR=$(BUILD_DIR)/perl-cgi-application
PERL-CGI-APPLICATION_SOURCE_DIR=$(SOURCE_DIR)/perl-cgi-application
PERL-CGI-APPLICATION_IPK_DIR=$(BUILD_DIR)/perl-cgi-application-$(PERL-CGI-APPLICATION_VERSION)-ipk
PERL-CGI-APPLICATION_IPK=$(BUILD_DIR)/perl-cgi-application_$(PERL-CGI-APPLICATION_VERSION)-$(PERL-CGI-APPLICATION_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-CGI-APPLICATION_BUILD_DIR=$(BUILD_DIR)/perl-cgi-application
PERL-CGI-APPLICATION_SOURCE_DIR=$(SOURCE_DIR)/perl-cgi-application
PERL-CGI-APPLICATION_IPK_DIR=$(BUILD_DIR)/perl-cgi-application-$(PERL-CGI-APPLICATION_VERSION)-ipk
PERL-CGI-APPLICATION_IPK=$(BUILD_DIR)/perl-cgi-application_$(PERL-CGI-APPLICATION_VERSION)-$(PERL-CGI-APPLICATION_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CGI-APPLICATION_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CGI-APPLICATION_SITE)/$(PERL-CGI-APPLICATION_SOURCE)

perl-cgi-application-source: $(DL_DIR)/$(PERL-CGI-APPLICATION_SOURCE) $(PERL-CGI-APPLICATION_PATCHES)

$(PERL-CGI-APPLICATION_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CGI-APPLICATION_SOURCE) $(PERL-CGI-APPLICATION_PATCHES)
	$(MAKE) perl-html-template-stage
	rm -rf $(BUILD_DIR)/$(PERL-CGI-APPLICATION_DIR) $(PERL-CGI-APPLICATION_BUILD_DIR)
	$(PERL-CGI-APPLICATION_UNZIP) $(DL_DIR)/$(PERL-CGI-APPLICATION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CGI-APPLICATION_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CGI-APPLICATION_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CGI-APPLICATION_DIR) $(PERL-CGI-APPLICATION_BUILD_DIR)
	(cd $(PERL-CGI-APPLICATION_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-CGI-APPLICATION_BUILD_DIR)/.configured

perl-cgi-application-unpack: $(PERL-CGI-APPLICATION_BUILD_DIR)/.configured

$(PERL-CGI-APPLICATION_BUILD_DIR)/.built: $(PERL-CGI-APPLICATION_BUILD_DIR)/.configured
	rm -f $(PERL-CGI-APPLICATION_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CGI-APPLICATION_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CGI-APPLICATION_BUILD_DIR)/.built

perl-cgi-application: $(PERL-CGI-APPLICATION_BUILD_DIR)/.built

$(PERL-CGI-APPLICATION_BUILD_DIR)/.staged: $(PERL-CGI-APPLICATION_BUILD_DIR)/.built
	rm -f $(PERL-CGI-APPLICATION_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CGI-APPLICATION_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CGI-APPLICATION_BUILD_DIR)/.staged

perl-cgi-application-stage: $(PERL-CGI-APPLICATION_BUILD_DIR)/.staged

$(PERL-CGI-APPLICATION_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CGI-APPLICATION_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-cgi-application" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CGI-APPLICATION_PRIORITY)" >>$@
	@echo "Section: $(PERL-CGI-APPLICATION_SECTION)" >>$@
	@echo "Version: $(PERL-CGI-APPLICATION_VERSION)-$(PERL-CGI-APPLICATION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CGI-APPLICATION_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CGI-APPLICATION_SITE)/$(PERL-CGI-APPLICATION_SOURCE)" >>$@
	@echo "Description: $(PERL-CGI-APPLICATION_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CGI-APPLICATION_DEPENDS)" >>$@

$(PERL-CGI-APPLICATION_IPK): $(PERL-CGI-APPLICATION_BUILD_DIR)/.built
	rm -rf $(PERL-CGI-APPLICATION_IPK_DIR) $(BUILD_DIR)/perl-cgi-application_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CGI-APPLICATION_BUILD_DIR) DESTDIR=$(PERL-CGI-APPLICATION_IPK_DIR) install
	find $(PERL-CGI-APPLICATION_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CGI-APPLICATION_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CGI-APPLICATION_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CGI-APPLICATION_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-CGI-APPLICATION_SOURCE_DIR)/postinst $(PERL-CGI-APPLICATION_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-CGI-APPLICATION_SOURCE_DIR)/prerm $(PERL-CGI-APPLICATION_IPK_DIR)/CONTROL/prerm
	echo $(PERL-CGI-APPLICATION_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CGI-APPLICATION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CGI-APPLICATION_IPK_DIR)

perl-cgi-application-ipk: $(PERL-CGI-APPLICATION_IPK)

perl-cgi-application-clean:
	-$(MAKE) -C $(PERL-CGI-APPLICATION_BUILD_DIR) clean

perl-cgi-application-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CGI-APPLICATION_DIR) $(PERL-CGI-APPLICATION_BUILD_DIR) $(PERL-CGI-APPLICATION_IPK_DIR) $(PERL-CGI-APPLICATION_IPK)
