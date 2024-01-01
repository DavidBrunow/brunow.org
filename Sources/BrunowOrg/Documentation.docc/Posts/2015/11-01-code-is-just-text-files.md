# Code Is Just Text Files
date: 2015-11-01T22:59:30-06:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
A colleague asked a question about why we were running into issues with features being overwritten in a test environment today. I replied and thought the topic would be good for a blog post, which I've adapted from the email.

In essence, the code that we write is just a directory of files that tell the computer what to do. We try to separate out different parts of the application into different files – for example we have one file that tells the computer how to do anything having to approvers – so that we can more easily reason about the application’s logic, so we only have to fix bugs or add features in one place, and so we have fewer issues with two people modifying the same file. Despite these efforts, if two people are working on two separate features at the same time then each of them can possibly make changes to the same files.

If those two people were both working on the same files in the same folder then they would constantly be causing problems with what the other was trying to do, similar to the problems you run into if you are trying to modify an Excel spreadsheet at the same time as someone else and you get locked out or lose changes. Whoever saved last would have their changes in the file and the other person’s changes would be discarded. To avoid this problem, each of us works on our own version of the files on our own computer. We use a software called Git to help us manage which version of the code is on our computer and it also helps us share the code between each other. Git also takes care of taking two versions of a file that two people have both made changes to and making them into one version.

The problem we are running into now is that we can only have one version of the files on the UAT server at a time. When I put my version out there it overwrites the other person's version and their features are no longer available. The best way to solve this problem is to coordinate which testing will be happening at which time. 
