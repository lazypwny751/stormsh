ROOT	= ""
PREFIX	= $(ROOT)/usr
BINDIR	= $(PREFIX)/bin
SHARED	= $(PREFIX)/share/stormsh

define install
	mkdir -p $(SHARED)
	install -m 755 ./src/regulator.awk $(SHARED)
	install -m 755 ./src/parser.awk $(SHARED)
	install -m 755 ./src/stormsh.sh $(BINDIR)/stormsh
endef

define uninstall
	rm -rf $(SHARED) $(BINDIR)/stormsh
endef

install:
	@$(install)
	@echo "\tinstalled."

uninstall:
	@$(uninstall)
	@echo "\tuninstalled."

reinstall:
	@$(uninstall)
	@$(install)
	@echo "\treinstalled."