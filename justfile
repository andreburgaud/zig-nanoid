APP := "nanoid"
DIST := "dist"
VERSION := "0.4.0"

alias b := build
alias c := clean
alias r := release
alias ru := release-upx
alias t := test

# Help
default:
	@just --list

# Build
build:
	zig build-exe --name {{APP}} main.zig

# Build release with UPX compression
release-upx:
	zig build-exe -O ReleaseSmall --name {{APP}} -fstrip -fsingle-threaded  main.zig
	-upx {{APP}}

# Build release
release:
	zig build-exe -O ReleaseSmall --name {{APP}} -fstrip -fsingle-threaded main.zig

# Distributions
dist: init-dist dist-linux dist-mac-amd64 dist-mac-arm

# Create
init-dist: clean
	-mkdir {{DIST}}

# Distribution for linux
dist-linux:
	zig build-exe -O ReleaseSmall --name {{APP}} -fstrip -fsingle-threaded -target x86_64-linux-musl main.zig
	zip -j {{DIST}}/{{APP}}-{{VERSION}}_linux_x86_64.zip {{APP}}

# Distribution for Mac amd64
dist-mac-amd64:
	zig build-exe -O ReleaseSmall --name {{APP}} -fstrip -fsingle-threaded -target x86_64-macos-none main.zig
	zip -j {{DIST}}/{{APP}}-{{VERSION}}_mac_amd64.zip {{APP}}

# Distribution for Mac arm64
dist-mac-arm:
	zig build-exe -O ReleaseSmall --name {{APP}} -fstrip -fsingle-threaded -target aarch64-macos-none main.zig
	zip -j {{DIST}}/{{APP}}-{{VERSION}}_mac_arm64.zip {{APP}}

# Distribution for Windows amd64
dist-win-amd64:
	zig build-exe -O ReleaseSmall --name {{APP}} -fstrip -fsingle-threaded -target x86_64-windows-gnu main.zig
	zip -j {{DIST}}/{{APP}}-{{VERSION}}_win_amd64.zip {{APP}}

# Test
test:
	zig test nanoid.zig

# Run
run:
	zig run main.zig

# Remove binaries and cache
clean:
	-rmm -rf {{DIST}}
	-rm {{APP}}
	-rm -rf zig-cache

# Push and tag changes to github
github-push:
    git push
    git tag -a {{VERSION}} -m 'Version {{VERSION}}'
    git push origin --tags