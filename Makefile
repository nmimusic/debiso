# Toki Installer v(ᓀ‸ᓂ)v
# License: 3-clause BSD
# Copyright (c) 2023-2026 Nippon Ruritania Music Assembly

PREFIX ?= /usr/local
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/toki
PROFILE_DIR=$(DESTDIR)$(PREFIX)/share/toki

all:
	printf "Run 'make install' to install Toki.\n"

install: install-scripts install-profiles install-doc

install-scripts:
	install -vDm 755 tokibuild -t "$(BIN_DIR)/"

install-profiles:
	install -d -m 755 $(PROFILE_DIR)
	cp -a --no-preserve=ownership configs $(PROFILE_DIR)/

install-doc:
	install -vDm 644 README.md -t $(DOC_DIR)

uninstall: uninstall-scripts uninstall-profiles uninstall-doc

uninstall-scripts:
	rm -rf "$(BIN_DIR)/tokibuild"

uninstall-profiles:
	rm -rf "$(PROFILE_DIR)/"

uninstall-doc:
	rm -rf "${DOC_DIR}"


.PHONY: check install install-doc install-profiles install-scripts uninstall uninstall-doc uninstall-profiles uninstall-scripts
