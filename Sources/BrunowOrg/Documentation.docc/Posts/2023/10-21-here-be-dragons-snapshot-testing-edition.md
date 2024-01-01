# Here Be Dragons: iOS Snapshot Testing Edition

Stumbling over complexity and hiding it with opinions. 

@Metadata {
  @Available("Brunow", introduced: "2023.10.21")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "misrenderedSwiftUIList",
    alt: "Screenshot of a user interface which was not rendered properly in snapshot tests."
  )
}

## Backstory

> In case you are unfamiliar: [Here Be Dragons (HC SVNT DRACONES) on Wikipedia](https://en.wikipedia.org/wiki/Here_be_dragons)

As I mentioned [in my previous blog post](<doc:08-30-snapshot-testing-with-xcode-cloud>) 
I am working on a small side-project app that allows me to play with some tools
from the Apple software development ecosystem. In that blog post I talked about
the steps needed to get the Swift Snapshot Testing library working with Xcode
Cloud but that was only the beginning of my snapshot testing saga. It seemed
like every time I wanted to take a snapshot of a new view I bumped up against
another problem. In this post I'm going to talk through what I bumped up
against, the reasons why this very good library still has those rough bits, and
how I will improve the situation for myself and my team by making opinionated
choices.

> While I will discuss some pain points when using the [Point-Free Snapshot Testing library](https://github.com/pointfreeco/swift-snapshot-testing),
> I cannot emphasize enough how good I think the library is. Hopefully
> none of the things I say will lead anyone reading this to any other opinion.

## A Little Background on Snapshot Testing

Snapshot testing is a type of automated test where you provide an input to the
snapshot assertion method, that snapshot assertion method creates a value for
that input, and then checks to ensure that that value matches the previous 
 ["golden"](https://softwareengineering.stackexchange.com/a/358792) value for
that input. 

This blog post is about snapshot testing where the input is a view
and the value created by the snapshot assertion method is an image. If I provide
a view for my app I expect an image that looks just like a screenshot of my app.

## Some initial pain points

I'll start by talking through some of the painful things I've run into and hope
that they give a sense of the landscape that I'm dealing with when doing
something that sounds simple like "just add snapshot tests". All this pain
happened over a single week around a month ago.

### Bumping into macOS Sonoma

I published my blog post on using snapshot tests with Xcode Cloud and everything
was working great with tests passing both locally and remotely. Since I have 
been using snapshot tests for a while that was a bit surprising to me, but I'll
touch on why that is a bit later. Days or weeks went by, I'd made changes that I
no longer remembered (or maybe the world changed around me), and my snapshot
tests were no longer passing on Xcode Cloud. I was especially upset by this
because I'd recently shared that blog post about how to get things working and
felt guilty for spreading misinformation.

Once I got some time to look into the issue I realized that one of two things
had happened:

1. I had changed the Xcode Cloud environment to run on macOS Sonoma, or
1. The latest version of macOS Sonoma changed the behavior of the snapshots

Basically, the issue had to do with running my snapshot tests on macOS Sonoma on
Xcode Cloud (running on Sonoma locally to record the snapshots seems fine) which
had just made it to the release candidate stage. Changing the Xcode Cloud
environment back to macOS Ventura resolved the issue and I was able to move on
knowing that I had not completely misled people.

### Bumping into TabView

Someone in the Point-Free Slack mentioned that the snapshots they generated of
their tab bar did not look correct. I hadn't tried creating snapshots for the
tab bar in my app, so I hadn't run into the issue before, but I was quickly able
to reproduce. The snapshots looked like this (the unselected tab bar icons are
white which makes them very difficult to see):

![Screenshot of my app's miscolored tab bar. The tab bar icons are white on a light gray background which makes them difficult to see.](miscoloredTabBar)

I found a workaround &mdash; by adding this code before my `assertSnapshot`
calls the tab bar would render correctly:

```swift
UITabBar.appearance().unselectedItemTintColor = .systemGray
```

This feels a bit hacky to me but it worked.

### Bumping into List

The bumps are piling up but at least I can bandage them &mdash; I've found
sometimes hacky, sometimes regressive, workarounds. As long as Apple always
supports macOS Ventura then I don't need to worry about the issue with Sonoma,
right?

But throughout these fights I'd been ignoring a glaring issue with the snapshots
of the SwiftUI `List` in my app. Take a look at this monstrosity:

![Screenshot of a SwiftUI List in my app. Each row in the list has slightly rounded corners that make it look goofy.](misrenderedSwiftUIList)

OK maybe calling it a monstrosity is harsh. And the contrast between the light
gray and the white is not great so the issue may be difficult to see, but each
row in the `List` has rounded corners instead of only the top leading, top
trailing on the first item and bottom leading and bottom trailing on the last
item having rounded corners. What is going on there?

I tried a lot of different things to try to get this to render properly. 

I thought that perhaps it was a timing issue and the UI needed more time to
layout so I increased the wait time before capturing the snapshot. Nope.

I thought that maybe the wait time wasn't enough and that I needed to increase
the speed of the animations so I tried setting the `window.layer.speed = 100`.
Nope.

I found [this GitHub issue](https://github.com/pointfreeco/swift-snapshot-testing/issues/667)
on the snapshot testing library and I was first encouraged by 
[a potential solution](https://github.com/pointfreeco/swift-snapshot-testing/issues/667#issuecomment-1462270406)
and then disappointed when [someone commented that it did not work for them](https://github.com/pointfreeco/swift-snapshot-testing/issues/667#issuecomment-1463810906).

I was out of options. I tried it anyway. And it worked! 🎉

## Why Did I Keep Bumping into Things?

I've said before, and I'll say it again now: Point-Free's snapshot testing
library is great. So why am I running into so many issues? Why is this so
painful? I think those three pain points are instructive so let's talk through
the root causes of each of those.

### macOS Sonoma Rendering Differently on Xcode Cloud's Intel machines

> Note from the future: Since writing this blog post I've solved the problem
> with simulators on Sonoma and wrote about it in [a new blog post about controlling simulators on Xcode Cloud](<doc:11-30-follow-up-snapshot-testing-xcode-cloud-sonoma>).

~~I have absolutely no insight into why I'm seeing the behavior I'm seeing on
Xcode Cloud but I can make some guesses based upon what I do know. I know that
Apple is going through a processor transition where their CPUs have changed from
being manufactured by Intel to being manufactured by Apple. Along with this CPU
change comes GPU changes as well since Apple is creating their own GPUs.~~

~~Again, I don't know the details, but this foundational change is somehow leaking
into our snapshot testing when running macOS Sonoma. I think the only people 
that can fix this work at Apple so I filed FB_INSERT_FEEDBACK_HERE.~~

That struck out code was my first attempt at explaining the behavior just a
week or two ago while first drafting this post --- I'm sharing it here to give
a little insight into the circuitous path I took to get to an understanding of
these issues. Since then 
[I've figured out that  having certain locales setup as preferred languages in a simulator causes different rendering](#Using-strong-opinions-in-higher-level-libraries).

So could that be the reason why the rendering is different on macOS Sonoma? 
Let's cook up a test failure to see by adding this to our snapshotting code:

```swift
if Locale.preferredLanguages.contains(where: {
  $0.contains("ar") || $0.contains("hy")
}) {
  XCTFail(
    """
    Running on a simulator with Arabic or Armenian in its preferred
    languages which will cause the snapshots to be rendered differently.
    Please remove Arabic and/or Armenian from the simulator's preferred
    languages (Settings > General > Language & Region).
    """,
    file: file,
    line: line
  )
  return
}
```

Then we'll run the tests again on Xcode Cloud on a macOS Sonoma machine:

![Screenshot showing a test failure about the simulator having Arabic or Armenian in its preferred languages.](arabicOrArmenianTestFailure)

Well there we go. That same test passes on macOS Ventura. But that leads me to
wonder "how many different preferred languages are setup in the Sonoma 
simulator?"

![Screenshot showing that the simulator running on macOS Sonoma has 34 preferred languages.](numberOfPreferredLanguagesXcodeCloudSonoma)

OK 34 preferred languages, cool. Running this same test on macOS Ventura returns
1 preferred language. Now I'm a bit more curious -- which languages did they
choose? Here they are as of October 2023 (notice that Arabic is in this list --
I talk about why that is noteworthy in a later section that I linked above):

| | | | | | | |
|-|-|-|-|-|-|-|
|en|ja|sv|el|pt-BR|th|id|
|fr|es|ru|he|pt-PT|cs|ms|
|de|it|pl|ro|da|hu|vi|
|zh-Hans|nl|tr|sk|fi|ca|es-419|
|zh-Hant|ko|ar|uk|nb|hr|

OK so it is great that the simulators include languages other than English --
app development is not something that only happens in the English speaking
world -- but this does add more complexity to our snapshot testing story. I've
created [FB13288344](https://github.com/feedback-assistant/reports/issues/431) to ask for control over
the preferred languages in Xcode Cloud. Until we get that we may have to make
our local simulators mirror what is setup on Xcode Cloud.

### TabView misrendering

Let's take a look at
[the snapshot testing documentation around `UIViewController` snapshot strategies](https://github.com/pointfreeco/swift-snapshot-testing/blob/main/Sources/SnapshotTesting/Snapshotting/UIViewController.swift#L48):

```swift
///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render
///     `UIAppearance` and `UIVisualEffect`s. This option requires a host application for your
///     tests and will _not_ work for framework test targets.
```

This is the documentation for a strategy that we have not been using and
therefore we are not getting this behavior. That part about the `UIAppearance`
might be the answer to our question about why the tab bar is not being rendered
correctly. Perhaps those unselected tab colors are being set on the
`UIAppearance`.

> Aside: Surprisingly the Snapshot Testing libraries documentation around the
> differences between the view controller snapshotting strategies is lacking a
> larger discussion about when to choose which. I've opened [a pull request with
> suggestions for that](https://github.com/pointfreeco/swift-snapshot-testing/pull/796).

So I have a theory about what is going on but I think we need to dig in on what
this `drawHierarchyInKeyWindow` parameter does. Let's do that while looking at
the rendering issues with `List`.

### List misrendering

To try to understand what might be going on with the `List` I think we need
to talk through how the snapshot images are created. To do so we can dig through
the code (yay open source!) and find [this conditional in `View.swift`](https://github.com/pointfreeco/swift-snapshot-testing/blob/main/Sources/SnapshotTesting/Common/View.swift#L990C46-L990C46):

```swift
...
  if drawHierarchyInKeyWindow {
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
  } else {
    view.layer.render(in: ctx.cgContext)
  }
...
```

> Aside: It would be nice if this code block had line numbers so I could refer to them
> to improve communication. I created an 
> [issue on the Swift-DocC project](https://github.com/apple/swift-docc/issues/737) 
> for that.

Depending on the value of `drawHierarchyInKeyWindow` either the 
[`drawHierarchy(in:afterScreenUpdates:)`](https://developer.apple.com/documentation/uikit/uiview/1622589-drawhierarchy)
or the [`render(in:)`](https://developer.apple.com/documentation/quartzcore/calayer/1410909-render) method is called.
Both of these are methods provided by Apple that have been in the SDK for a long
time. We can look up their documentation (linked in the method names) but what
we find isn't super useful, at least not to me. Here is a snippet from the 
`drawHierarchy` documentation:

> Quote: Renders a snapshot of the complete view hierarchy as visible onscreen
> into the current context.

OK that sounds great, that's exactly what we want. So why do we need the
`render` method? Maybe its documentation gives us a clue:

> Quote: Renders the layer and its sublayers into the specified context.

OK so the difference is that `render` only renders a layer and `drawHierarchy`
renders the complete view hierarchy. But to do that you need a complete view
hierarchy which we see on [line 940 of View.swift](https://github.com/pointfreeco/swift-snapshot-testing/blob/main/Sources/SnapshotTesting/Common/View.swift#L940C36-L940C36):

```swift
...
if drawHierarchyInKeyWindow {
  guard let keyWindow = getKeyWindow() else {
    fatalError("'drawHierarchyInKeyWindow' requires tests to be run in a host application")
  }
...
```

To draw the complete view hierarchy in the key window we need something called a
key window and we can only get that with something called a host application.

> Technically we only need to be running in a host application to be able to
> draw the complete view hierarchy using `drawHierarchy` but the snapshot
> testing library does not support using that method without also using the key
> window.

The [key window](https://developer.apple.com/documentation/uikit/uiapplication/1622924-keywindow)
is the application window with which the user is interacting. That property I
linked to on `UIApplication` is deprecated since Apple no longer wants us to
think about an application having a single window and instead to think in terms
of a multi-window world, but that deprecation doesn't matter for our purposes
since the concept of a key window is still valid. 

A host application is an application within which we can run our tests. This 
gets a bit complex in the current Apple ecosystem when you choose to use Swift
Package Manager to modularize your dependencies like I did in the last blog 
post. Swift packages have no concept of a host application and therefore tests
in Swift packages cannot be run inside a host application. Since I'm building an
iOS app I have a host application at my disposal which I can use and I'll talk
about how to do that a bit later. For now, let's get back to these two different
methods for creating snapshots of our user interface.

> Aside: The host application story for Swift packages could be improved and I'm
> not the first to notice that --- 
> [this thread on the Swift forums](https://forums.swift.org/t/host-application-for-spm-tests/24363)
> was started in 2019. While I like to take action to try to improve the little
> parts of the world that I can, I'm not sure what action to take here.

What we've seen so far is two conditionals with two branches each and therefore
4 different ways that snapshots could theoretically be captured (based upon the
conditional's logic only 3 of these possibilities can actually be used in the
snapshot testing library but I think it is useful to think through them all):

Method|Window|Configurable without code changes
-|-|-
`drawHierarchy`|`UIWindow()`|No
`drawHierarchy`|Key window|Yes
`render`|`UIWindow()`|Yes
`render`|Key window|Yes

Then my followup question to that table is "do any of these configurations fix
the bad behavior I'm seeing with my `List`?" (I had to modify the snapshot
testing code to test the first "impossible" configuration):

Method|Window|Fixes `List`
-|-|-
`drawHierarchy`|`UIWindow()`|Yes*
`drawHierarchy`|Key window|Yes
`render`|`UIWindow()`|No
`render`|Key window|No

> I added the asterisk on the first line because while the `List`
> was rendered properly the tab bar's tabs were not properly positioned as you
> can see in this diff where the tab bar is positioned too low in the view: 
> ![Shows difference between the snapshot taken with the key window and the snapshot taken with a UIWindow. The snapshot taken with the UIWindow looks the same other than the tab bar is lower on the screen.](diffBetweenDrawHierarchyKeyWindowUIWindow)

So the main difference in our `List` rendering is the method being called. 
We've already looked at the Apple documentation and I didn't see any clues there
as to the underlying reason behind the differences in behavior --- that
documentation did not even mention the difference in `UIAppearance` mentioned 
by the snapshot testing documentation.

After some internet searching I found
[this interesting StackOverflow post](https://stackoverflow.com/a/25704861) that
talks about the implementation differences between those two methods:

> Quote about drawHierarchy method: The method `drawViewHierarchyInRect:afterScreenUpdates:` performs its 
> operations on the GPU as much as possible, and much of this work will probably
> happen outside of your app’s address space in another process. Passing YES as 
> the afterScreenUpdates: parameter to `drawViewHierarchyInRect:afterScreenUpdates:`
> will cause a Core Animation to flush all of its buffers in your task and in
> the rendering task. As you may imagine, there’s a lot of other internal stuff
> that goes on in these cases too.

> Quote about render method: In comparison, the method `renderInContext:` performs
> its operations inside of your app’s address space and does not use the GPU
> based process for performing the work...This route is not as efficient as it
> does not use the GPU based task. Also, it is not as accurate for screen
> captures as it may exclude blurs and other Core Animation features that are
> managed by the GPU task.

So the `render(in:)` method is both less efficient and creates less accurate
results!?! 😲 Why would we want to consider it as an option?

Well, as we noted before, the `drawHierarchy` method only works when the tests
are hosted in an application. And as I mentioned before, at this point in time
there is no way for a Swift package's tests to be hosted in an application
without a separate Xcode project. The `render(in:)` method is the only choice to
use image based snapshot tests in a Swift package. Running tests inside of a
host application is also much slower than running them standalone and folks
might want to make that tradeoff of accuracy for test speed.

> Aside: I've created a [discussion](https://github.com/pointfreeco/swift-snapshot-testing/discussions/797) around whether
> `drawViewHierarchy` should be the default codepath if the tests are being run
> inside a host application.

I think it is also worth noting that neither of these API were created with the
intent of supporting snapshot testing. Without intentional support of that use
case we can't expect the Apple folks working on those API and supporting them
across OS versions, processor architectures, and everything else changing to
ensure that they work for this purpose. That being said, I believe that Apple
should consider snapshot testing to be a first-class use case for these API (or
to provide separate API for that purpose) and therefore I've filed
[FB13292311](https://github.com/feedback-assistant/reports/issues/430) for that.

## Rough edges in low-level, general libraries

As I've mentioned before I think the Swift Snapshot Testing library is very
good. But I've also typed a fair number of words and spent a large amount of
time working around these rough edges on the API. How can I think it is a good
library and think it has rough edges? Do I have a poor sense of quality?

I may have a poor sense of quality elsewhere (I did once watch an entire movie
about a homicidal tire named Robert) but I don't think that is the case here.
These rough edges come from two things: 1) the library authors are building upon
lower level things that have rough edges, and 2) the library is low-level and
general purpose.

The only way to cover over rough edges in the things that you are building on
top of is to make decisions for the end users of the library. But making those
decisions for the end users takes away the end users' power and flexibility. 
Like most engineering, this is a trade-off and I think the authors of this
library made the right choice. My only minor gripe would be that, as I mentioned
before, the documentation around these trade-offs is lacking and therefore I, as
an end user of this library, am not able to make as informed of a decision as I
would like.

## Using strong opinions in higher level libraries

If I know my end users (or if I'm my own end user) then I can make informed
decisions for them which will cover over most of the rough edges from the lower
levels without taking away the power they need. There will be exceptions, like
the rendering differences in macOS Sonoma on Xcode Cloud, but the experience can
be much simpler. The trade-off here is that I need to ensure the environment the
end user is working in matches the expectations of my strong opinions --- they
need to have their tests setup the proper way and have them hosted inside an
application.

But even my strongest opinions can't cover over all the issues and it is in
those cases that we need to provide other ergonomics. For example, if you
capture your golden snapshot on a simulator that renders at a display scale of
`@3x` and then run a follow-up test on a simulator that renders at a display
scale of `@2x` the test will fail. Similar failures will happen with different
iOS versions due to minor differences in text layout, and with different
simulators based upon the size of their status bar. In those cases we can find
way to gently nudge the user onto the right path.

Even this approach has some flaws. After I finished that paragraph I went to
test out a change to see if I could make my library more ergonomic when a
simulator was set to a different language and found that all my tests were
failing. Apparently if Arabic is in the list of languages --- even if it isn't
the default language --- the simulator will render differently. Now that I've
figured that out I can add a check for that to the library but I can never be
sure that I've covered every rough edge.

> I went down a long path to try to create an example project that would show
> the issue of the simulator rendering differently when Arabic is in the list of
> preferred languages. Some ways down that path I asked myself "does this
> happen on device as well?" and, _turns out_, the answer is yes. I was going to
> file a Feedback about this but I think the behavior, while unexpected to me,
> is correct. If an app knows that a user prefers Arabic then they might need to
> show Arabic text in their app and therefore they need the SF Arabic font and
> the extra vertical height it has.
>
> This led me to think "which other languages might behave similarly?" I have
> not tested every language to find out but I did identify another language that
> changes the rendering like Arabic does. I started on this 
> [Apple website about their fonts](https://developer.apple.com/fonts/) which
> describes a category of SF Script Extensions into which SF Arabic falls. I
> tested the other script extensions and found that Armenian behaves similarly
> to Arabic.

## My opinions

* All snapshot tests should be hosted.
* All snapshot tests should use `drawHierarchyInKeyWindow = true`.
* Snapshots should usually be generated on the latest device/OS combination.
* Snapshots should fail early, with a helpful failure method, when the snapshot
environment is different than we expect.
* Every view should be snapshotted in the same set of standard environments.
* Users should have the option to create a "throwaway" snapshot for situations
where dependencies or caches need to be setup to capture the right data.
* Snapshots should be rendered on a small device size to be able to find
layout issues at that size.

Next let's talk about how to setup the environment for these opinions and the
helper code I've created to work with them.

### Setting up hosted tests

Hosted tests need to live inside an app's XCProject or XCWorkspace and need
their own target. Here are the steps to set up the hosted tests:

1. Create a "Unit Testing Bundle" target. This could be named "SnapshotTests" if
you want to limit the scope of the kinds of tests that will be in this target or
you could name it "Hosted Tests" since there might be other tests you want to
write in the future that won't be snapshot tests but will need to be hosted. One
example would be live implementation tests for code that interacts with the
keychain. Make sure that your app is selected as the "Target to be Tested"
because this is what makes the tests hosted.
1. If you have existing snapshot tests in your Swift package, copy them into the
folder created for the new test target. If you don't have existing snapshot
tests then create the tests in that folder.
1. Add the Swift Snapshot Testing dependency to the app project. Ensure that it
is only added to the test target and not to the app target.
1. If using TCA, ensure that the app's logic is not being run at the same time
as the snapshot tests by wrapping the code that creates the store with 
`if _XCIsTesting == false { }`.
1. Add the tests in the test target to the test plan.
1. If you're using Xcode Cloud for CI, update the 
[symlink in the `ci_scripts` folder](<doc:08-30-snapshot-testing-with-xcode-cloud#Create-a-symlink-in-the-ci_scripts-directory-to-where-our-snapshots-are-stored>) to point to the new location for
snapshots.

Now that we have setup hosted tests we have no excuse for not using
accessibility snapshot tests. Unfortunately adding them is a little more
complicated than simply importing the 
[library](https://github.com/cashapp/AccessibilitySnapshot) because nothing in
technology is easy.

### While we're at it, let's setup accessibility snapshot tests

Before we get into setting up the accessibility snapshot tests let me give you a
quick sales pitch for them. Accessibility snapshot tests give anyone who uses
them a superpower. That superpower is to be able to look at a user interface and
know how a VoiceOver user would experience that user interface. Here's an
example:

![Accessiblity snapshot showing a snapshot of the user interface on the left. The snapshot of the user interface has colored rectangles over different elements which match up to the VoiceOver text that will be spoken for that element on the right.](accessibilitySnapshotTestExample)

This snapshot isn't perfect -- the order of the items in the navigation bar is
incorrect, they should be announced before the list rather than after (I created 
[an issue on the Accessibility Snapshot Testing library](https://github.com/cashapp/AccessibilitySnapshot/issues/168) for
this). But even with that flaw this is fantastic -- I can easily see that the
order of the elements inside each row doesn't make sense. The name and quantity
should be grouped together because that is related information that shouldn't be
interrupted by the edit button. The alternative to these accessibility snapshot
tests is either firing up Accessibility Inspector or building to device with
VoiceOver on and manually stepping through each element. And as a reviewer on a
pull request who probably doesn't have time to do that for every review this
tool is fantastic.

Anyhow, I hope I've convinced you to at least try the accessibility snapshot
tests and we can move on to adding them to our hosted tests.

Our first step is to add the Accessibility Snapshot Testing dependency to our
app project, and specifically the hosted tests target (just like for the
snapshot testing dependency). But unfortunately the current version of the
Accessibility Snapshot Testing library does not support precision or perceptual
precision which are both things we need since we are working across Apple
Silicon and Intel machines and each of those machines renders things just
differently enough to not completely match snapshots from the other processor
type (not needing to set these precision parameters in my first blog post was
the surprising thing I alluded to near the beginning of this post). Those things
cannot easily be added to the library because:

1. Accessibility Snapshot Testing supports CocoaPods, and
1. Swift Snapshot Testing dropped support for CocoaPods at the same time it
added perceptual precision

To work around this I've [created a shim](https://gist.github.com/DavidBrunow/9aade5980649c660d73795d7c9b5b056) inspired by 
[this pull request](https://github.com/cashapp/AccessibilitySnapshot/pull/143).

This allows us to set the precision and perceptual precision on our
accessibility snapshots. Next I'll share the code that implements my opinions
and ties everything together.

### My opinionated helper code

This mostly builds upon the 
[helper code I shared in my snapshot tests on Xcode Cloud post](<doc:08-30-snapshot-testing-with-xcode-cloud#Creating-Something-Reusable>)
but adds "throwaway" and accessiblity snapshots and provides values for
precision and perceptual precision that work consistently for me. This helper
has strong opinions and does not provide the user with a lot of flexibility --- 
and where there is flexibility the API provides a default value so that most of
the time users would not have to think about those options. Hopefully making
these decisions for the user provides a simpler user experience that "just
works".

Here is a [gist with my helper code](https://gist.github.com/DavidBrunow/abb67bb0dda59d9524ae9868c926e810).
Note that some of the decisions I've made may not work for you. For example, 
I've added a check to make sure that the first preferred language on the
simulator running the tests is English (US). This is because I am an American
and the primary language I use is American English and this ensures that I don't
accidentally get to a place where all my tests are failing with an extra "u" in
the word "color" if I've set my simulator's primary language to English (UK).
The tests will still fail with this check but they will fail with a useful error
message. You may want to change that check to test for your preferred language.

This helper uses another [helper extension on `UIDevice`](https://gist.github.com/DavidBrunow/c7fa841ecd61526a660367c32a093a0c) which I pulled from
[Stack Overflow](https://stackoverflow.com/a/26962452) to be able to check
whether the right simulator is being used for the snapshots.

These two helpers and the shim I created for accessibility snapshot testing all
need to be copied into your hosted tests target.

Using these helpers, this is what the callsite for running the standard tests
would look like:

```swift
...
  assertStandardSnapshots(
    content: Text("I am going to be snapshot!"),
    named: "Sample Text"
  )
...
```
