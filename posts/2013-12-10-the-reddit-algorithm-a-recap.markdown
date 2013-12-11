---
title: The Reddit algorithm: a recap
---

Yesterday, I published [a modest post](http://technotes.iangreenleaf.com/posts/2013-12-09-reddits-empire-is-built-on-a-flawed-algorithm.html)
detailing a flaw in the Reddit ranking system, the consequences, and the response to it. A few hours later,
it was [#1 on Reddit](http://www.reddit.com/r/technology/comments/1siiiw/reddits_empire_is_founded_on_a_flawed_algorithm/)
and [#2 on Hacker News](https://news.ycombinator.com/item?id=6878369). I was not expecting this, to say the least.

## Rejoinder ##

The Reddit developers spoke up again in the comments to explain themselves a little further.
Notably, for the first time that I'm aware of, there is
[some indication](http://www.reddit.com/r/programming/comments/1si31j/reddits_empire_is_founded_on_a_flawed_algorithm/cdy1ba5)
that they *do* consider this a bug and might be planning to fix it at some point.

A number of helpful people also sent me links to previous discussions on this subject,
some of which I had not dug up on my own.
[This thread](http://www.reddit.com/comments/6ph35/reddits_collaborative_filtering_algorithm/c04ixtd)
contains a fairly thorough discussion of the implementation, and a proposal from a
developer to change the algorithm -- surprisingly, in a different way than what I believe should be done.

I want to make clear while we're on the subject that I was never looking to be hard on the Reddit developers.
I *do* believe that I am right and they are wrong, and I *do* believe that they have done a poor job
of communicating the actual reasons behind this decision, whatever those reasons are.
But I don't think that the Reddit devs are jerks or idiots or anything else.
Managing a community is tough work, and all the tougher when your code is open for people to
pick through and criticize. I do want this issue fixed, but I wasn't really looking to
start a crusade for it[^2].

## Agreement ##

My discussion of vote gaming struck a nerve. If there's one lesson to take away from this
article's popularity, it's that vote manipulation is something Redditors are thinking about
and are worried about - not just the programmer types, but everyone.
Many people have pet theories about what kind of widespread vote manipulation is taking place[^3].
All sorts of comments poured in about this, everything from the reasonable ("I wish there
were more safeguards against trolls") to the full-blown conspiracy theories ("Wake up sheeple").
Several moderators of subreddits chimed in to say that they
[have struggled with the vote banishment in their subreddits](http://www.reddit.com/r/technology/comments/1siiiw/reddits_empire_is_founded_on_a_flawed_algorithm/cdy0aet).

Another kind person, [rubicks](https://github.com/rubicks), sent me a graph he created based on my article that provides an
[abstract representation of the function curves](http://www.onlinefunctiongrapher.com/?f=log%28max%28abs%28x%29%2C1%29%2C10%29%2Bmin%28max%28-1%2Cx%29%2C1%29|log%28max%28abs%28x%29%2C1%29%2C10%29*min%28max%28-1%2Cx%29%2C1%29&xMin=-50&xMax=50&yMin=-3&yMax=3)
generated[^4] by the existing calculation (purple) and my proposed solution (green). It's a powerfully intuitive way
to make the argument -- the existing version spikes in a strange and discontiguous way.

## Disagreement ##

A number of people also disagreed with my stance, proposing alternate explanations
for the behavior I described. I am not entirely convinced by any of the theories I
have seen so far, but some of them are interesting and I did enjoy reading them.
Click through for my responses and further discussion.

* That a post with more downvotes in a shorter period of time is
  [worse because that indicates it is more hated](http://www.reddit.com/r/programming/comments/1si31j/reddits_empire_is_founded_on_a_flawed_algorithm/cdxva8s).
* That [many negative notes demonstrates lots of activity on a post](http://www.reddit.com/r/programming/comments/1si31j/reddits_empire_is_founded_on_a_flawed_algorithm/cdxtgby),
  and thus still a measure of "hotness".
* That banishment [helps with spam/noise control](http://www.reddit.com/r/programming/comments/1si31j/reddits_empire_is_founded_on_a_flawed_algorithm/cdxwu8p), because spam will quickly receive several downvotes.

## Action ##

In response to my article, [/r/Chicago](http://www.reddit.com/r/chicago) is launching
[a month-long experiment disabling downvotes](http://www.reddit.com/r/chicago/comments/1smy3u/more_pictures_less_downvotes/)
in their subreddit. I'll be very interested to see how it turns out for them.

Most importantly of all, [/r/BirdPics](http://www.reddit.com/r/birdpics) ***held a Puffin Day in my honor***.

![Puffin Day at /r/BirdPics](/images/2013-12-10-the-reddit-algorithm-a-recap/puffin_day.png)\ 

You guys... you really shouldn't have. What an honor. I don't have the words to tell you how
much this means to me. No, no I'm fine. I just got something in my eye.
It's fine. Just an eyelash. Runny nose. It's fine. Excuse me for a moment.

## Corrections ##

A number of people helpfully pointed out that the fluctuating vote numbers I was seeing were due to [vote fuzzing](http://www.reddit.com/r/WTF/comments/eaqnf/pardon_me_but_5000_downvotes_wtf_is_worldnews_for/c16omup?context=3), an anti-spam feature. I have corrected that footnote[^1].

I linked to the wrong piece of code when discussing the bug, leading some people to believe it has been fixed in production. This was my *fork* of the Reddit code in which I fixed it, not the official Reddit repo. I've now changed that link to point to a pre-fix commit so as not to be confusing.

Someone else corrected my statement that Reddit has "tons of cash flowing in" by pointing out that they're still not profitable. I haven't amended that because that's just mean.

## Miscellany ##

Did you know that [Randall Munroe has taken an interest in Reddit's ranking algorithms](http://blog.reddit.com/2009/10/reddits-new-comment-sorting-system.html)?
Well, now you do.

Another user contends that ["Controversial" is the real worst sort implementation](http://www.reddit.com/r/programming/comments/1si31j/reddits_empire_is_founded_on_a_flawed_algorithm/cdxycdk). Some good discussion ensues.

And then there's [this story](http://www.reddit.com/r/programming/comments/1si31j/reddits_empire_is_founded_on_a_flawed_algorithm/cdy13zc?context=3). I don't have a lot to say about that.

[^1]: These corrections also provide an answer as to whether anyone reads the footnotes.
[^2]: You should realize that I never, ever imagined that a technical post written for a technical
      audience on my quiet little blog would net this much attention. The absolute ceiling on my
      expectations was having it do well on [/r/programming](http://www.reddit.com/r/programming/).
[^3]: Due to the uncertainty introduced by vote fuzzing, I assume these theories are mostly speculation
      rather than hard observation. However, some of the theories are, like mine, quite plausible.
[^4]: Don't look at the actual numbers on the graph, as they won't meet up. It's the shape of
      the curves that can help visualize how scores will relate.
