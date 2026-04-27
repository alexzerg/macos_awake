# macos_awake Makefile
# Usage:
#   make install      copy awake + hid-nudge.sh to ~/bin, write plists, load agents
#   make uninstall    stop agents, remove plists, remove ~/bin/awake
#   make schedule     install weekend auto-toggle (Fri 23:59 off / Mon 07:00 on)
#   make on           start awake right now
#   make off          stop awake right now
#   make status       show current state

BIN_DIR := $(HOME)/bin
AWAKE   := $(BIN_DIR)/awake
HID     := $(BIN_DIR)/hid-nudge.sh
SRC_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: install uninstall schedule unschedule on off enable disable status

install: $(BIN_DIR)
	@echo "==> copying scripts to $(BIN_DIR)"
	cp -f "$(SRC_DIR)/awake"        "$(AWAKE)"
	cp -f "$(SRC_DIR)/hid-nudge.sh" "$(HID)"
	chmod +x "$(AWAKE)" "$(HID)"
	@echo "==> writing LaunchAgent plists (namespace: $${AWAKE_NS:-com.awake})"
	AWAKE_HID="$(HID)" "$(AWAKE)" install
	@echo
	@echo "Done. Run 'make on' or '$(AWAKE) on' to start."

uninstall:
	@echo "==> uninstalling agents"
	-"$(AWAKE)" uninstall
	@echo "==> removing scripts from $(BIN_DIR)"
	rm -f "$(AWAKE)" "$(HID)"
	@echo "Done."

schedule:
	"$(AWAKE)" schedule

unschedule:
	"$(AWAKE)" unschedule

on:
	"$(AWAKE)" on

off:
	"$(AWAKE)" off

enable:
	"$(AWAKE)" enable

disable:
	"$(AWAKE)" disable

status:
	"$(AWAKE)" status

$(BIN_DIR):
	mkdir -p "$(BIN_DIR)"
