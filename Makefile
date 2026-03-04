PREFIX ?= /usr/local/bin

.PHONY: build install uninstall clean

build:
	swift build -c release

install: build
	@echo "Installing to $(PREFIX)..."
	install -m 755 .build/release/opentk $(PREFIX)/opentk
	install -m 755 .build/release/TermKit $(PREFIX)/TermKit
	@echo "✅ Done! Run 'opentk' to start."

uninstall:
	rm -f $(PREFIX)/opentk $(PREFIX)/TermKit
	@echo "✅ Uninstalled."

clean:
	swift package clean
