# Magneto
date: 2013-03-27T16:50:43-05:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}

As I state on my 'about' page, I am using a static blogging engine created and open sourced by [Don Melton][linkDonMelton] to create this site. I'll to talk through why I chose Magneto, the current limitations of my setup, and walk through simple tutorial for other ruby amateurs that may want to set up their own Magneto site.

The main reason that I want to use a static blogging engine is that I want to have complete control over my content. With Magneto, every part of my website is generated on my local computer. If the company that I rent a server from goes belly up, or the hardware server on which I have one small, virtualized chunk gets seized by the government, I could be back up and running on a new server with a different company before the DNS records could change. 

Since I have complete control over the content, that also means that I can change the CSS and JavaScript directly. When using a drag and drop type tool that someone else created, I feel like I have to think through someone else's mind. I don't know their mental model for the task I am doing, so I have to figure it out before actually getting anything done. With Magneto, I just have to be able to read source code and think like me, and I've gotten good at the latter. 

So why Magneto in particular? It is written in ruby and I was exposed to it through Don's blog at the right time. If I had wanted to learn php, I would have started using Marco Arment's [Second Crack][linkSecondCrack] long ago.

[linkDonMelton]: <http://donmelton.com>
[linkSecondCrack]: <http://www.marco.org/secondcrack>

##Limitations
Currently, I have run into only one significant limitation with Magneto. I am certain that I can build a workaround, but I haven't thought about it too much yet.

Doing anything with my website while on the go, other than edits to content, is more difficult than I would like. And even edits require that my computer is on, connected to the internet, and watching my local directory for changes. None of those can be counted on to be true for a laptop.

##Getting Started with Magneto
These instructions are based on my experience installing Magneto on my 2012 MacBoook Air running Mountain Lion. But I did it a little while back, so if you run into problems, talk to me on twitter [@davidbrunow][linkMeTwitter].

Getting your site up and running with some custom design settings shouldn't take more than a couple of hours, less if you know exactly what you want everything to look like.

###Prerequisites
+ Web server - could be any variety since you will be sending it static files. However, if you are running a Windows or other non-*nix based server you will at least have to come up with a different solution to deploying your files than I will discuss here. 
+ I will not cover the setup of this server here &mdash; I found all of the reference materials at [linode][linkLinode] very helpful if you are running a *nix based server.
+ *nix based local system (Mac OS X, Linux, Unix)
+ You must have ruby installed locally. If you don't have it installed, follow [these instructions][linkRVMInstall].
+ You will also need [coffeescript][linkCoffeeScript], [kramdown][linkKramdown], [directory watcher][linkDirectoryWatcher], [multi json][linkMultiJSON], [exec js][linkExecJS] and [SASS][linkSASS] installed locally.
+ You will need to be able to use a text editor (I use [TextMate 2][linkTextMate2] because I want to be like the cool kids) and the command line.

[linkRVMInstall]: <https://rvm.io/rvm/install/>
[linkCoffeeScript]: <https://github.com/josh/ruby-coffee-script>
[linkKramdown]: <http://kramdown.rubyforge.org>
[linkDirectoryWatcher]: <http://codeforpeople.rubyforge.org/directory_watcher/classes/DirectoryWatcher.html>
[linkSASS]: <http://sass-lang.com>
[linkMultiJSON]: <https://rubygems.org/gems/multi_json>
[linkExecJS]: <https://github.com/sstephenson/execjs>
[linkLinode]: <http://www.linode.com>
[linkTextMate2]: <https://github.com/textmate/textmate>

###Installing Magneto
First, let's check to make sure that you have the prerequisite gems installed. Navigate to this directory either in Terminal or Finder (if you have a version of ruby other than 1.8 installed, then the path will be slightly different):

/Library/Ruby/Gems/1.8/gems/  

Look at the contents of that directory, and see if the following directories exist:  

coffee-script-2.2.0  
kramdown-0.14.1  
sass-3.2.5  
directory_watcher-1.4.1  
execjs-1.4.0  
multi_json-1.5.0  

If any of them are missing, run the following applicable commands to install them (since you are using the `sudo` command, you will have to enter your password after the first command):

    sudo gem install coffee-script
    sudo gem install kramdown
    sudo gem install sass
    sudo gem install directory_watcher
    sudo gem install execjs
    sudo gem install multi_json

Magneto's installation is just as simple as the other gems. You just need to run this command on your local machine:

    sudo gem install magneto

That was easy, wasn't it? Now let's put some content out there.

###Website Generation Files
Now, you will need to create the files that Magneto uses to create your website. The simplest way to start is to download all of the files from Don Melton's website from [github][linkDonMeltonGithub] and then put them in a directory. I created a directory called 'brunow.org' off of my home folder. I think that something off of your home folder will be simplest, since you can use '~/' when needing to provide absolute paths. 

[linkDonMeltonGithub]: <https://www.github.com/donmelton/donmelton.com>

I started by trying to download as few files as possible. The upside of this approach is that I was able to see what each file did by seeing which features were missing at each step. The downside is that it took longer and ground my teeth a lot. But since I already did that for you, I will describe each of the files that you need and what they do, grouped by directory. 

**~/brunow.org/**

The files in this directory handle the basic scripting of building the website as well as the overall configuration:

**Rakefile**: this is ruby's version of a makefile. In general, it is a script that performs certain tasks. In this case, it will start a new draft post, deploy files to your server, clean up folders and post a draft. You will need to make changes to this file, which I will describe later.  
**config.yaml**: this is a general configuration file for your website. You will need to change a number of values in here, which I will describe later.  
**script.rb**: I'm not sure of the most correct way to describe this file. Pretty much, it is the main source code file for the website. Magneto will read through this file, and generate posts based upon the files in the /Items path. This is the main component that uses all of the other ruby files to put all of the pages together.  

**~/brunow.org/Items**

The files in this directory are either a template of each file that will be moved to the server for the website (about.md will become /about/index.html) or the file itself (/favicon.ico will become /favicon.ico in the output.) All content, such as the 'About' page and each individual blog post, is in a variety of [Markdown][linkMarkdown] format called [kramdown][linkKramdownSyntax] and when run through Magneto will be moved into its own directory and named index.html. Anything that will be generated by Magneto is in a file with a .erb extension.

[linkMarkdown]: <http://daringfireball.net/projects/markdown/>
[linkKramdownSyntax]: <http://kramdown.rubyforge.org/syntax.html>

**.htaccess**: this is a file that lives on web servers to establish access rights to directories.  
**404.md**: this is the content that will be displayed when a page cannot be found on your server. It doesn't follow the rule about being moved into a folder and renamed index.html.  
**about.md**: this is content about you. Well, when you first download it, it is content about Don. So you will want to make it about you.  
**archives.erb**: this is the template for the archives page of the website. This file contains both HTML and ruby. The ruby is used to group your posts by dates and display links to each of them in one location.  
**favicon.ico**: this is the image that will show up in the browser bar when someone visits your website. You will need to provide and image and then you can follow [John Gruber's instructions on how to make a retina favicon].  
**index.erb**: this is the template for every file that will be an index.html, which is based upon the document.erb template.  
**robots.txt.erb**: this is the template for the file that tells the ethical bots whether they can traverse your site  
**rss.xml.erb**: this is the template for your RSS feed.  
**sitemap.xml.erb**: this is the template for your site map.  
**css/style.sass**: this is the stylesheet for your website, in [SASS] format. It will become /css/style.css after processing through Magneto (which handles running it through the SASS engine for you).  
**includes/sidebar.erb**: the includes folder holds different 'components' of the web page. This particular file the is template for a right sidebar that has a short bio, recent articles and search.  
**js/jquery.min.js**: the jQuery JavaScript library is an easier way to do JavaScript - it contains advanced functions that would be a pain to write yourself, and solves browser compatibility problems.  
**js/timeago.coffee**: this coffeescript changes the date at the end of your posts from 'January 3rd, 2013' to 'Two months ago.'  

**~/brunow.org/plugins**

The files in this directory are called by either the script.rb file or by the .erb files that build the pages. Each performs its own little part in the process of website generation, and has documentation at the beginning which I will pretty much restate here:

**copyright_year.rb**: uses the copyright year information in your config.yaml file to determine how to display the copyright years   
**image.rb**: creates proper image tags  
**items.rb**: parses individual markdown files to create posts  
**markdown_inline.rb**: parses the markdown syntax  
**reduce_empty_lines_filter.rb**: removes extra whitespace  
**relative_to_absolute_urls_filter.rb**: changes relative URLs to absolute  
**remove_more_marker_filter.rb**: gets rid of the MORE marker  
**strip_html.rb**: not sure  
**symbolic_to_numeric_entities_filter.rb**: changes symbols like `&amp;` to their numeric equivalent `&#38;`  
**video.rb**: creates the proper video tags  

**~/brunow.org/templates**

**document.erb**: the basic template of each 'index.html' file that will be created by Magneto. *You will need to make changes in this file*  
**page.erb**: the template of the page that is inside of the document  
**post.erb**: the template for each post that will be on the main site page  
**post_article.erb**: the template of the page if it is an individual post, rather than all posts  

###Customizing Magneto
Now I will describe the small number of items that you absolutely need to modify to get Magneto running as well as those that you will need to change so that you are not copying the style of Don's site.

First, open config.yaml in your favorite text editor. Change `base_url:` to be the name of your site. If you know how your CDN works, then put in the proper URL there for `cdn_url:` &mdash; I think mine is the same as my base URL, but I haven't researched that yet. Change the copyright information to yours, and put in a description of your site. This description will be part of the document header if you use a template similar to Don's. If you are going to be using Google Analytics, then change Don's number to yours. I actually left Don's GA number in there because I am not using GA and I got an error when running Magneto when I took out that line completely. I did remove all of the GA JavaScript from the pages, however, and will try to track down the source of the problem with removing that line in the future. Instead of GA, I am using [Mint][linkMint]. Why did I choose Mint? Because I want to own my analytics, just like I want to own everything else.

Anyhow, back to changing the config.yaml file: change `search_sites:` to your site's URL, change the `title:` to whatever you want to show up in the browser's tab bar, and change `visible_posts:` to show the number of posts that you want on your main and subsequent pages.

Now to the Rakefile. I don't use the 'stage' or 'deploy' sections of the Rakefile right now, so I won't speak to them. The one thing you need to change if you are going to be using the Rakefile for deployments is the part after `rsync`. You will need to put the information for the directory that you have your output folder in as the first argument after `-avz`. I use the absolute path because I have another process that calls Rakefile to make things more automatic. You will then need to put in the information for your server as the last parameter.

Ok, now to the customization of the look of the site. Let's start in templates/document.erb. In here, you can change the names of the items in the header, add an image to your header like I have, or do other structural type tweaks. This is stuff that I can't tell you what to do &mdash; it is time to make it yours.

So next, we will head to another area that I can't tell you what to do: the css. I change a few things in items/css/style.sass, such as the color of the footer, the way that the site handles different screen widths, and hiding the sidebar.

Ok, you are just about ready, you just need to do three final things:  

+ Delete the directories for each year (2012, 2013, etc.) These contain Don's blog posts, which you won't need.
+ Edit 'about.md' so that it contains information about you instead of information about Don.
+ Replace favicon.ico with an icon of your choosing. Don's face won't represent you very well.

[linkMint]: <http://www.haveamint.com>

###Workflow
My workflow is constantly evolving and hopefully I can keep updating it here as I learn to use Magneto in ways that will better suit my needs. Like the furniture in my living room, I constantly tweak my workflow to try to make myself more comfortable and reduce friction &mdash; anything that I can do to make myself write more often is a good thing.

That being said, here is my current process:

I start a draft post with the command `rake draft`. This way, a new file is automatically created in the drafts directory with a current timestamp and a title that I provide. Since I have my entire ~/brunow.org folder symlinked to my dropbox account, I can then either edit the file in TextMate 2 locally, or use IA Writer on my iPhone or iPad. Sometimes though, I bypass all of that and just start typing in my Notes app on my phone. Then I can just do a copy and paste from my Notes app on my Mac into TextMate when I am ready to create the post. Realistically, the limitation of having to make posts on my computer isn't a bad thing. It means that I have a higher likelihood of taking my time to develop my thoughts, helped by using a screen that is large enough to see meaningful amounts of text at the same time, which I find is better for editing and pruning my ideas.

So that I can make edits to existing files from anywhere, I have Magneto running in auto mode on my MacBook Air. When Magneto detects a file that has changed in the /items path, it will regenerate the site. I then have folder actions setup on the ~/brunow.org file. I learned about how to set up the folder actions [on this site][linkFolderActions]. That action calls [a script][linkFolderActionScript], which deploys the files to my web server with the command `rake deploy` and then runs the command `rake clean` which removes the output directory and all of its contents. As discussed earlier, `rake deploy` uses rsync to send your files to the server.

Since I am using the auto mode of Magneto I could technically start a new post on my phone, but I really like how it automatically handles the timestamp for me instead of my having to figure out the format once again and then typing the whole thing.

Once I have finished writing the post, I use the command `rake post` which re-timestamps, renames, and moves the files to the proper location for the site. Since I have Magneto running in auto mode, it rebuilds the site, and within about 30 seconds I get a Notification Center message that my files have been uploaded by my folder action.

###Future
I hope to keep updating this as I get responses from other users, or as Don updates Magneto. A little down the road I hope to work on my fork of Magneto and my website and get them both up on Github so I can share any enhancements that I make.

I also am planning on using Magneto to create a static engine that creates a sort of "storybook". But that is still just tumbling around in my head right now.

You should definitely follow [Don Melton on twitter][linkDonMeltonTwitter] &mdash; he has already tweeted about one blog post about how to increase Magneto's efficiency and he has great stories about his years developing Safari at Apple. Plus he just seems like a nice guy.

You should also follow [me on twitter][linkMeTwitter] for none of the same reasons.

[linkDonMeltonTwitter]: <http://www.twitter.com/donmelton>
[linkMeTwitter]: <http://www.twitter.com/davidbrunow>
[linkFolderActionScript]: <http://brunow.org/downloads/syncsharedfolder.scpt>
[linkFolderActions]: <https://sites.google.com/site/andreatagliasacchi/blog/osxautomaticsyncwithfolderactions>
