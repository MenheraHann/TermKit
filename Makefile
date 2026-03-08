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
	@mkdir -p $(APP_NAME)/Contents/Resources
	@cp -R Resources/CLIIcons $(APP_NAME)/Contents/Resources/CLIIcons
	@# Ad-hoc sign so macOS doesn't block it
	@codesign --force --sign - $(APP_NAME)
	@echo "✅ $(APP_NAME) created."

install: app
	@# 杀掉正在运行的旧进程
	@-pkill -x TermKit 2>/dev/null; sleep 0.3
	@echo "Installing..."
	@rm -rf $(APP_DIR)
	@cp -R $(APP_NAME) $(APP_DIR)
	@chmod -R 755 $(APP_DIR)
	@xattr -cr $(APP_DIR)
	@# 自动启动新版本
	@open $(APP_DIR)
	@echo ""
	@echo "✅ Done! TermKit 已自动重启。"

uninstall:
	@-pkill -x TermKit 2>/dev/null; sleep 0.3
	@rm -rf $(APP_DIR)
	@echo "✅ Uninstalled."

clean:
	@rm -rf $(APP_NAME)
	swift package clean
