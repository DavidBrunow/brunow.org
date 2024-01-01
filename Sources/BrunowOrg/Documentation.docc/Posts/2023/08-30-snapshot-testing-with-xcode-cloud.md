#  Snapshot Testing with Xcode Cloud
Working around unexpectedly sharp edges when using snapshot tests.

@Metadata {
  @Available("Brunow", introduced: "2023.08.30")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "snapshotTestFailures",
    alt: "Screenshot of snapshot test failures from Xcode Cloud."
  )
}

## Backstory

> Tip: If you don't want to read about the backstory and just want to get your
> snapshot tests working on Xcode Cloud then you might want to skip to the
> [section with the steps needed to get them working](#Getting-Snapshot-Tests-Working-on-Xcode-Cloud).

Over the last several weeks I've been working on a side project app as a way to
flex some product development muscles, build an entire app in the
[Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture),
and experiment with tools and processes that I don't
get to use in my day job. I've tried to be very intentional about adding complexity to
the project and therefore
started off simply by not worrying about modularity or organization and instead
just putting all of my Swift files into a single Xcode project and letting the
flow of creation take me where it would. To keep CI/CD simple I decided to use
Xcode Cloud and created a pipeline that would deploy a build to TestFlight every
time I merged to `main`. My simple process was to write a bit of code each day,
commit it to `main`, and then use the TestFlight build to get a feel for what
needed to be done next.

Last week I shipped my first bug that caused a regression in functionality
and decided that I'd gotten to the point of complexity where I
needed some automated tests. I hadn't been writing any tests to that point
because what I'd built was not complex and because I was still in a highly
experimental phase where tests would probably slow down the flow. But I think I
hit the tipping point where adding those tests would speed things up by limiting
potential backsliding from regressions.

Before I started writing tests I chose to do some [yak shaving](http://projects.csail.mit.edu/gsb/old-archive/gsb-archive/gsb2000-02-11.html)
so I could implement the module hierarchy that I wanted. Modularizing would allow
me to write tests targeted at specific features which I could build and run in
isolation as my app grows. So I shaved these yaks to modularize my app using
Swift Package Manager:

* Created a Package.swift file
* Defined all my modules and their dependencies in that file
* Copied my code to the proper locations for Swift Package Manager
* Added that Package.swift to my project
* Made API public until the app would successfully build again

This is a process I am very familiar with but it still took me some time and I
had to be patient with myself while doing it. Part of my mind was wanting me to
hurry up and get back to building things because that part of my mind does not
like to acknowledge that organizing and tidying up is part of the building
process.

OK so I had modules and now I was ready to add tests. As I mentioned earlier,
I'm using the Composable Architecture
for this app and since I'm familiar with using it from the day job I only had to
do minor refactoring around how I was generating UUIDs to support tests. I
started with a test around the regression that I'd found and used the test to
troubleshoot the issue. Once that was resolved I finished out tests around the
rest of the features in the app.

One of my modules is a "DesignSystem" module which has UI components with little
to no logic in them. Despite the lack of logic I still like to get some coverage
on their layout and how they behave in different environments (like light mode,
dark mode, and different Dynamic Type sizes) so I added some snapshot tests for
that using [Swift Snapshot Testing](https://github.com/pointfreeco/swift-snapshot-testing).

I ran all my tests locally and everything passed. 🎉

Now to get them running on Xcode Cloud. My experience with Xcode Cloud to this
point had been simple and easy so I expected the same with adding tests. But my
decision earlier to modularize meant that I needed to shave another yak or two
&mdash; Xcode Cloud wants a specific test target or a test plan to run tests
against and after modularizing I have multiple test targets. So I added a test
plan I named "AllTests" and included all the test targets in it. This was
oddly difficult because apparently there already was a test plan in the project
that was automatically generated and I had to delete that one and jump through
some other hoops. Eventually I had a test plan that I could use both locally and
with my Xcode Cloud tests. I merged the changes to `main` and waited to see the
green checkmark in Xcode Cloud.

All my snapshot tests failed on Xcode Cloud. 😿

## Figuring Out What Was Going Wrong

My tests were failing and I didn't know why so I went searching the internet for
clues, starting with the issues section of the Swift Snapshot Testing GitHub repo. I
found [this issue](https://github.com/pointfreeco/swift-snapshot-testing/discussions/553)
which described what I was seeing and had a lot of discussion including multiple
people who had resolved the issue. So I started naïvely implementing things that
were suggested in that thread without understanding the fundamentals of the
problem. And those things I tried did not work &mdash; I needed to learn a bit
more about how Xcode Cloud works to be able to understand the conversations on
that issue.

> While I had to do extra research to figure out what was going on I'd like to
> give all the credit for this approach to the folks on that GitHub issue,
> specifically Cameron Cooke and Oliver Foggin.

Since the approach I wanted to take mentioned adding a `ci_scripts` folder I
searched for documentation around that and found [this documentation for writing
custom build scripts on Xcode Cloud](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-the-CI-scripts-directory).
I didn't care about custom build scripts but this documentation discussed where
the `ci_scripts` folder needed to live, how to create it, and [this section about
resources in custom build scripts](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Add-resources-to-the-CI-scripts-directory).
That documentation gave me the underlying context I needed to fill in the
details I was missing from the GitHub issue.

## Getting Snapshot Tests Working on Xcode Cloud

> Some of this configuration to get snapshot tests working on Xcode Cloud is
> very specific to the way the project is setup. I'll try to call out those
> specific places but if your project is setup differently than mine then
> this may not work.
> 
> Also, two different approaches were discussed in the GitHub issue that I
> linked above but I believe the approach that I'll go through here is more
> straightforward and maintainable.

At a high level, this is what we need to do:

1. Create a `ci_scripts` directory where Xcode Cloud expects it to be.
1. Create a symlink in the `ci_scripts` directory to where our snapshots are stored.
1. Detect when running on Xcode Cloud in our snapshot tests.
1. Provide Swift Snapshot Testing with a file path to the `ci_scripts` directory when running on Xcode Cloud.

Let's walk through those steps in detail.

### Create a ci_scripts directory where Xcode Cloud expects it to be

Copied from [Apple's documentation](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-the-CI-scripts-directory):

To create the `ci_scripts` directory:

1. Open your project or workspace in Xcode and navigate to the Project navigator.
1. In the Project navigator, Control-click your project and choose New Group to create the group and its corresponding directory.
1. Name the new group ci_scripts.

### Create a symlink in the ci_scripts directory to where our snapshots are stored

> The way this symlink is created is specific to the directory structure. 
> Hopefully I'm providing enough detail here for you to make any adjustments you
> need for your project.

Here is the directory structure that I'm using:

```shell
SpeakList/
  .git/
  App/
    SpeakList.xcodeproj/
    ci_scripts
    ...
  Sources/
    ...
  Tests/
    SnapshotTests/
      SnapshotTests.swift
      __Snapshots__/
    ...
  ...
```

The root directory is called "SpeakList", the Xcode project is in a directory
called "App" which also contains the "ci_scripts" directory, and there are
"Sources" and "Tests" directories to follow the default directory structure that
Swift Package Manager expects. The "Tests" directory has a "SnapshotTests"
directory with the test file "SnapshotTests.swift" and the "`__Snapshots__`"
folder where Swift Snapshot Testing stores the snapshots.

We need a symlink from the `SpeakList/App/ci_scripts` directory to the
`SpeakList/Tests/SnapshotTests/__Snapshots__` directory which we can create by
running this command in the `ci_scripts` directory:

```shell
ln -s ../../Tests/SnapshotTests/__Snapshots__
```

> This setup assumes that you only have one target in which you are running
> snapshot tests and therefore only one `__Snapshots__` directory.

### Detect When Running on Xcode Cloud in our Snapshot Tests

This is the part that tripped me up the most while I was trying to make this 
work. There are different ways that you could achieve the same goal of 
determining that the tests are running on Xcode Cloud but I chose to use the
`CI` environment variable that Xcode Cloud injects.

#### Pipe the Environment Variable into the Test Plan

For our tests to get access to this environment variable we have to "pipe" the
variable through our Test Plan. I'd never done this before and Test Plans are a
newer Xcode feature so I found it difficult to find documentation on what is
needed. I eventually found [this documentation for Datadog](https://docs.datadoghq.com/continuous_integration/tests/swift/?tab=swiftpackagemanager#configuring-datadog)
with this nugget that set me right: 

> Quote: You **must** select your main target in Expand variables based on or Target for Variable Expansion if you are using test plans

To pipe the environment variable through we need to edit our TestPlan so it
looks like this:

![Screenshot of the TestPlan configuration. Values are set as described below.](testPlanConfiguration)

"Environment Variables" is set to `CI=$(CI)` and "Target for Variable Expansion"
is set to "SpeakList" which is the main app target.

#### Access the Environment Variable in Tests

Now that we've piped the variable through we use `ProcessInfo` to access the
variable in our tests. Here is what the single line of code looks like to return
a Boolean for whether we are in the CI environment (we know we want to test
for the value of `"TRUE"` based upon the [Xcode Cloud environment variable documentation](https://developer.apple.com/documentation/xcode/environment-variable-reference#Variables-that-are-always-available)):

```swift
ProcessInfo.processInfo.environment["CI"] == "TRUE"
```

I'll share how that fits in with the rest of our test code in a bit.

### Provide Swift Snapshot Testing with a File Path to the ci_scripts Directory when Running on Xcode Cloud

Swift Snapshot Testing uses the location of the file where the tests are being
run to determine where it creates and looks for snapshots. When running in Xcode
Cloud we need to provide a different file path to the `assertSnapshot` method so
Swift Snapshot Testing can find the snapshots in the location we symlinked them
in the second step.

First we need to create a `StaticString`:

```swift
let xcodeCloudPath: StaticString = "/Volumes/workspace/repository/ci_scripts/SnapshotTests.swift"
```

Then we need to choose to use that `StaticString` when running on CI:

```swift
let filePath: StaticString

if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
  filePath = xcodeCloudPath
} else {
  filePath = #file
}
```

And then we need to provide the correct file path to the `assertSnapshot` method:

```swift
assertSnapshot(
  matching: view,
  as: .image,
  file: filePath
)
```

After putting that all together our snapshot test could look like this:

```swift
class SnapshotTests: XCTestCase {
  let xcodeCloudPath: StaticString = "/Volumes/workspace/repository/ci_scripts/SnapshotTests.swift"

  func testTextExampleSnapshot() {
    let view = Text("Snapshot Test Example")
      .frame(width: 200, height: 200)

    let filePath: StaticString

    if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
      filePath = xcodeCloudPath
    } else {
      filePath = #file
    }

    assertSnapshot(
      matching: view,
      as: .image,
      file: filePath
    )
  }
}
```

## Creating Something Reusable

That code we just created gets the job done but that boilerplate code to
test for running on CI in every test would get annoying to write over and over.
It would be better to extract the common things we want to do for every snapshot
test to a separate method to remove that redundancy and have consistent
snapshot tests for all of our views.

I've created an extension on `XCTest` with a method that handles the check for
running on CI as well as:

* Checks that the device or simulator used for creating snapshots has a
consistent display scale and OS version
* Creates snapshots inside a view controller so we are capturing what the view
will look like on device
* Creates snapshots in all color schemes (Light Mode and Dark Mode)
* Creates snapshots in all Dynamic Type sizes
* Disables animations in the view to get more consistent snapshots

Here is that extension:

```swift
import SnapshotTesting
import SwiftUI
import XCTest

extension XCTest {
  // https://github.com/pointfreeco/swift-snapshot-testing/discussions/553#discussioncomment-3807207
  private static var xcodeCloudFilePath: StaticString {
    "/Volumes/workspace/repository/ci_scripts/SnapshotTests.swift"
  }
  private static var isCIEnvironment: Bool {
    ProcessInfo.processInfo.environment["CI"] == "TRUE"
  }

  /// Creates snapshots in a variety of different environments at the screen size of an iPhone 13 Pro (by default).
  /// This method must be called when running tests on a device or simulator with the proper display scale
  /// and OS version.
  ///
  /// Environments used for these snapshots:
  /// * Light Mode
  /// * Dark Mode
  /// * All Dynamic Type Sizes
  ///
  /// - Parameters:
  ///   - view: The SwiftUI `View` to snapshot.
  ///   - snapshotDeviceOSVersions: A dictionary of the OS versions used for snapshots. Defaults
  ///   to: ["iOS": 17.0, "macOS": 14.0, "tvOS": 17.0, "visionOS": 1.0, "watchOS": 10.0]. The test will fail
  ///   if snapshots are recorded with a different version.
  ///   - snapshotDeviceScale: The device scale used when recorded snapshots. Defaults to 3.0.
  ///   The test will fail if snapshots are recorded with a different scale.
  ///   - viewImageConfig: The `ViewImageConfig` for the snapshot. Defaults to `.iPhone13Pro`.
  ///   - xcodeCloudFilePath: A `StaticString` describing the path that will be used when
  ///   running these tests on Xcode Cloud. Defaults to `"/Volumes/workspace/repository/ci_scripts/SnapshotTests.swift"`. If your
  ///   tests are in a Swift file with a name other than "SnapshotTests.swift" you will need to provide this
  ///   same `StaticString` but with your test file's name in place of "SnapshotTests.swift".
  ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
  ///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
  ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
  func assertStandardSnapshots(
    view: some View,
    snapshotDeviceOSVersions: [String: Double] = [
      "iOS": 17.0,
      "macOS": 14.0,
      "tvOS": 17.0,
      "visionOS": 1.0,
      "watchOS": 10.0
    ],
    snapshotDeviceScale: CGFloat = 3,
    viewImageConfig: ViewImageConfig = .iPhone13Pro,
    xcodeCloudFilePath: StaticString = xcodeCloudFilePath,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
  ) {
    guard UIScreen.main.scale == snapshotDeviceScale else {
      XCTFail(
        "Running in simulator with @\(UIScreen.main.scale)x scale instead of the required @\(snapshotDeviceScale)x scale.",
        file: file,
        line: line
      )
      return
    }
    let snapshotDeviceOSVersion: String
    #if os(iOS)
    guard let version = snapshotDeviceOSVersions["iOS"] else {
      XCTFail(
        "iOS version not provided.",
        file: file,
        line: line
      )
      return
    }
    snapshotDeviceOSVersion = "\(version)"
    #elseif os(macOS)
    guard let version = snapshotDeviceOSVersions["macOS"] else {
      XCTFail(
        "macOS version not provided.",
        file: file,
        line: line
      )
      return
    }
    snapshotDeviceOSVersion = "\(version)"
    #elseif os(tvOS)
    guard let version = snapshotDeviceOSVersions["tvOS"] else {
      XCTFail(
        "tvOS version not provided.",
        file: file,
        line: line
      )
      return
    }
    snapshotDeviceOSVersion = "\(version)"
    #elseif os(visionOS)
    guard let version = snapshotDeviceOSVersions["visionOS"] else {
      XCTFail(
        "visionOS version not provided.",
        file: file,
        line: line
      )
      return
    }
    snapshotDeviceOSVersion = "\(version)"
    #elseif os(watchOS)
    guard let version = snapshotDeviceOSVersions["watchOS"] else {
      XCTFail(
        "watchOS version not provided.",
        file: file,
        line: line
      )
      return
    }
    snapshotDeviceOSVersion = "\(version)"
    #endif
    guard UIDevice.current.systemVersion == "\(snapshotDeviceOSVersion)" else {
      XCTFail(
        "Running with OS version \(UIDevice.current.systemVersion) instead of the required OS version \(snapshotDeviceOSVersion).",
        file: file,
        line: line
      )
      return
    }

    let filePath: StaticString

    if Self.isCIEnvironment {
      filePath = xcodeCloudFilePath
    } else {
      filePath = file
    }

    for colorScheme in ColorScheme.allCases {
      let viewController = UIHostingController(
        rootView: view
          .transaction {
            $0.animation = nil
          }
          .background(colorScheme == .light ? Color.white : Color.black)
          .environment(\.colorScheme, colorScheme)
      )
      viewController.view.backgroundColor = colorScheme == .light ? .white : .black

      assertSnapshot(
        matching: viewController,
        as: .image(on: viewImageConfig),
        named: "\(name) - Color Scheme: \(colorScheme)",
        file: filePath,
        testName: testName,
        line: line
      )
    }

    for size in DynamicTypeSize.allCases {
      let viewController = UIHostingController(
        rootView: view
          .transaction {
            $0.animation = nil
          }
          .environment(\.dynamicTypeSize, size)
      )

      assertSnapshot(
        matching: viewController,
        as: .image(on: viewImageConfig),
        named: "\(name) - Dynamic Type: \(size)",
        file: filePath,
        testName: testName,
        line: line
      )
    }
  }
}
```
