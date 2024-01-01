# State is where the bugs are
date: 2016-04-11T23:16:32-05:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
I read an interesting blog post by Brent Simmons the other day where he was comparing reactive programming with traditional iOS programming. He made a comment about how you want to avoid state in your program because state is where the bugs are. I know he is a much more experienced programmer, but I can't get my mind wrapped around what he's saying enough to agree. I think that state is one of the best parts of programming or, more specifically, building systems that maintain and change state over time.

In my mind, complexity is where the bugs are. And try as you might you can't avoid complexity for any reasonably sized project. You can move it around to different places but it is still there.

So the key is to make it as easy as possibly to reason about the complexity and to hold it in your mind. Which is similar to something Brent said &mdash; he prefers the straight forward, easily readable, and understandable version of the code more than a version that solves the problem "better."

In all programming our minds are the weak link. We have to find the best ways to optimize for our understanding above all else.
