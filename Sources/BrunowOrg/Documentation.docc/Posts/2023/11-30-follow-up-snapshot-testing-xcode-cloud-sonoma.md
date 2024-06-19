# Follow up: Snapshot Testing with Xcode Cloud on Sonoma

Working around a change in simulator configuration. 

@Metadata {
  @Available("Brunow", introduced: "2023.11.30")
  @PageColor(purple)
}

## Backstory

In my [last blog post](<doc:10-21-here-be-dragons-snapshot-testing-edition>) I
discussed an 
[issue I ran into when running snapshot tests on Xcode Cloud when the runners were using macOS Sonoma](<doc:10-21-here-be-dragons-snapshot-testing-edition#macOS-Sonoma-Rendering-Differently-on-Xcode-Clouds-Intel-machines>):

> Quote from that blog post: OK [simulators on macOS Sonoma have] 34 preferred languages, cool.
> Running this same test on macOS Ventura returns 1 preferred language.

As I described later in that post, those preferred languages include Arabic
which causes snapshots to be rendered differently than when Arabic is not in the
preferred languages.

My workaround at the time was to avoid using Sonoma but fortunately I've now had
a chance to find a solution.

## Controlling the Xcode Cloud Simulator Environment

I had filed a Feedback with Apple for the issue while I was writing that
previous blog post. I shared that Feedback with an iOS developer community I'm a
part of and Francis Chary recommended that I use a pre-xcodebuild script to
setup the  simulator the way I needed it to be setup. That recommendation led to
me create a `ci_pre_xcodebuild.sh` script which sets "en" as the only language
and "en_US" as the only locale on all the simulators on the build machines used
for testing (see [this documentation](https://developer.apple.com/documentation/Xcode/Writing-Custom-Build-Scripts)
for more information about the scripts that Xcode Cloud supports). Here is the
script ([gist](https://gist.github.com/DavidBrunow/3ef4a1fa3e61c09411270c7c181c3174)):

```sh
#!/bin/sh

if [[ $CI_XCODEBUILD_ACTION == "test-without-building" ]]
then
  # Setup the simulators so that they only have one preferred language.
  # This works around an issue where the simulators on Sonoma have multiple
  # preferred languages which include Arabic and therefore provide different
  # results when running snapshot tests.
  #
  # This solution was inspired by: https://stackoverflow.com/a/74335552
  brew install jq
  brew install parallel

  # In my testing running more than 2 jobs in parallel led to flaky tests
  # where the simulators would error out.
  xcrun simctl list -j "devices" \
    | jq -r '.devices | with_entries(select(.key | contains("iOS"))) | map(.[] | select(.isAvailable == true)) | .[] .udid' \
    | parallel --jobs 2 'echo {}; xcrun simctl boot {}; xcrun simctl spawn {} defaults write "Apple Global Domain" AppleLanguages -array en; xcrun simctl spawn {} defaults write "Apple Global Domain" AppleLocale -string en_US; xcrun simctl shutdown {};'
fi
```

This script fixes the issue and now all my tests pass on Xcode Cloud runners
using Sonoma. 🎉
