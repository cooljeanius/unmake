.POSIX:
.SILENT:
.PHONY: all

all:
	rustup component add \
		clippy \
		rustfmt
	cargo install --force \
		cargo-audit \
		crit@0.0.7 \
		cross@0.2.5 \
		tinyrick@0.0.13
