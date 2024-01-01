# Limiting Variables and Seeing Things Happen
date: 2016-02-06T08:25:45-06:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
When in the first steps of making something new I concentrate on two things, limiting the things that can go wrong and seeing something work. I start with the most simple situation possible by hard coding known good values. For example, if I'm logging a user into a system I won't build the part to get the username and password from the user at the start. I'll code a username and password that I know will work directly into the application. That means that if the logging in process doesn't work that it is something wrong with the way I am sending the information rather than somehow sending the wrong information.

Hard coding those variables naturally leads to seeing things happen faster. I'm not building an entire user interface for a login screen just to be able to log in, I'm building one small piece of code that I get to see work within a few hours.
