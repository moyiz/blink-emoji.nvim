SHELL = /bin/bash
NVIM ?= nvim

.PHONY: all build

all: build

build:
	@$(NVIM) --headless --noplugin -c 'lua dofile("./scripts/data.lua").build("./lua/blink-emoji/emojis.lua")' -c qa

# vim: ft=make ts=4 noexpandtab
