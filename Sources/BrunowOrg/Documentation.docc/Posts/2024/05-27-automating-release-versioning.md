# Automating Release Versioning

Implementing tools and patterns to ship code as soon as it is ready.

@Metadata {
  @Available("Brunow", introduced: "2024.05.27")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "conventionalCommitParserReleaseNotesFromDanger",
    alt: "Screenshot of a comment containing release notes on a GitHub pull request made by a GitHub Action using Danger Swift. The release notes were generated using my Swift Conventional Commit Parser tool."
  )
}

By adopting a standard called
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for the
git commits on your repo, and adding a tool that parses those commits, you can
automate the versioning of code that follows semantic versioning. I've written a
tool that parses Conventional Commits and I'll talk through how I use it to
automate my releases.

## About Conventional Commits

Conventional commits are a style of commit that originated in the Angular
development team and are meant to solve the problem of automating versioning. I
came across the idea of conventional commits years ago, before the standard
linked above was created, when looking to automate module releases at a previous
job.

Conventional commits are git commits which follow a specific format, for
example:

```
feat: Add endpoint to the InputField API for formatting
```

The `feat:` prefix in this format indicates that the change is a feature, which
means that the semantic version's minor version should be increased by one, and
the description for that feature is "Add endpoint to the InputField API for
formatting".

## Implementing Conventional Commit Parsing

To implement this parsing, we need two things:

1. An automation workflow that uses the parsed values to inform versioning, and
1. Ergonomic interaction points to inform the person using these formatted
commits about what the automation does

I've written a command line tool, [Swift Conventional Commit Parser](https://github.com/DavidBrunow/swift-conventional-commit-parser),
which is integral to the workflow I use for release automation.[¹](<doc:05-27-automating-release-versioning#Footnotes>)

Swift Conventional Commit Parser has two commands, one for running on a pull
request and one for running on a branch which should create releases. 
The two commands behave almost exactly the same, so once you've learned one
there isn't much to learn about the other.

These commands were designed for the place we need them in our automation, so
let's talk about how the pull request and release automation works. Throughout
the remainder of this, I'm going to call the Swift Conventional Commit Parser
the "commit parsing tool" or "the tool" for the sake of brevity.

### Pull Request Automation

I choose to use the commit parsing tool in the part of my pull request
automation that runs tests. I do that because I use Danger Swift in that
automation to report test results back to the pull request and it is simple to
add the extra information from the commit parsing tool. This is what my [GitHub
Action YAML for macOS command line tools](https://github.com/DavidBrunow/CI-Tooling/blob/apple/.github/workflows/macos-tools-pull-request-action.yml#L15) looks like today for that automation:

```yaml
...
jobs:
...
  test:
    runs-on: macos-14
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      TARGET_BRANCH: ${{ github.base_ref }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Run Tests
        run: |
          git clone -b apple https://github.com/DavidBrunow/CI-Tooling.git CI-Tooling --depth 1
          ./CI-Tooling/unpack.sh
          ./create_fixtures.sh
          gem install xcpretty
          gem install xcpretty-json-formatter
          defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
          brew install jq
          export SCHEME=`xcodebuild -list -json | jq -r '.workspace.schemes[0]'`
          xcodebuild test -scheme $SCHEME -destination "OS=13.0" -derivedDataPath ../DerivedDataTests -enableCodeCoverage YES -resultBundlePath ../DerivedDataTests/coverage.xcresult | XCPRETTY_JSON_FILE_OUTPUT=result.json xcpretty -f `xcpretty-json-formatter`
          defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool NO
          brew install npm
          npm install -g danger
          ./CI-Tooling/swift-conventional-commit-parser pull-request -t "origin/$TARGET_BRANCH" > release_notes.json || true
          ./CI-Tooling/danger-swift ci
```

There is a lot of noise in there that isn't completely relevant to what we're
talking about here, but I think the extra context is useful for seeing how
things fit together.

> Note: This example uses my shared CI Tooling repo pattern, which stores
> everything needed for CI in one repo. You can learn more about that in my
> [blog post about it](<doc:04-21-ci-tooling>).

The key part for this discussion comes on the next to last line, where the 
parser tool is called:

```
./CI-Tooling/swift-conventional-commit-parser pull-request \
  -t "origin/$TARGET_BRANCH" \
  2> swift_conventional_commit_parser_error.txt \
  > release_notes.json \
  || true
```

This command takes in a target branch, which we're passing along from the pull
request's target branch, and outputs any errors to a file called error.txt and
any successful output to a file called `release_notes.json`. The `|| true` at
the end ensures that this command does not exit in an error. This is needed to
ensure the pipeline continues running and allows Danger Swift to report
everything, including any errors, back to the pull request.

The only error the tool will emit is when there are no formatted commits on the
pull request branch. This error message is a great place to help folks learn
about Conventional Commits and can be customized using the optional `-n`
argument to pass in your own error message, which could link to how you use
Conventional Commits in your CI system. By default, the error message links to
the README on the Swift Conventional Commit Parser repo, which talks about how
I use Conventional Commits.

The standard output from the tool is JSON. Here is an example:

```json
{
  "bumpType" : "minor",
  "releaseNotes" : "## [1.1.0] - 1970-01-01\n\n### Features\n* Awesome feature
(abcdef)\n\n### Chores\n* Change the \"total\" field (abcdef)",
  "version" : "1.1.0"
}
```

We can take this output, or the error message, and [use it in the Dangerfile](https://github.com/DavidBrunow/CI-Tooling/blob/apple/Dangerfile.swift#L6)
to report back to the pull request:

```swift
if FileManager.default.fileExists(atPath: "release_notes.json"),
  let contents = FileManager.default.contents(atPath: "release_notes.json"),
  let jsonObject = try? JSONSerialization.jsonObject(
    with: contents, 
    options: []
  ) as? [String: Any],
  let releaseNotes = jsonObject["releaseNotes"] as? String {
  markdown("Release notes:\n\(releaseNotes)")
} else if FileManager.default.fileExists(atPath: "swift_conventional_commit_parser_error.txt"),
  let contents = FileManager.default.contents(atPath: "swift_conventional_commit_parser_error.txt"),
  let errorMessage = String(data: contents, encoding: .utf8),
  errorMessage.isEmpty == false {
  fail(errorMessage)
} else {
  fail("No formatted commit.")
}
```
This code in the Dangerfile will output errors on the pull request like this:

![Screenshot of pull request comment showing that there was an error due to no formatted commits being found. This error also has a link to documentation to learn more about Conventional Commits.](conventionalCommitParserErrorFromDanger)

And will output the release notes on the pull request like this:

![Screenshot of pull request comment showing release notes generated by the commit parsing tool. The release notes have a heading with the version and the date, and then sections for "Features" and "Chores". Each of the items under the features and chores has a description of the change and the commit hash.](conventionalCommitParserReleaseNotesFromDanger)

And that's what it takes to make the pull request automation functional and
ergonomic. Next, let's talk about the release automation.

### Release Automation

The commit parsing tool also needs to run on merges to release branches and the
release command is built for that. The tool acts the same way as for pull
requests, with the exception of not needing to pass in a target branch. Here is
what the [GitHub Action YAML](https://github.com/DavidBrunow/CI-Tooling/blob/apple/.github/workflows/macos-tools-release-action.yml#L7)
looks like today for the release automation of macOS command line tools:

```yml
...
jobs:
  release:
    runs-on: macos-14
    steps:
      - uses: actions/create-github-app-token@v1
        id: app-token
        with:
          app-id: ${{ vars.RELEASE_BOT_APPID }}
          private-key: ${{ secrets.RELEASE_BOT_PRIVATE_KEY }}
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ steps.app-token.outputs.token }}
      - name: Release
        run: |
          git clone -b apple https://github.com/DavidBrunow/CI-Tooling.git CI-Tooling --depth 1
          ./CI-Tooling/unpack.sh
          brew install jq
          # Run conventional commit parser
          CONVENTIONAL_COMMIT_PARSER_OUTPUT=`./CI-Tooling/swift-conventional-commit-parser release`
          if [[ "$BUMP_TYPE" == "none" ]]; then exit 0; fi
          VERSION=`jq -r '.version' <<<"$CONVENTIONAL_COMMIT_PARSER_OUTPUT"`
          RELEASE_NOTES=`jq -r '.releaseNotes' <<<"$CONVENTIONAL_COMMIT_PARSER_OUTPUT"`
          # Bump version
          FILE_THAT_NEEDS_VERSION_UPDATE=`grep -lr "@main" ./Sources`
          sed -i '' -E "s/(version: \").*(\")/\1$VERSION\2/" $FILE_THAT_NEEDS_VERSION_UPDATE
          # Update CHANGELOG
          RELEASE_NOTES=`sed 's/$/\\\\/g' <<<"$RELEASE_NOTES"`
          sed -i '' -f - ./CHANGELOG.md <<EOF
          7 i\\
          \\
          $RELEASE_NOTES
          EOF
          # Push changes without running CI
          git add $FILE_THAT_NEEDS_VERSION_UPDATE
          git add CHANGELOG.md
          git commit -m "Release $VERSION [skip ci]"
          # Add tag
          git tag "$VERSION"
          git push origin
          git push origin "$VERSION"
```

> Warning: In order for the automation to be able to push to a protected branch,
> I created a GitHub App which I can use as a bot and then added that bot to the
> bypass list for the ruleset that is protecting branches.
> 
> While setting that up is outside the scope of this post, I do want to note
> that this can be dangerous if setup incorrectly. Before doing so, ensure you
> consider that anyone with write access to the repository would theoretically
> be able to modify a GitHub Action workflow to push changes to those protected
> branches. This works fine for me because I am not giving write access to
> anyone else – your approach will vary based upon your needs.

This automation first installs [jq](https://jqlang.github.io/jq/) because we'll
be doing all our JSON parsing of the tool's output in the automation's shell
script. If the `bumpType` is equal to "none", and therefore no release is
needed, the automation exits early. Otherwise, the release notes are added to
the changelog, the code's version is updated, the changes are added and
committed to git, the repo is tagged, and all the changes are pushed to origin.
The details about how this automation works is specific to the way I have my
codebases setup, but the general process would be the same for any codebase.

With this automation in place, every commit to a release branch creates a new,
properly semantically versioned release that can be distributed to your users.

That's all it takes to setup this automated semantic versioning. Next I'll talk
about some approaches for this kind of automation that I rejected, in case
you're interested.

## Rejected Alternative Approaches

When figuring out how to automate versioning a few years ago, I considered and
rejected a couple of approaches. I think it is useful to talk through why I
rejected them, because at first glance they seem like a simpler approach than
what I follow today. Plus, talking through them reveals what is important about
the problem space of automating versioning. I'll also talk through another
approach that I did not consider a few years ago but that I think is relevant to
the thought process:

* Always bumping the patch version for any non-breaking changes
* Using specially formatted branch names
* Using specially formatted pull request titles

### Rejected approach: Always bumping the patch version for any non-breaking changes

This is an approach that I didn't consider when I first starting thinking about
automating versioning, but I've recently heard that other folks might be doing
this for their build automation. I'd reject this approach for a few reasons: 

1. Always bumping the patch version means that you aren't actually following
semantic versioning, and I believe the most value you get out of semantic
versioning is in the "semantic" part of it. Always bumping the patch version
loses the semantic meaning of a version, which brings me to my second reason.
1. As a client of a library that bumps versions like this, I cannot
trust the versioning to provide me with any information about how easy it will
be to adopt the changes.
1. If you always bump the patch version, there is no "room" between versions to
make a hotfix. For example, if I need to make a hotfix for version 1.0.1 but
versions 1.0.2, 1.0.3, 1.0.4, and 1.0.5 have already been created, I have to get
creative in my version naming to create a version between 1.0.1 and 1.0.2. If I
were OK with the first point above, I'd bump the minor version by default to
avoid this issue – but I'm definitely not OK with the first point.

### Rejected approach: Using specially formatted branch names

I considered using specially formatted branch names, but that approach meant you
either needed to know what kind of change you would be making when you started
your effort, or you would have to change your branch name later in the effort to
match the type of change. And while I like small efforts, one change per branch
seemed overly limiting. Plus, in git, branches are ephemeral. I believe that any
automated versioning should be idempotent and stable over time – no matter how
many times it is run, given the same inputs it should always produce the same
versions – and that would not be true when using branch names due to their
inherent instability. Therefore I believe we should base our versioning on
things that git considers to be more stable.

### Rejected approach: Using specially formatted pull request titles

After rejecting specially formatted branch names, I considered something more
flexible – pull request titles. Since pull request titles can be changed at any
point in the pull request process, one could change the format of it without
disrupting the remainder of the workflow too much since you don't need to create
a new pull request. But this approach has many of the same limitations as using
branch names around one change per pull request and the automated versioning not
being idempotent and stable over time.

Even worse, this approach would couple your automated versioning to your source
control platform (GitHub, GitLab, etc.), which would be overly limiting in the
long term.

## Footnotes

[1](<doc:05-27-automating-release-versioning#Implementing-Conventional-Commit-Parsing>): There are [many other tools out there that can parse conventional commits](https://www.conventionalcommits.org/en/about/#tooling-for-conventional-commits),
many of those may fit your needs as well, but I know my tool better than those.
