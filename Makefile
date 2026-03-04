PREFIX ?= /usr/local/bin
APP_NAME = TermKit.app
APP_DIR = /Applications/$(APP_NAME)

.PHONY: build install uninstall clean app

build:
	swift build -c release

app: build
	@echo "Packaging $(APP_NAME)..."
	@rm -rf $(APP_NAME)
	@mkdir -p $(APP_NAME)/Contents/MacOS
	@mkdir -p $(APP_NAME)/Contents/Resources
	@cp .build/release/TermKit $(APP_NAME)/Contents/MacOS/TermKit
	@cp Resources/Info.plist $(APP_NAME)/Contents/Info.plist
	@echo "✅ $(APP_NAME) created."

install: app
	@echo "Installing..."
	@# Install .app
	@rm -rf $(APP_DIR)
	@cp -R $(APP_NAME) $(APP_DIR)
	@# Install opentk CLI
	@install -m 755 .build/release/opentk $(PREFIX)/opentk
	@echo ""
	@echo "✅ Done!"
	@echo "  • TermKit.app → $(APP_DIR)"
	@echo "  • opentk CLI  → $(PREFIX)/opentk"
	@echo ""
	@echo "Usage:"
	@echo "  opentk          — 打开/关闭 TermKit 面板"
	@echo "  ⌥Space          — 全局快捷键"
	@echo ""
	@echo "💡 打开 TermKit 设置，开启「开机自动启动」即可后台常驻。"

uninstall:
	@rm -rf $(APP_DIR)
	@rm -f $(PREFIX)/opentk
	@echo "✅ Uninstalled."

clean:
	@rm -rf $(APP_NAME)
	swift package clean
