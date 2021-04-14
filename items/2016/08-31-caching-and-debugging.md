---
published: 2016-08-31T00:05:17-05:00
title: Caching and Debugging
---
Tonight I fought with an issue for hours that should have taken me minutes. I went into the situation with my normal debugging strategy which involves quickly making changes, seeing results, and then repeating until I'd found the problem.

But tonight I was dealing with a different kind of situation although I didn't know it at first. I was dealing with caching, which meant that changes I made didn't show up immediately. When caching, the server holds on to certain information for a set period of time for the sake of efficiency. It is much easier to hold onto a webpage for a few seconds and then show it again rather than rebuilding the entire page.

Like I said I didn't know I was dealing with caching at first and my strategy wasn't working at all. I made a change, checked for results and nothing happened. That went on for longer than I'd have liked it to but eventually I caught on. Troubleshooting with caching requires patience and attention. With normal debugging you can usually move quickly enough to keep your attention engaged naturally. But with caching you have to remember what you changed last for seconds or minutes. You have to pay attention to whether things have changed in more subtle ways.