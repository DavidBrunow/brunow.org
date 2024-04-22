# CI Tooling

Storing CI tools in a centralized location to be used across the pipelines for
multiple projects.

@Metadata {
  @Available("Brunow", introduced: "2024.04.21")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "allChecksHavePassed",
    alt: "Screenshot of the GitHub interface showing that all CI checks have passed."
  )
}

## Overview

When I was working at American Airlines, I took charge of the CI architecture
for Apple platforms. The CI supported the main American Airlines customer-facing
app, which was modularized with each module living in its own repo. This meant
that we needed our CI architecture to support many repos. Since CI architecture
wasn't my primary responsibility (I was a senior iOS developer on a platform
team), I also needed the system to be easily maintained from as few places as
possible – I really did not want to update every module repo every time we
wanted to add new functionality to our CI pipelines.

My solution was to have the bare minimum of CI infrastructure in the repos and
have everything else living in a separate repo which could be cloned during the
CI job. When I first implemented this at American Airlines we were using GitHub
Enterprise for our source control platform and Jenkins for CI, so that meant
that every repo had a Jenkinsfile but nothing else related to CI. When I
migrated the team from GitHub Enterprise to the hosted GitHub and switched CI to
GitHub Actions, every repo had a yaml file defining their actions but nothing
else related to CI. In both of these situations, updating the Jenkinsfiles or
GitHub Actions yaml files across modules was painful, but it was also rare.

When I started working at Hilton, they already had a similar app architecture
that was modularized with each module in a separate repo. At that time, we were
using a hosted BitBucket instance for our source control platform and Jenkins
for CI so I implemented a similar pattern to what I had at American Airlines –
each repo only had a Jenkinsfile in it and all the tools were hosted in a
separate repo. Then when I migrated the team to a hosted GitLab instance, I was
able to build things in such a way that each repo had no references to CI in the
codebase – instead, the settings for each repo point to a centralized
configuration file in that same separate repo that holds the rest of the CI
tooling.

The current state of our CI architecture is working really well for us, so in
this post I'd like to share one bit that I think is critical – this separate
repo of CI tooling that provides everything a repo needs to run its CI jobs.

## The CI Tooling Repository

### What It Is

The CI Tooling repository is simply another repo that holds all the tools needed
for CI, with only two things that make it work differently from other repos:

* The repository does not use the main branch, instead it uses a branch per
supported platform
* The repository knows how to "unpack" itself so that its contents get put in
the right places

Let's talk through each of those in more detail.

#### Branch per Supported Platform

When I say "supported platform" here, I mean the type of thing being built. For
example, at Hilton the CI infrastructure I've built supports both our Android
app and our apps for Apple platforms (iOS, watchOS, and macOS command line
tools). Therefore, our CI Tooling repo has two primary branches, `apple` for
Apple platforms, and `android` for the Android app.

When we want to make improvements to our Apple CI, we create a branch off of our
`apple` branch, do the work, and create a merge request back into the `apple`
branch. This does mean some duplicated work at times – some things we do on CI
are common across platforms, like tagging releases – but my current stance is
that that duplicated work is less effort and less error-prone than putting all
our tooling together onto one branch. We're also looking into ways to abstract
out some of that duplicated work.

> Note: In reality, our naming at Hilton is not quite this simple at the moment
> because I thought it would be useful to have more specific branch naming. The
> branch name we use for Apple platforms is currently
> `apple/xcode14-dangerSwiftLint-dangerSwiftFormat` – I thought that including
> the capabilities enabled by the branch in the branch name would be useful but
> it simply made things more complicated while providing no benefit.
>
> We'll be moving to simpler names in the near future which is why I feel OK
> putting this in a note rather than inline above.

#### Unpacking the CI Tooling

For maximum flexibility, it is really useful for the CI tooling repo to know how
to put its tools in the right place. One example is the Dangerfile – it must be
in the root of the repo on which you want to run Danger. But maintaining a
separate Dangerfile in every repo when you have tens of repos is unwieldy. It is
much simpler to have a single Dangerfile in the CI tooling repo which can then
be placed in the right place when unpacked. And it is much more flexible for the
CI Tooling repo to own that unpacking so that its contents can be re-organized,
or new contents can be added, without anything outside the repo needing to be
changed.

To do that, the CI tooling repo needs a script which I like to call `unpack.sh`.
This script does two main things:

1. Deletes the .git folder from the checked-out CI tooling repo so any git
operations will be performed on the repo where the CI job is being run, and
2. Puts files where they are needed for CI to function properly

An `unpack.sh` that moves a Dangerfile.swift to the right place could look like
this:

```shell
#! /bin/sh

rm -rf $(dirname "$0")/.git

# Move things out of the CI-Tooling repo here
mv $(dirname "$0")/Dangerfile.swift $(dirname "$0")/..
```

### What Tools We Keep In It

These are the kinds of tools I like to keep in the CI Tooling repo:

* Danger Swift pre-built binaries, both executable and library
* Dangerfile
* Pre-built Swift tool to parse formatted commits
* Pre-built swiftlint binary
* Pre-built Swift tool to show public API diffs
* Fastlane files (Fastfile and Matchfile)
* Any other pre-built binaries or tools that are only used on CI

### What We Do Not Keep In It

There are some things that we want in common across all our modules that we do
not keep in CI Tooling. The determinant for this is whether developers need to
use those things locally as well, such as configuration files for SwiftLint and
Swift Format. We want our developers to get warnings and errors from those tools
early, in their IDE, so we need those configurations inside the module repos
rather than being in CI Tooling.

### How to Use It

Using this repo is fairly simple – clone the repo with a depth of 1 to only
clone the last commit, run the `unpack.sh` script, and then use the tools within
the repo as you would in any other script. For example:

```shell
...
git clone https://www.github.com/DavidBrunow/CI-Tooling.git --depth 1
./CI-Tooling/unpack.sh
fastlane run_tests
...
```

### Keys to Success

The biggest key to success is ensuring that you have consistency across your
different repos. This means having a standard folder structure, standard tools
used, code quality standards, and one module per repo. A bonus side effect of
this approach is that humans love consistency as well – it will be easier for
your team to work within consistent repos than it would be if every repo follows
its own rules.

But also, you will always have exceptions.

Sometimes it makes sense to special case those exceptions in your tooling. For
example, we have some legacy repos that we don't want to use `swift-format` on
because it would cause a massive amount of churn and we don't see the value in
that churn with the legacy code. We have chosen to special case those repos by
testing for the existence of a `.swift-format` configuration file in the
repo. When possible, I like to use something specific to the tool being used to
function like a feature flag. For other situations, we've had to special case by
individual module names, which I only do if there is no other way to solve the
problem.

Sometimes it makes sense to have entirely different tooling for different
contexts. For example, we have different CI pipeline definitions for modules vs.
the main app – there are enough differences between the two that it is easier to
maintain two different files, each with a clear focus, than to try to put
everything into a single file.

### Example

I've setup an example of my CI Tooling pattern in the repo for a 
[macOS command line tool that parses conventional commits](https://github.com/DavidBrunow/swift-conventional-commit-parser).

You can see the "client" side in the [pull request GitHub action](https://github.com/DavidBrunow/swift-conventional-commit-parser/blob/main/.github/workflows/pull_request.yml). It is simple enough that I can just
copy it here:

```yml
on:
  pull_request:

jobs:
  ci_tooling:
    uses: DavidBrunow/CI-Tooling/.github/workflows/macos-tools-pull-request-action.yml@apple
    permissions:
      pull-requests: write
```

Lines 1 and 2 say that this action should be run on pull requests. Line 6 says
that this pipeline should use the shared pipeline in my CI-Tooling repo, using
the configuration in `.github/workflows/macos-tools-pull-request-action.yml` on
the branch `apple`. Lines 7 and 8 give the shared pipeline permission to add
comments to the pull request, which is needed for Danger Swift to add its
feedback.

You can see the shared CI Tooling side for that action in 
[this configuration file](https://github.com/DavidBrunow/CI-Tooling/blob/apple/.github/workflows/macos-tools-pull-request-action.yml). This file is more
complex because it is doing all the work – the client's file is only calling
into this one. I'm not going to go through it line by line because most of it is
specific to what I want to do on CI and might be a good starting point for you,
but you also may already have all those bits figured out. But line 31 is
important:

```shell
export SCHEME=`xcodebuild -list -json | jq -r '.workspace.schemes[0]'`
```

The script in the CI Tooling repo is generic and does not know what project it
is working on. Therefore it needs to figure out what scheme to use for running
tests, which it gets from the `xcodebuild -list -json` command. Making this
tooling generic means that it cannot make assumptions. This makes things more
difficult to initially get setup but makes adding new clients simple and
straightforward.

> Warning: Do not use my CI Tooling repo – always have your own that is
> completely under your control! If you use my repo then I have too much access
> to your CI pipelines and, theoretically, could do bad things. I wouldn't do
> that because I'm a nice person, but you still shouldn't trust me.

> Note: When using these shared configuration files on both GitHub and GitLab, a
> new pull request must be opened to get the latest version of the shared
> configuration file. Both platforms cache the configuration file when the pull
> request is opened.

You can also poke around that repo and see the other shared CI tools that I
have, some of which I plan to talk more about in future blog posts.
