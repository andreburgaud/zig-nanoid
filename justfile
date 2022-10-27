APP := "nanoid"

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

# Build release with UPX compression (does not work on Linux)
release-upx:
	zig build-exe -O ReleaseSmall --name {{APP}} --strip -fsingle-threaded  main.zig
	-upx {{APP}}

# Build release
release:
	zig build-exe -O ReleaseSmall --name {{APP}} --strip -fsingle-threaded  main.zig

# Test
test:
	zig test nanoid.zig

# Run
run:
	zig run main.zig

# Remove binaries and cache
clean:
	-rm {{APP}}
	-rm -rf zig-cache
