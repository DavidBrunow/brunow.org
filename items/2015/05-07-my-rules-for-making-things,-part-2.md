---
published: 2015-05-07T22:47:52-05:00
title: My Rules for Making Things, Part 2
---
The first rule for making things was all about simple tools, a pen and paper, a marker and a window, and good questions. This second rule is where some fancy tools really make the difference.

## Step 2 -- Make Iteration Simple by Reducing Friction

1. Make changes easy -- Use common editing tools that are easily accessible. Automate deployments to production so your changes get to users quickly. 

    We use a simple text editor as much as we can. We use [Grunt](http://gruntjs.com) for deployments as simple as 'grunt deploy'.

2. Make mistakes painless -- Use a version control system that tracks every change you make. You will be able to track down code that broke things and painlessly undo those changes.

    We use Git for our version control system. I don't believe that any of the other version control options even come close.

3. Make testing simple -- Have a safe test environment that replicates production. The easier it is to test the more you'll do it and the better the products you'll ship.

    Our local machines mirror production perfectly so testing is super simple. We setup local web servers with Grunt that make starting the test environment as simple as 'grunt server'.

Of course, the specific tools you use for your workflow will have to adapt to that workflow. I have to change things up when I am making an iPhone app -- I have to use a fancier program because the code has to be compiled. These particular tools are a good starting point for thought and discussion.