APP := "nanoid"

alias b := build
alias c := clean
alias r := release
alias t := test

default:
	@just --list

build:
	zig build-exe --name {{APP}} main.zig

release:
	zig build-exe -O ReleaseSmall --name {{APP}} --strip -fsingle-threaded  main.zig
	#-upx {{APP}}

test:
	zig test nanoid.zig

run:
	zig run main.zig

clean:
	-rm {{APP}}
	-rm -rf zig-cache
