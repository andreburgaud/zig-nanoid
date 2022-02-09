# zig-nanoid

Nanoid implementation in Zig

When I need a random ID, I commonly generate a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier). The [UUID specification](https://datatracker.ietf.org/doc/html/rfc4122) is precise and the specified algorithms supporting UUID are sound.

I realized that **Nanoid** was very popular among JavaScript afficionados. As a curiosity and to understand the underlying algorithms, I decided to implement Nanoid in Zig that I'm currently learning.

## Code

The code includes the nanoid implementation in file `nanoid.zig`, and a command line `main.zig` demonstrating how to use the library.

## Usage of the CLI

### Help

```
$ nanoid --help
Usage:
  nanoid                            Generate a nanoid with the default size (21) and default alphabet
  nanoid -s | --size <size>         Generate a nanoid with a custom size and default alphabet
  nanoid -a | --alphabet <alphabet> Generate a nanoid with a custom alphabet (requires the size)
  nanoid -h | --help                Display this help
  nanoid -v | --version             Print the version
Examples:
  nanoid
  nanoid -s 42
  nanoid -s 42 -a 0123456789
```

### Default

```
$ nanoid
bnX1GLQViedU3axkMeFH1
```

### Custom Size

```
$ nanoid --size 42
AO6gpj98L1J6bNKx-CCAbUjU060yoX8YtE6ntZNmZK
```

### Custom Size and Alphabet

```
$ nanoid --size 42 --alphabet 0123456789
523818966093355749724259496656326495868533
```

## Build

The build uses a `justfile` https://github.com/casey/just and as only be tested on Mac OS as of 1/24/2022.

To build in debug mode:

```
$ just build
...
```

To build in release mode:

```
$ just release
...
```

## Test

```
$ just test
...
```

## References

I did not find any concrete specs similar to the UUID specs, and referred to some of the existing implementations.

### Implementations

* https://github.com/ai/nanoid (MIT License)
* https://github.com/matoous/go-nanoid (MIT License)
* https://github.com/puyuan/py-nanoid (MIT License)

### Other References

* [Why is NanoID Replacing UUID?](https://blog.bitsrc.io/why-is-nanoid-replacing-uuid-1b5100e62ed2)

