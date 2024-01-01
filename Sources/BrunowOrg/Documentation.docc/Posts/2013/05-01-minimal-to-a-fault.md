# Minimal to a Fault
date: 2013-05-01T08:23:01-05:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
Jenni and I intentionally [shipped an app][linkWakeUp] with a fatal flaw.

No, I don't mean the inability to change am/pm manually.

iOS, the operating system that runs on iPhones and iPads and iPod Touches, will not allow our app to do what it needs to do if it isn't running. That means we can't let the phone go to sleep and then have the app automatically open when it is time for the alarm to go off. That means that you have to open the app to set the alarm every night (or morning) before you fall asleep.

I knew about this fatal flaw when I started development on this app a little more than a year ago.[^1] I did research into different hacks that could possibly be used to allow the app to function in the background. At one point, I had decided not to make it at all since I couldn't make it work perfectly. That's what Apple does, right? They wait for the technology to mature before creating something half-baked? Well, I really wanted it to exist, so I built it anyway.

Fully knowing the burden of the flaw[^2], I made choices to allow setting your alarm every night to be as simple as possible. I added the ability for the alarm to start automatically at launch, so you only have to tap the icon to set the alarm. I designed the time input so that you can directly choose the numbers for the time you want to wake up, instead of scrolling back and forth in a picker like in a typical alarm app. And you don't have to choose am or pm, because the app picks the next occurrence within 12 hours. With this design, choosing 6:30 am takes 3 taps.

I've used this app almost every night for the past year. I am constantly thinking of things that would make my process of going to bed and waking up better and adding those ideas to the app. I hope they make your nights and mornings a little better too.

I hope you enjoy our imperfect app.


[linkWakeUp]: <http://wakeup.brunow.org>
[^1]: I've used a handful of different iPhone alarm clocks over the years, but I never stuck with them because of the friction involved with setting the alarm every night.
[^2]: I stopped using this feature after Jenni's beautiful redesign of the app. Now I actually want to experience the UI, rather than skip it.
