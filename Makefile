MAJVER	= 1
MINVER	= 0
VERSION	= $(MAJVER).$(MINVER)
ROOT	= ""
PREFIX	= $(ROOT)/usr
SRCDIR	= $(PREFIX)/share/stormsh
LIBDIR 	= $(PREFIX)/local/lib/stormsh/$(VERSION)

define install
	mkdir -p $(SRCDIR) $(LIBDIR)
	install -m 755 ./src/parser.awk ./src/regulator.awk ./src/lib_parser.awk ./src/repetitious.awk ./src/lib_source.awk $(SRCDIR)
	install -m 755 ./lib/*.sh $(LIBDIR)
	install ./src/stormsh.sh $(PREFIX)/bin/stormsh
endef

define uninstall
	rm -rf $(SRCDIR) $(LIBDIR) $(PREFIX)/bin/stormsh
endef

install:
	@$(install)
	@echo "installed."

uninstall:
	@$(uninstall)
	@echo "uninstalled."

reinstall:
	@$(uninstall)
	@$(install)
	@echo "reinstalled."