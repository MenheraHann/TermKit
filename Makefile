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
	@chmod 755 $(APP_NAME)/Contents/MacOS/TermKit
	@cp Resources/Info.plist $(APP_NAME)/Contents/Info.plist
	@# Ad-hoc sign so macOS doesn't block it
	@codesign --force --sign - $(APP_NAME)
	@echo "✅ $(APP_NAME) created."

install: app
	@echo "Installing..."
	@# Install .app
	@rm -rf $(APP_DIR)
	@cp -R $(APP_NAME) $(APP_DIR)
	@chmod -R 755 $(APP_DIR)
	@xattr -cr $(APP_DIR)
	@echo ""
	@echo "✅ Done!"
	@echo "  • TermKit.app → $(APP_DIR)"
	@echo ""
	@echo "Usage:"
	@echo "  Hold ⌘          — 唤出分层菜单，松开粘贴"
	@echo ""
	@echo "💡 打开 TermKit 设置，开启「开机自动启动」即可后台常驻。"

uninstall:
	@rm -rf $(APP_DIR)
	@echo "✅ Uninstalled."

clean:
	@rm -rf $(APP_NAME)
	swift package clean
