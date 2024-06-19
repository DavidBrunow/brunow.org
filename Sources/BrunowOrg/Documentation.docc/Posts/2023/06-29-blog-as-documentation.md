# Blog as Documentation
Intentionally choosing the wrong tool for the job.

@Metadata {
  @Available("Brunow", introduced: "2023.06.29")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "siteHeaderScreenshot",
    alt: "Screenshot of the header of the home page for this site."
  )
}

It has been over six years since I've written anything for my blog. I stopped
writing due to a number of factors but most of them are irrelevant for what I
want to write about today. Today I'm going to focus on the technical reasons
behind my writing drought, so the relevant bits are the ones around the
technology that powered my blog: static site generation powered by a tool called
[Magneto](https://github.com/donmelton/magneto) and a Linux server hosted by
Linode.

## Backstory

Magneto is like many other static site generators in that it is written in
Ruby, allows complete customization using Ruby templating and CSS, and parses a
collection of Markdown files to generate the blog's content. But Magneto is also
different than the most popular static site generators in that the author built
it as a fun side project and not for general use. I can't remember with any
certainty but I think they advised against anyone else using it. Apparently I'm
drawn to using things I shouldn't because I adopted it as my static site
generator of choice shortly after they open sourced the project.

If you look in the archives here you can see that I wrote hundreds of posts
using this setup. At times it was easy, especially when I was on a roll of
posting regularly and my tooling (my computer, operating system, Ruby
version, etc.) wasn't changing. But when my posting was irregular or my tooling
changed I felt pain. The errors I ran into were obtuse and cryptic. While trying
to think of a way to describe it the only thing that comes to mind is 
[the "PC LOAD LETTER" scene from the movie Office Space](https://www.youtube.com/watch?v=5QQdNbvSGok).

A large part of the problem is that I was learning Ruby as I encountered these
issues and, while I was learning, Ruby was changing, growing, and releasing new
versions. My pace of learning would never keep up with the pace of change
because my use case was limited and I just didn't flex those muscles often
enough. My hobby use of Ruby could only lead to more pain.

After fighting with Ruby for who knows how long I still had the task of getting
those files I generated onto the Linux server. It is a fairly straightforward
task &mdash; all one needs to do is to run a tool called `rsync` from the
Terminal to copy the files from one's local machine, like the laptop I'm typing
on right now, to the server. I cannot possibly explain, or even understand
myself, all the tension in my body that has been built up by such a simple
thing. I just could not remember how to run the command properly from one
invocation to the next. This was fine when I could just press the up key in the
Terminal to get to the last time I recited the encantation but that was not
reliable enough over time because I'd lose the history in one way or another.
Today I'd write a very simple shell script that would remember the command for
me but at that time I had no experience with shell scripts. Back then my brain
would much rather learn about new shiny tools than learn about the basic
fundamentals like shell scripting. 

Speaking of new shiny tools, somehow I got it into my head that a task runner
was the thing I needed so I tried out the different task runners du jour,
although the only two I can remember were a Rakefile and Grunt. Grunt is a tool
written in JavaScript and everything I mentioned above about Ruby changing,
growing, and releasing new versions is at least an order of magnitude worse (or
better, depending on your point of view) in the JavaScript ecosystem. And I also
had the same problem of not using these task runners enough to be familiar with
their idiosyncrasies &mdash; neither Ruby nor that sector of the (very large)
JavaScript ecosystem were part of my day-to-day work.

## Using Tools I'm Already Using

One theme from my experience has stood out more than any other:  not being
intimately familiar with your tools and their ecosystem leads to the kind of 
pain that isn't good for me. Given that, I've tried to find ways to use the same
tools I use to develop for Apple's platforms in my day job. That started with
looking into some open source static site generators written in Swift but none
of those stuck. The Swift those tools use is the same Swift that I use daily but
the approach was much different than the code I would write and I wasn't bought
into the ecosystem for each of the projects. I also went a long ways down the
path of writing my own static site generator but that has turned into a big
thing that I haven't been able to devote time to.

Something else clicked during WWDC this year. The improvements in DocC,
Apple's documentation generation tool which can also generate static sites, plus
the support for documentation previews in Xcode made me think that maybe DocC
could work for my blog. Plus, I write a lot of documentation as part of my job
and I've wanted to get more familiar with DocC so I could use it even more at
work. Seems like a win-win-win.

Well, everything isn't perfect but so far I'm probably more pleased than
displeased with my experience.

Here's what I like about using DocC to generate my blog:

* Apple has created an opinionated and, to my eyes, pleasant design. My control 
over it is limited but not needing to make design decisions is nice and removes
something that was causing me to get stuck.
* Media handling is simple and straightforward.
* I get automatic support for features I value, like light and dark mode 
switching, searching by post titles, and formatting of code blocks with proper
syntax highlighting.
* Everything is in an ecosystem (Swift Package Manager, DocC) that I can use (
and misuse) well due to my experience working with these tools daily.
* I can easily build the site and push the changes to GitHub and host it on
GitHub Pages for free.
* Site generation is fast &mdash; it takes less than 2 seconds on my M2 MacBook
Air.

Here are some things that I find noteworthy but not good or bad:

* DocC will probably require a bit more manual work than other static site
generators. For example, I don't know of a way to loop over the `N` posts I've
written most recently so I'm doing that manually. Other folks may have much less
tolerance for that extra work but I actually kind of like it since the manual
work is lightweight and doesn't require abstractions.

And here is what I don't like about it:

* The site that DocC generates is very opinionated about looking like Apple's
documentation. This makes perfect sense for its intended purpose, but I'm not
sure how I feel about it for this purpose I'm misusing it for.
* The site that DocC generates has a base path of "documentation/MODULE_NAME"
but I'd rather the site were at the root with no extra path. But really, do
people care what URL they are linked to for a blog post? I don't.
* I don't believe that DocC generates an RSS feed which is my favorite way of
consuming a blog.

> I do want to be clear here to say that none of my complaints are about DocC
itself and I wouldn't ask for these things to change. The complaints are simply
about how it fits into what I'm trying to do with my blog while holding the tool
completely wrongly.

## Workflow

Here's my workflow for writing posts using DocC now that I've finished the 
initial setup:

1. Create a file with a ".draft" extension for a new post. Using this extension
excludes the file from static site generation until I'm ready to publish it. 
2. Write. I'm using Xcode 15 beta 2 for all my writing because it has a nice
preview of the rendered document.
3. When ready to publish, change the file extension to ".md".
4. Create a link to the new post on the home page, for example: `- <doc:06-29-blog-as-documentation>`.
5. Run a script that generates the site. The script runs this command which is
quite a mouthful and difficult to memorize: 
```sh
swift package --allow-writing-to-directory docs generate-documentation --target Brunow --disable-indexing --output-path docs --transform-for-static-hosting
```
6. Commit the docs directory.
7. Push the changes to GitHub. GitHub will automatically update the site.

> The workflow in step #5 is more complicated at the moment because I've created
the Swift package for building the site in a separate directory, so I have to 
generate in one directory and then copy that directory over to the right place
before committing. I didn't include that in the steps because I expect it to be
temporary but felt like I needed to add this note since I haven't committed the
package to the repo hosting the site.

## Moving Forward

I'm definitely not sold on this solution but I'm giving it a go. I've
converted all my old posts to a format that works with DocC and, although I
still have some cleanup there, it should be enough content to give me a good
feel of how the site looks and feels. I'm going to try living with it for a
while and see what additional insights time will provide. Will I cringe when I
look at it in a month? Or will I get burnt out on a workflow that is too heavy?
Maybe I'll be delighted each time I think about how I'm documenting myself.
Only time will tell.
