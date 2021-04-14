---
published: 2016-02-04T08:09:09-06:00
title: Failing Forward
---
When something goes wrong in technology, like you send software out to your customers that is broken or your web server configuration breaks, you generally have two options. You can choose to restore everything to a recent known good state, reexamine what went wrong, and try again to get it right the next chance you get. Or you can find the problems that are happening now, fix them, and move forward with the new thing in place.

Neither answer is the right answer for every situation but I always try to fail forward first. Usually problems are simple enough to fix that restoring from backup will take more time. Plus, you can't guarantee that you'll find out why it failed the first time. Something could be different in your test environment that you didn't think about while testing your changes.

The not-so-secret to success is to set yourself up for success. Know as much as possible about the systems you are working with. Know how they interact with every other system. Know what could go wrong. Most of all, know your fundamentals. If you are migrating a web server then you need to know how the entire HTTP stack works. Without all that knowledge you'll be guessing at solutions rather than making smart decisions.