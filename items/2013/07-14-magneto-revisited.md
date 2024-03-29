---
published: 2013-07-14T08:55:17-05:00
title: Magneto Revisited
---
I recently created my second site with Magneto, so I'm going to share my experience in doing so.

Background
----------
I have had a [website for my daughter][linkEmmaCan] hosted on Squarespace for a little over a year. The initial concept for the site was a sort of picture based storybook, something that I could read to my daughter as a bedtime story perhaps. None of the templates on Squarespace did exactly what I wanted, so I got a close approximation of what I wanted by futzing around with javascript and CSS every time that I made a post.

All of that futzing meant that I only made about 3 posts, all very soon after I created the site. I attribute that lack of posting to two factors (and I like to believe that it isn't because I'm a bad father):

1. The time it took to make a post -- to make the Squarespace site do what I wanted it to do, I had to spend about 20 to 30 minutes for each post. That was mostly because I would have to look at the past posts to re-learn what I had hacked together the previous time.
2. Having to log in to Squarespace -- I've found that having to log in to a service is a large enough hurdle to discourage me from using it. Any friction in the form of discouragement is a factor that will undermine my intentions and that I want to eliminate.

So I decided to abandon Squarespace and create another Magneto site.

Change of Plans
------------------
As I said earlier, I had an idea in my head of creating a website that was sort of like a children's bedtime story book, to which I would add new information about my daughter as she grew up and could do more things. But I ran into problems with this concept. Where would a new user start in reading the story? If I put them at the beginning of the book then they would get the full effect of the story. However, my friends and family that checked back often would have to jump through hurdles to get to the new stuff. Additionally, in a children's book there is generally one picture and caption per page. Having the same effect on the web would require a lot of clicking and waiting[^1], delivering a poor overall user experience.

So I abandoned the original idea and one of my primary reasons for leaving Squarespace[^2]. The new concept reminds me of what you would see on many Tumblr sites, pictures or videos with some comments. 

New Implementation
------------------
Setting up Magneto was very easy to do. I simply followed [my instructions][linkMagnetoInstructions] (having to fix a couple of typos along the way) and I had the basic site up in a few minutes. It is so much easier the second time around.

Despite changing my overall concept of the site, I still want to tell a story through the use of pictures and videos. In order to do that, I had to make some modifications to the stock Magneto setup.

First, I added some hacky javascript to the article template so that my pictures are in a separate div from the caption text. You can see that javascript in [post_article.erb on GitHub][linkArticleGithub]. This allows me to show the caption text on top of the image when it is moused over, and let's the images speak the rest of the time.

Next, I created an [HTML5 plugin][linkHTML5Github] that I use instead of Don's video plugin. As I learned after diving into this, HTML5 video is a bit of a pain in its current form, which I attribute to Firefox's insistence on not supporting the H.264 format. The plugin that I created does not account for this issue and therefore the videos do not show up in Firefox (although I added more hacky javascript to allow them to be downloaded). Not supporting Firefox has given [my father a reason to troll me][linkTwitterTroll], but I had to make a decision based upon my particular constraints, and one of those constraints is that I would like to be able to make the posts completely from the file system on my iOS devices. From my research, it isn't super straightforward to export Ogg Vorbis from the iPhone and even if I did that, I would be using twice as much space to store each video, which is just a waste. I also want to have full control over my videos, and I don't want to have to log into yet another web service. So for now, HTML5 with no Firefox support is the way I'm going.

Now a short bit about my experience serving images and videos. I have no prior experience in this area (my current professional work involves sites on an intranet that have little to no media assets) so I was experimenting with serving these assets straight from my server (which is the lowest tier virtual private server at [Midas Green Tech][linkMidasGreenTech]). With this strategy, my server would become unresponsive shortly after uploading updates to the site. I believe that this is because the server was caching those assets in memory, but I am not completely sure. I next experimented with a CDN, [Cloudflare][linkCloudflare] to be exact, and the server's unused memory went up dramatically and load times shortened dramatically. In other words, as convention would tell you, use a CDN.

The last thing that I modified was Don's timeago.coffee. I wanted the time stamps on my daughter's site to display my daughter's age at the time of the posting, so I created [timesince.coffee][linkTimesinceGithub]. You can provide the script a starting date and it will display how long after the date that that post occurred, with accuracy to a month.

Conclusion
----------
I am quite pleased with my switch to Magneto for my daughter's site. I have already posted more times than I did on the previous platform, and more importantly I don't get that feeling of dread that I usually do when I have to put in a password and navigate a site that I'm not used to navigating. I can almost do everything on my iPhone.

Would I recommend this setup to someone who is not technically minded? Definitely not. But if you are already managing a Linux server and want to share some pictures and memories with family and friends, or just want to have a memory for yourself, I think this is a great way to go. I might just be putting together another soon, and I will definitely be iterating upon my daughter's site in order to get it closer to my original concept.

You can follow me on Twitter [@davidbrunow][linkTwitter] where I will post links to any further blog posts about my experience with Magneto. And as a reminder, Magneto was created and open sourced by [@donmelton][linkDonMeltonTwitter].

[linkEmmaCan]: <http://EmmaCan.com>
[linkMagnetoInstructions]: <http://brunow.org/2013/03/27/magneto/>
[linkTwitterTroll]: <https://twitter.com/paraboloo/status/355400925713661952>
[linkCloudflare]: <https://www.cloudflare.com>
[linkMidasGreenTech]: <http://www.midasgreentech.com>
[linkHTML5Github]: <https://github.com/DavidBrunow/EmmaCan.com/blob/master/plugins/html5video.rb>
[linkArticleGithub]: <https://github.com/DavidBrunow/EmmaCan.com/blob/master/templates/post_article.erb>
[linkTimesinceGithub]: <https://github.com/DavidBrunow/EmmaCan.com/blob/master/items/js/timesince.coffee>
[linkTwitter]: <https://www.twitter.com/davidbrunow>
[linkDonMeltonTwitter]: <https://www.twitter.com/donmelton>

[^1]: I could make the waiting after clicking much shorter by fully loading all of the content at the beginning, and then using JavaScript to hide and show different "pages", but that would add more complexity to the site and make the template system generated by Magneto more difficult to use. Scrolling is very natural on the web, and probably the best way to do it.

[^2]: I do not regret my decision to stop using Squarespace, because of the following benefits of self hosting: 1) I have the content on my local machine and can use it any way that I like, 2) I don't have to log in, and 3) I can run my daughter's site on the same server that I run my own which saves me money.
