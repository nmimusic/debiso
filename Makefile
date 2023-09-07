# DebISO Installer
# License: 3-clause BSD
# Copyright (c) 2023 Radio New Japan Broadcasting Club

PREFIX ?= /usr/local
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/debiso
PROFILE_DIR=$(DESTDIR)$(PREFIX)/share/debiso

all:
	printf "Run 'make install' to install DebISO.\n"

install: install-scripts install-profiles install-doc

install-scripts:
	install -vDm 755 mkdebiso -t "$(BIN_DIR)/"

install-profiles:
	install -d -m 755 $(PROFILE_DIR)
	cp -a --no-preserve=ownership configs $(PROFILE_DIR)/

install-doc:
	install -vDm 644 README.md -t $(DOC_DIR)
	install -vDm 644 doc/customise.md -t $(DOC_DIR)

uninstall: uninstall-scripts uninstall-profiles uninstall-doc

uninstall-scripts:
	rm -rf "$(BIN_DIR)/mkdebiso"

uninstall-profiles:
	rm -rf "$(PROFILE_DIR)/"

uninstall-doc:
	rm -rf "${DOC_DIR}"


.PHONY: check install install-doc install-profiles install-scripts uninstall uninstall-doc uninstall-profiles uninstall-scripts
