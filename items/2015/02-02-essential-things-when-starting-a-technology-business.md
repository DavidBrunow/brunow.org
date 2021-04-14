---
published: 2015-02-02T23:55:52-06:00
title: Essential Things When Starting a Technology Business
---
A year ago I was part of a company that had grown from 2 people, with me doing most of the programming work, to 9 people in the period of a month or two. The systems we had in place for communication (email) and project management (email and Excel) failed quickly in the new environment. I'm a systems and infrastructure kind of guy so I took the lead on figuring out what we needed and the best solutions for it.

In no particular order, here are the conclusions I came to along with some notes on different options for each.

## Issue Tracker
To save money we went with [Mantis](http://www.mantisbt.org), a free and open source issue tracking web application written in PHP. I did some tweaking to the CSS so it wasn't absolutely awful to look at and we came up with a pretty good workflow involving projects and versions. If I didn't want to pay for a system then I'd definitely use Mantis again.

Fortunately for very small teams, Fog Creek Software offers [FogBugz](http://www.fogcreek.com/fogbugz/) for free to teams of two people. FogBugz is great and I highly recommend it.

## Source Control
Being a .NET shop we debated between Team Foundation Server and Git for our source control system. I had never used either in a team environment but based upon my research I really liked the workflows available in Git that couldn't be done with Team Foundation.
We first tried hosting the Git repositories on our own server but maintaining that took too much of my time and performance was awful. After fighting with it for a few months we started paying for GitHub.

GitHub is probably the best option for a small technology company with more than two people. If you only have two people, FogBugz has source control built-in through Kiln.

## Chat
I want to keep as much as possible out of the email inbox. Email inboxes easily get overwhelming and are too private -- I embrace transparency and want everyone to know what is going on and group chat is a great way to do that.

I highly recommend [Slack](http://slack.com) and nothing else. As a bonus, Slack is very well designed and performs flawlessly in my experience. Using it will give your team something to aim for.

## Email
Since we had a large corporate client and needed Microsoft Office we went with Office 365. I was pleased with the service and the software. The only small complaint I have is that the administration screens are a bit wonky.
I've also heard good things about FastMail if you only need email.

Anything Google related is not on my approved list because I don't like their business model, although their applications are quite popular.

## Wiki
Some may debate me on the necessity of a wiki, but I couldn't go without one. This is the place you store everything that you will or may need to look back up again one day. I love them for documentation and training. We went with [DokuWiki](https://www.dokuwiki.org/dokuwiki) because it was free, open source, and had a single sign-on plugin for Mantis.

Fortunately for teams of two, FogBugz has a wiki built in for free.

## Web Server
A place to host your website and any applications you build for yourself. I get all my servers from [CH3 Data](https://www.ch3data.com) in Austin, Texas because they care about reducing their power consumption which is good for the environment.

We got a Windows server because we did .NET development. I'd always recommend a Linux server.

I'd love to hear what I missed on this list or better options for any of the components I chose -- what do you use and love?