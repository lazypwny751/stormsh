ROOT	= ""
PREFIX	= $(ROOT)/usr
SRCDIR	= $(PREFIX)/share/stormsh
LIBDIR	= $(PREFIX)/local/lib/stormsh/2.0

# # müzik değil acılardır evrensel olan

define install
	mkdir -p $(SRCDIR) $(LIBDIR)
	install ./lib/*.sh $(LIBDIR)
	install -m 755 ./src/lexer.awk $(SRCDIR)
	install -m 755 ./src/parser.awk $(SRCDIR)
	install -m 755 ./src/stormsh.sh $(PREFIX)/bin/stormsh
endef

define uninstall
	rm -rf $(SRCDIR) $(LIBDIR) $(PREFIX)/bin/stormsh 
endef

install:
	@$(install)
	@echo "installed."

uninstall:
	@$(uninstall)
	@$(install)
	@echo "uninstalled."

reinstall:
	@$(uninstall)
	@$(install)
	@echo "reinstalled."
