APP := "nanoid"

alias b := build
alias c := clean
alias r := release
alias ru := release-upx
alias t := test

default:
	@just --list

build:
	zig build-exe --name {{APP}} main.zig

# Tested successfully on MacOS - Not working on Linux
release-upx:
	zig build-exe -O ReleaseSmall --name {{APP}} --strip -fsingle-threaded  main.zig
	-upx {{APP}}

# Works on Linux
release:
	zig build-exe -O ReleaseSmall --name {{APP}} --strip -fsingle-threaded  main.zig

test:
	zig test nanoid.zig

run:
	zig run main.zig

clean:
	-rm {{APP}}
	-rm -rf zig-cache
