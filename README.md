# Package Registry Benchmark Harness

A harness for benchmarking the performance of
building a project with Swift Package Manager
using the new [package registry interface](https://github.com/apple/swift-package-manager/pull/3023).

The example project in this benchmark harness includes
a few popular packages as its dependencies.
You can add or remove dependencies from the package manifest (`Package.swift`)
and re-run the benchmark on the new package dependency graph.

> **Important**:
> If you add or remove any of the dependencies,
> run `rake clobber` to clear the existing registry index,
> so that it can be rebuilt on the next benchmarking run.

## Requirements

- macOS 10.15\*
- Homebrew
- Swift 5.3+
- Ruby and Bundler

> \* This hasn't been tested on macOS 11 or Apple Silicon.

## Instructions

### Install the Swift package registry reference implementation

Clone the Swift package registry
[reference implementation](https://github.com/mattt/swift-registry),
install the system dependencies,
and build the project from source using the provided Makefile.

```terminal
$ git clone https://github.com/mattt/swift-registry.git
$ cd swift-registry
$ brew bundle
$ make install
```

Running these commands installs `swift-registry` to `/usr/local/bin`.
Verify that the executable is accessible from your `$PATH`
by running the following command:

```terminal
$ swift registry --help
USAGE: swift-registry <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init                    Initializes a new registry at the specified path.
  list                    Show all published package releases.
  publish                 Creates a new release of a package.
  serve                   Runs the registry web service locally.

  See 'swift-registry help <subcommand>' for detailed help.

```

### Build the package registry fork of Swift Package Manager

Clone [this fork](https://github.com/mattt/swift-package-manager)
of Swift Package Manager,
which adds support for dependency resolution with package registries.

```terminal
$ git clone https://github.com/mattt/swift-package-manager.git
$ cd swift-package-manager
$ git checkout package-registry-implementation
$ swift build -c release
```

### Configure the benchmark harness

If you haven't already,
clone the package registry benchmark harness.

```terminal
$ git clone https://github.com/mattt/swift-registry-benchmark-harness.git
$ cd swift-registry-benchmark-harness
```

Within the benchmark harness directory,
run the following command to create an `.env` file.

```terminal
$ cat > .env <<EOF
SWIFT_PACKAGE_MANAGER_BUILD_PATH=$(swift build -c release --show-bin-path --package-path path/to/swift-package-manager)
EOF
```

This `.env` file is used to set the
`SWIFT_PACKAGE_MANAGER_BUILD_PATH` environment variable
with a path to your local build of the Swift Package Manager fork,
that will be benchmarked against the current official release.

Next, open a new terminal window and start an HTTP tunnel using `ngrok`
to forward `localhost` on port `8080`.

```terminal
$ brew cask install ngrok
$ ngrok http 8080
```

Copy the HTTPS forwarding address
and use it to append the following line to `.env`
to set the `SWIFT_REGISTRY_URL` environment variable.

```terminal
$ echo "SWIFT_REGISTRY_URL=https://________.ngrok.io" >> .env
```

Finally,
run `bundle install` to install the Ruby libraries
necessary to run our benchmarks.

```terminal
$ bundle install
```

### Run the benchmarks

Once you've done all of the previous steps,
you can run the benchmarks with the following command.

```terminal
$ bundle exec rake benchmark --trace
```

## Results

Here are some preliminary results from running the benchmarks locally:

```terminal
$ bundle exec rake benchmark
time swift build
       38.60 real        85.35 user        10.92 sys

time ./spm build --enable-package-registry
       31.44 real        83.92 user         9.30 sys
```

<details>
<summary>System Information</summary>

```terminal
$ system_profiler SPHardwareDataType
Model Name: iMac
Model Identifier: iMac18,3
Processor Name: Quad-Core Intel Core i7
Processor Speed: 4.2 GHz
Memory: 40 GB

$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.15.7
BuildVersion:	19H15

$ swift --version
Apple Swift version 5.3.1 (swiftlang-1200.0.41 clang-1200.0.32.8)
Target: x86_64-apple-darwin19.6.0
```

</details>

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))
