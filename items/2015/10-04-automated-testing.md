---
published: 2015-10-04T23:06:24-05:00
title: Automated Testing
---
I've never been a proponent of automated testing. I don't believe in Test Driven Development and I've never written tests for my code. Despite that, I've shipped high quality code that I've been able to maintain without worrying about breaking things.

I attribute my ability to not break things to two factors: 1) I generally work alone on projects so I'm the only one touching the code, and 2) I don't use any sort of refactoring tools and if I need to refactor I do it all myself so that once again I'm the only one touching the code.

This has worked really well for me. So well that I wondered why anyone would spend time making tests and thinking "leave it to software developers to come up with a solution to bad code that involves writing more code."

But recently I've changed my mind about automated testing. I can see how it can find bugs that get introduced into your code and how it can provide peace of mind. I changed my mind because I had to do automated refactoring -- so I wasn't the only one touching the code -- and my code got broken.

Fortunately the app that got broken was still in beta so the issues were caught quickly with minimal impact. And if I'd spent a little more time testing the app after the changes then I'd have found the broken parts before the tester. But if I'd had automated tests in my code I would have known where the issues were immediately after the automated refactoring.

So I'm going to start getting more familiar with testing. I still don't believe that Test Driven Development is the right system, at least not for new projects, so I probably won't adopt that. And I probably won't write tests in every environment -- if I'm the only one writing code and I'm not using automated refactoring then tests are just more overhead and more code that could have bugs.

But now at least I can understand the point of them and see the value they can provide in peace of mind alone.