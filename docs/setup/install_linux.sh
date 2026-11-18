#!/bin/sh
# Installs the dev toolchain for Linux cloud sessions: Godot 4.7.2 and gdtoolkit.
set -eu

GODOT_VERSION="4.7.2"
GODOT_NAME="Godot_v${GODOT_VERSION}-stable_linux.x86_64"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${GODOT_NAME}.zip"
INSTALL_DIR="$HOME/.local/opt/godot"
BIN_DIR="$HOME/.local/bin"

if godot --version 2>/dev/null | grep -q "^${GODOT_VERSION}\.stable"; then
	echo "Godot ${GODOT_VERSION} already installed."
else
	mkdir -p "$INSTALL_DIR" "$BIN_DIR"
	tmp_zip="$(mktemp)"
	curl -fsSL "$GODOT_URL" -o "$tmp_zip"
	unzip -o -q "$tmp_zip" -d "$INSTALL_DIR"
	rm -f "$tmp_zip"
	chmod +x "$INSTALL_DIR/$GODOT_NAME"
	ln -sf "$INSTALL_DIR/$GODOT_NAME" "$BIN_DIR/godot"
	echo "Installed Godot ${GODOT_VERSION} to $BIN_DIR/godot"
fi

python3 -m pip install --user "gdtoolkit==4.*"

case ":$PATH:" in
*":$BIN_DIR:"*) ;;
*) echo "Add $BIN_DIR to PATH: export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac
