# Retiring My First iOS App
date: 2016-07-02T20:43:40-05:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
Five or so years ago I wanted to solve a problem I had &mdash; I wanted to be able to wake up to music from my playlists on the now-shutdown music streaming service Rdio. I built that app and called it Wake Up, Powered by Rdio. A very cool and very talented designer, [Jenni Leder](http://thoughtbrain.com), like and used it and offered her help to make it look beautiful. After implementing her redesign I built functionality to play playlists from the iTunes music on the phone itself instead of from Rdio. Due to Rdio's licensing agreement I could never charge for or put advertisements in the Wake Up, Powered by Rdio app but I could charge for the new app, called Wake Up to Music.

Wake Up to Music has never sold well. Jenni and I split the revenue from it and that works out to about a nice cup of coffee every three months. I attribute the slow sales to two factors:

1) No marketing effort on my part  
2) It isn't a very good app

I could solve #1 with some time and effort but I don't think I can solve #2 which is the reason I'm writing this now. I've had a few bugs reported on the app and I need to decide whether they're worth fixing or if I just need to let go of it. I really want this app to exist in the world but I think my stubbornness about it is causing more harm than good.

I've [written before about the app's fundamental flaw](https://brunow.org/2013/05/01/minimal-to-a-fault/) due to the restrictions in iOS that mean that I can't build the functionality I want in the way that I want to. I want to be able to allow the user to setup alarms at their leisure and have those alarms play music from their chosen playlist without any additional effort on their part. But iOS doesn't allow an app to start playing music whenever the app wants to &mdash; even if that app were instructed to do so by the phone's owner. Therefore I've had to compromise the app by forcing the user to open it before she goes to bed and leaving it open all night.

This issue of forcing the app to be open all night isn't the only crappy part of the experience and leads to other crappy side effects. Take for example the situation where the user gets a text after they've set their alarm. The alert won't show up on the lock screen because the app is open. And if the user notices and decides to respond to the text then she also needs to remember to open the app again afterwards. Plus, since the phone is unlocked all night it has to be plugged in which isn't very energy efficient. Plus plus, the phone being unlocked means that nightly backups might not get done. Plus plus plus, leaving the phone unlocked is a security risk because you are unconscious while anyone with access to your bedroom can get to all your private data on your phone.

As I said before I really want this app to exist in the world and despite these flaws I still want to use it every night. But I'm the guy who made it and I know every one of its flaws and how to work around each of them. Part of me is saying to myself "if I could only educate the users somehow!" I could add informational videos to the website and messages in the app about how to make it work optimally. I could add notifications to the user when they haven't re-set the alarm properly after replying to a text or other notification. But the app would still be flawed. No matter how stubborn I am about it the app won't be what I want it to be. It won't be built to my quality standards and I feel like it reflects poorly upon me.

So I'm probably going to pull the app from the App Store soon but I wanted to post this and give anyone who care an opportunity to say "no, don't do that!" Or "actually David you can get around your fundamental problem by doing ______" or "it is about time I can't believe you thought it was a good idea in the first place."

Do you have any thoughts? Let me know [on Twitter](https://twitter.com/davidbrunow) or in the comments below.
