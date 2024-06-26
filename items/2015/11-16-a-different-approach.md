---
published: 2015-11-16T23:18:24-06:00
title: A Different Approach
---
I remember when I first got into programming I approached some problems differently. I'm not sure the best way to describe it, but I think I attacked them like a human would rather than like a computer could. I'll give an example.

A common problem I've come across is tracking time. Let's say I make an application that tracks how long I've been working on a particular task. If I try to solve this problem like a human could, I'd try to count the number of seconds I've been doing something. Each time the clock ticks, I increment a variable that is tracking my total time. And really, this isn't an unreasonable approach to the problem, even for a computer. But solving the problem like a computer can is much better.

A computer can store abstract values that are difficult for the human mind to remember. And a computer can perform calculations on those values so much faster than I can blink that it boggles my mind if I let myself think about it. So a computer can use a different approach to solving this problem -- it can store the starting time and the ending time and perform a calculation to find the total time. Why is this much better? 

First, we have much richer information. Not only do we know the total time, but we know the start time and finish time. If we want to run a report and see how many hours are logged starting between 10 and 11 in the morning, we can. Since we can never predict how we may need to use information in the future, richer information is valuable.

Second, the system is more reliable. If our program is counting and runs into a crashing bug then the count is lost. That is really bad if you're trying to track billable time. If we save a start date and the program crashes, we still have that start date available when the program starts back up and we can continue where we left off.

Third, the second approach is more efficient. If the computer constantly has to increment a number then it has to repeatedly work at regular intervals. That means it is using more power, and in the case of a mobile device draining the battery more quickly.

Since I've been doing programming for a while, the second approach is the only obvious one to me now. I have to work to try to remember how I approached the problem back when I was a beginner to see any other way to solve it.