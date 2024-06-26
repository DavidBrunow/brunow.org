# How I Like to Use Danger

Danger is an excellent tool for providing build tool feedback on pull requests
with a flexible plugin architecture, but I find that limiting that flexibility
makes it more ergonomic.

@Metadata {
  @Available("Brunow", introduced: "2024.04.22")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "exampleDangerReport",
    alt: "Screenshot of a comment on a GitHub pull request made by a GitHub Action using Danger Swift."
  )
}

## Overview

Danger is a tool that connects your CI build systems to your pull requests. This
provides an excellent developer experience where (most of the time) they can
know whether a pull request is in a healthy state by looking at a comment
directly on that pull request.

This connection between the CI build systems and the pull request allows teams
to implement automated code health tools which can give quick feedback to about:

* Warnings introduced by the changes
* Linting and code formatting errors based upon agreed-upon standards
* Code coverage percentages
* Any other information which can be automated

Danger has two base implementations, one in Ruby and one in JavaScript. On top
of that, there are Danger runners written in Kotlin and Swift which hand off the
bulk of the work to Danger JS but allow for Dangerfiles, the file which define
what Danger should do, written in languages that will be more familiar to
mobile developers. I prefer to use Danger Kotlin when building CI for Android or
other Java-based projects and Danger Swift when building CI for Apple
platforms, because I find it is easier to get folks involved in CI code when it
is in a language they use every day. It is also more likely that folks in a
specific community will create plugins for Danger that you could find useful –
folks using Danger Swift will be more likely to create plugins around Xcode and
other Apple tooling than folks using Danger Kotlin would.

OK I think that is enough of an intro to Danger, next I'll talk through the
flexibility built-in to Danger through its plugin system.

## Danger's Architecture

Danger is architected to allow for anyone to create their own plugins that can
provide information to Danger which can then be shown on a pull request. I've
relied on this ability to add plugins to add extra checks that are specific to
our codebase, like a localization linter which ensured that Xcode's command line
tools could extract keys for localization. Out-of-the-box, Danger allows for
these plugins to be dynamically included at run time which is a lot of
flexibility, especially when using statically typed languages like Kotlin and
Swift.

This plugin architecture is very clever and lets people get started with Danger
quite easily. But it is a bit complex. Let's talk through the moving pieces in
Danger Swift, all of which applies to Danger Kotlin as well:

* The Dangerfile
* The Danger Swift Library
* The Danger Swift Runner
* The Danger JS Runner

Here is how they are all connected. The Danger Swift runner builds and runs the
Dangerfile while linking in the Danger Swift library. The Danger Swift runner
then uses the Danger JS runner to interact with the source control platforms
(GitHub, GitLab, BitBucket, etc). Let's talk through each of these components in
detail.

### The Dangerfile

The Dangerfile, `Dangerfile.swift` for Danger Swift, is the code file that
defines everything that Danger will do when Danger is run in a CI pipeline. Here
is a simplified example of a Dangerfile from
[Danger Swift's documentation](https://danger.systems/swift/):

```swift
import Danger
let danger = Danger()

// Add a CHANGELOG entry for app changes
let hasChangelog = danger.git.modifiedFiles.contains("changelog.md")

if (!hasChangelog) {
    warn("Please add a changelog entry for your changes.")
}
```

This simple example checks to see if the `changelog.md` file has been modified
as part of the pull request and, if not, adds a warning to the pull request
letting the developer know that they need to update the changelog. Providing
that feedback through this automation means that a contributor to a repo can
quickly learn what changes they need to make to meet the standards of that repo.
Plus, the maintainer of the repo can focus on things only humans can do, like
making sure that the pull request follows their architectural guidelines.

At the beginning of every Dangerfile, the Danger library must be imported. Let's
talk about how that works next.

### The Danger Swift Library

The Danger Swift library is what powers the different things you can do in a
Dangerfile. The library is built with the core Danger functionality plus any
plugins that you've chosen to integrate. The documentation recommends
integrating Danger into your workflow by
[adding Danger Swift and any related plugins to your `Package.swift` file](https://danger.systems/swift/guides/about_the_dangerfile#swift-package-manager-more-performant).
This allows the Danger Swift library to be built as-needed with just the plugins
you've defined and puts everything in the right place so Swift can find the
library when running the Dangerfile.

I'm not a fan of this approach but I'll talk through that later when I go
through how I like to use Danger.

### The Danger Swift Runner

The Danger Swift runner is a fairly simple tool that ties everything together.
As mentioned before, it runs the Dangerfile while also providing the path to the
Danger Swift library. This could easily be a standalone executable, but in the
recommended setup, linked above in the Danger Swift library section, the runner
is re-built through Swift Package Manager every time it is needed to be run.

In addition to running the Dangerfile, the Danger Swift runner runs the Danger
JS runner, which handles all communication with the source control platforms.

### The Danger JS Runner

As mentioned before, the Danger JS runner is the common tool across the
different Danger "front-ends" (Danger Swift, Danger Kotlin, etc.) that handles
all the interactions with source control platforms. These interactions are
bi-directional because the Dangerfile needs access to information from those
platforms and also needs to send information to them for warnings, errors, and
informational messages.

Strangely, I don't see anything about how to install Danger JS, or even the need
to do so, in [the Danger Swift documentation](https://danger.systems/swift/guides/getting_started). I
prefer to install Danger JS through npm, which I prefer to install through
Homebrew. Here are the steps to do that:

```sh
brew install node
npm install -g danger
```

## How I Setup Danger

Now that we know how all the pieces fit together, I'll gripe about the things
I don't like about this approach and talk about how I like to set things up.

### Gripes

All of my gripes revolve around the need to use Swift Package Manager to build
and run the runner and library:

* I don't like to mix tooling and my app's dependencies
* I don't always want to use SPM
* I don't want to re-build Danger on every run
* The recommended approach is invasive to my project, requiring me to add a
folder that will not be used
* Due to the invasive nature of the recommended approach, applying the same
Danger configurations across multiple repos, and keeping those configurations in
sync, it creates a lot of manual overhead
* I like pre-built binaries

What I want is a pre-built executable for the Danger Swift runner, and a
pre-built framework for the Danger Swift library. Let's talk about how I make
that work.

### My Setup

> Note: This setup requires a fork of Danger Swift.

#### The Runner

The Danger Swift runner is already meant to be a standalone executable, so we
don't need to do too much there. We want to make sure that it is built as a
universal binary so it can run on both Apple Silicon and Intel, so we can build
it like this:

```sh
swift build -c release --arch arm64 --arch x86_64
```

Swift builds the `danger-swift` binary and puts it in the 
".build/apple/Products/Release/danger-swift" folder so we'll need to copy it
from there to where we need it. All of that is simple and straightforward. 

#### The Library

Building the library in a portable way isn't quite as nice, but we'll get to
that in a moment. First, since we want a portable library that can be used
anywhere, we need to find a way to build that library with all the plugins we
need. This approach requires choosing your plugins ahead of time and not being
able to do so at run time – if you want a new plugin you'll need to rebuild and
redistribute the library.

##### Integrating Plugins

Fortunately, Danger Swift has already gone through the process of integrating a
common plugin, SwiftLint, into the library so we can follow the maintainer's
lead and do the same thing for our plugins. There is already a "Plugins" folder
in the "Sources/Danger" folder and adding our plugin there is quite simple – we
copy the source code folder into the "Plugins" folder and then make whatever
changes are need to make the Danger library successfully compile again. Doing
that requires fixing any naming conflicts and, while we're in there, we'll fix
warnings around importing Danger by removing any `import Danger` code. Let's
walk through an example with a popular plugin, [DangerSwiftCoverage](https://github.com/f-meloni/danger-swift-coverage),
which gathers code coverage so it can be posted on pull requests.

1. Fork Danger Swift and clone the fork to your machine
1. Clone DangerSwiftCoverage to your machine
1. Copy the "Sources/DangerSwiftCoverage" folder from DangerSwiftCoverage into
the "Sources/Danger/Plugins" folder in Danger Swift. If you cloned the two repos
next to each other, the copy command from the root of the Danger Swift repo
would look like this: 

```sh
cp -r ../danger-swift-coverage/Sources/DangerSwiftCoverage Sources/Danger/Plugins
```
4. Open Danger Swift's Package.swift in Xcode and try to build the Danger
library.
1. Follow the compiler errors to fix all the build issues around multiple files
and types with conflicting names:  
    1. Rename the file "Sources/Danger/DangerSwiftCoverage/Models/Report.swift"
to "Sources/Danger/DangerSwiftCoverage/Models/DangerSwiftCoverageReport.swift"
    1. Rename the `File` struct on line 34 of "XcodeBuildCoverage.swift" to
`XcodeBuildCoverageFile` and update the type of `files` on line 26 of the same
file to use the `XcodeBuildCoverageFile` type.
    1. Remove the `import Danger` from the top of the "XcodeBuildCoverage.swift"
file.

OK, now we've integrated a plugin directly into the Danger library which means
that plugin will always be available in our Dangerfiles when linking against a
pre-built version of the library. Here are all the open source plugins I like
to include, and integrating them, or any others you may find, should follow the
same steps as above:

* [DangerSwiftCoverage](https://github.com/f-meloni/danger-swift-coverage) (mentioned above)
* [DangerXCodeSummary](https://github.com/f-meloni/danger-swift-xcodesummary) (yes, Xcode is misspelled, but still a good plugin)

##### Building a Portable Library

As the Swift package is setup, there is no way to create a portable library. The
reason is that the `swift build` command will not create a framework like we're
used to working with on iOS. Instead, it creates a folder full of object,
.swiftmodule, and .dylib files:

```sh
$ ls .build/apple/Products/Release                 
Danger-Swift.o                          Danger_Swift.swiftmodule    RunnerLib.o
Danger.o                                Logger.o                    RunnerLib.swiftmodule
Danger.swiftmodule                      Logger.swiftmodule          Version.o
DangerDependenciesResolver.o            OctoKit.o                   Version.swiftmodule
DangerDependenciesResolver.swiftmodule  OctoKit.swiftmodule         danger-swift
DangerFixtures.o                        PackageFrameworks           danger-swift.dSYM
DangerFixtures.swiftmodule              RequestKit.o                libDanger.dylib
DangerShellExecutor.o                   RequestKit.swiftmodule      libDanger.dylib.dSYM
DangerShellExecutor.swiftmodule         Runner.swiftmodule
```

This is not very portable. We need almost all of these files to be able to link
against libDanger.dylib. Plus, these files are tied to a specific Swift version
because [library evolution](https://www.swift.org/blog/library-evolution/) is
not turned on. This means that when you change the default version of Xcode on a
machine, and therefore change the default version of Swift, you'll need to
rebuild the Danger Swift library. I've worked around this in the past by keeping
an older version of Xcode on the build machines that is only used to run Danger
Swift, but it is easy to forget why you're doing that and inadvertently break
things.

> Note: It might be possible to use library evolution with this libDanger.dylib
and the object files, but I was not able to make it work.

To get a framework, which I find to be much more portable, you must use an Xcode
project file, which I've added on this
 [proof of concept pull request for showing how to have a pre-built library that uses library evolution](https://github.com/danger/swift/pull/579). That pull request
also changes the Danger Swift library's imports to be [`@_implementationOnly`](https://forums.swift.org/t/update-on-implementation-only-imports/26996)
imports which tells the linker that the symbols within those imports won't be
exposed publicly. And finally, that pull request tells the Danger Swift runner
to look for a "Danger.framework" to link against when running the Dangerfile.

Once that is done, you can run this command to generate the framework:

```sh
xcodebuild archive -project Danger.xcodeproj \
  -scheme Danger -sdk macosx -destination "generic/platform=macOS" \
  -archivePath "archives/Danger.framework"
```

I've added a
[shell script on that pull request that builds both the runner and the library](https://github.com/danger/swift/pull/579/files#diff-ee93d24b11504c134791a4e4232fc7ccb850be02de509fd76431a30509bf675e).

### Using this Setup

Now that we have an executable binary and a framework, how do we use them in our
CI jobs? Each of them is portable, so we can put them where we need them. I like
to store all of my CI tooling in a centralized place, which I've talked about in
my [previous blog post on CI tooling](<doc:04-21-ci-tooling>).

If you don't want to, or can't, use that centralized place, then you need to
make sure that the `danger-swift` executable and the Danger.framework library
are in the same directory when you run `danger-swift`.

Once you have them there, you'll want to do something like this in your CI job:

```sh
...
brew install node
npm install -g danger
danger-swift ci
...
```
