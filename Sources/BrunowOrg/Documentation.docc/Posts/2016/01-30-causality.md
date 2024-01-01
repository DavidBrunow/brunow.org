# Causality
date: 2016-01-30T12:27:20-06:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
Last night I was up until 4:30 in the morning working on a server migration, moving an old Windows 2003 server to Windows 2012. I started this migration last weekend and got my tail whooped &mdash; everything took longer than I expected and I ran out of weekend before I overcame all the problems that popped up.

Last night I approached the problem with a fresh mind and a new plan of attack I'd come up with over the week. But while the plan of attack got me started, I don't owe the successful server migration to it. I owe it to realizing I was approaching the problem wrong.

Any reasonably complex system starts to feel like magic. An operating system, like Windows Server, is a very complex system. All that complexity hides causes and effects from you because there is no way to see exactly what is going on everywhere in the system. I'd gotten lost in this complexity and forgotten the power of causality. After struggling with the problem all last weekend I'd gotten lost in the complexity. I wrote off the migration failure as a sort of magic, thinking and saying "if it failed the first time it will probably fail again." I'd lost my power over the situation because I didn't think I could change it.

Last night I ran into problems again, some the same as last time and a couple new ones too. But this week things changed when somewhere along the way a new idea clicked. I thought "I need to figure out what is going wrong so I can fix it." Sounds simple, I know, but it had escaped me.

First step, figure out what is going wrong. The system is too complex to see all the moving pieces at once, but I can look at individual parts. What tools do I need to do that? What information do those tools give me? How can I use that information to solve the problem? Repeat those three questions until you solve all the problems, with a little bit of thought about whether one problem could be causing another and whether you need to stay focused, or bounce between the different problems, or broadly attack all of them. When in doubt, stay focused.

My moral from this story is that I can easily fall into a trap of thinking that something is magic rather than a complex system of cause and effect. Any complex system can be figured out with enough time and energy.
