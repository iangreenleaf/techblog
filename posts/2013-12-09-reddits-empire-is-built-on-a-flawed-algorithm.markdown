---
title: Reddit’s empire is founded on a flawed algorithm
---

Reddit has a bug in their code. This bug is currently present in their production platform, and has been for years. It affects one of the most important algorithms in the entire site, the "Hot" ranking algorithm for link popularity. It has real, demonstrable negative effects. It has been reported to Reddit's technical team several times and never fixed.

## The Bug ##

Reddit needs to determine which articles are "hot" right now. Newer material is better than older material. Material with many positive votes is better than material with few votes, and both are better than material with mostly negative votes. This is pretty straightforward to calculate. One determines numeric values representing these two measures, and multiplies by some constants to determine exactly how much priority each measure gets[^4].

The devil is in the details, or in this case, [the implementation](https://github.com/iangreenleaf/reddit/blob/45e8209d8d4236367a6f7247068c13ab2307afb4/r2/r2/lib/db/_sorts.pyx#L45).

```python
seconds = date - 1134028003
```

The time-dependent variable, named `seconds`, is based on a UNIX timestamp. It's a bright way to do it: time is forever counting up, so every new submission receives a slightly higher score from the time variable than every submission that came before it.

```python
s = score(ups, downs)
order = log10(max(abs(s), 1))
if s > 0:
    sign = 1
elif s < 0:
    sign = -1
else:
    sign = 0
```

The vote-dependent half of the equation has two parts. The `sign` variable simply designates if the total vote sentiment is positive or negative. If the material received more positive votes than negative votes, `sign` is `1`; if more negative votes, `sign` is `-1`. The other variable, `order`, is the `log₁₀`[^5] of the absolute value of the vote score.

The actual problem stems, as so many problems do, from the transposition of two characters.

```python
return round(order + sign * seconds / 45000, 7)
```

Here we have our final score calculation. `seconds` is a large positive number. `order` will always be positive -- it uses the absolute value, so a submission scored -389 will have the same value for `order` as a submission scored +389. We need to use `sign` to adjust `order` so that net-negative submissions are penalized accordingly. But *this* code multiplies `sign` and `seconds`, *not* `sign` and `order`.

On net-positive submissions, this has no effect. `sign` is `1`, so `order` and `seconds` are added together and everything is good.

What happens on a net-negative submission? `sign` is `-1`, so the very large `seconds` value becomes negative. Then a *positive* `order` is added to that. This has several surprising results!

Imagine two submissions, submitted 5 seconds apart. Each receives two downvotes. `seconds` is larger for the newer submission, but because of a negative `sign`, the newer submission is actually rated *lower* than the older submission.

Imagine two more submissions, submitted at exactly the same time. One receives 10 downvotes, the other 5 downvotes. `seconds` is the same for both, `sign` is -1 for both, but `order` is higher for the -10 submission. So it actually ranks *higher* than the -5 submission, even though people hate it twice as much.

Now imagine one submission made a year ago, and another submission made just now. The year-old submission received 2 upvotes, and today's submission received two downvotes. This is a small difference -- perhaps today's submission got off to a bad start and will rebound shortly with several upvotes. But under this implementation[^6], today's submission now has a negative hotness score and will rate *lower* than the submission from last year.

## Consequences ##

This is not a hypothetical problem. Curious to see if the code in Reddit's public repository was what they had running in production, I found a recent post in a fairly inactive subreddit and downvoted it, bringing its total vote score negative. Sure enough, that post not only dropped off the first page (a first page which contained month-old submissions), but it was effectively banished from the "Hot" ranking entirely. I felt bad and removed my downvote, but that post never really recovered[^7].

Indeed, by manipulating the query string, you can find a strange purgatory where damned submissions slowly rot, alone in the darkness[^9]. Here is a collection of unfortunate articles from the iPhone subreddit:

![Reddit's purgatory for posts](/images/2013-12-09-reddits-empire-is-built-on-a-flawed-algorithm/post_purgatory.png)\ 

These posts are sad, alone, and afraid. And notably, they are sorted oldest first, just as I predicted.

This banishment flaw opens a door for more intentional gaming of the system as well. Imagine a hypothetical subreddit, /r/BirdPics, devoted to pictures of birds[^8]. An attacker despises puffins, and wants to keep all pictures of puffins off the front page. This attacker can downvote every picture of puffins, but will be outgunned by the other users who like and upvote puffin pics. On average, 350 people are watching the front page of this subreddit at any one time, so that's a lot of upvotes to contend with.

Instead, our attacker will watch the new submissions very carefully, and the moment a puffin pic is submitted, immediately downvote it. If the attacker gets to the picture first, it will go negative and be utterly exiled, never again touching the front page. The only thing the attacker needs to worry about are the people watching the "New" ranking, which ignores votes. Our hypothetical subreddit only averages 10 people on the New page, so our attacker can defeat them simply by maintaining 10 sock puppet accounts, instead of the ~300 that would be needed to defeat the front page users. Just like that, our attacker has scrubbed the subreddit of all puffin pics, and the world is a poorer place for it.

## Remediation ##

I wasn't the first person to notice this error. Jonathan Rochkind covered it in [his well-written post on the subject](http://bibwild.wordpress.com/2012/05/08/reddit-story-ranking-algorithm/). He was [told by a Reddit developer](http://www.reddit.com/r/programming/comments/td4tz/reddits_actual_story_ranking_algorithm_explained/) that he was "just incorrect" and that the algorithm as it exists is "not wrong".

I submitted [a pull request](https://github.com/reddit/reddit/pull/583) fixing the bug, and was informed by a different Reddit developer that "it's that way by design". I do not understand, nor have received a satisfactory explanation of, in what sense this nonsensical behavior would be "by design". But it is clear that Reddit is not interested in fixing this, and this behavior will probably persist for many more years.

## Denouement ##

Programmers tend to nurture a definition of justice that revolves around rule conformance. It's why many of us find worldly realms like relationships or politics so intractable, and why many of us were drawn to computer science in the first place. In computation, everything is strictly deterministic. If something happens that doesn't make sense, it can only be because our understanding of the system is incomplete[^1]. To be Right, capital-R Right, is a system that is fully understood and executes precisely as expected.

When we hold this type of worldview, intentional propagation of a bug seems *unjust*. Myself and the other developer who pressed this issue seem to have a more complete understanding of the algorithm than the Reddit employees who responded to us. We're certainly correct about the surprising and counterintuitive behavior of the unpatched algorithm. We are *Right* and Reddit is *Wrong*. And Reddit has a wildly popular site, a tremendous userbase, and tons of cash flowing in. All built on a foundation with an obviously *Wrong* component.

What's the moral here? Maybe it's that an insufficiently tested system becomes an insufficiently understood system, and eventually a system that is defended with rationales like "it just works, stop asking questions". Or not. Maybe the moral is that the perfect is the enemy of the good, that worse is better[^3], that splitting hairs can distract us from the haircut[^2]. Maybe it's that a good technical implementation is a distant second to a good *product*, and that hard data should always yield to a positive experience.

Maybe there is no moral. Reddit screwed up. It could have hurt them, but it didn't, and probably won't. They are wrong but they are not Wrong because there is no such thing as capital-W Wrong. Moral codes are ideas that we construct, and there is no god of determinism that will one day smite Reddit for their crime of being bad at math. The world is a flawed place, has always been a flawed place, will always be a flawed place.

[^1]: This is also, I suspect, why the [heisenbug](https://en.wikipedia.org/wiki/Heisenbug) is perhaps the most feared and hated event in all of Computer Science. See also: [releasing Zalgo](http://blog.izs.me/post/59142742143/designing-apis-for-asynchrony).
[^2]: Can you guess which one of these analogies I just made up on the spot?
[^3]: The "worse is better" meme originates in [Richard Gabriel's seminal article](http://www.jwz.org/doc/worse-is-better.html) on the rise of C and fall of LISP. This article and the later follow-ups are some of the best writing the computer science world has ever seen.
[^4]: This is a simple yet powerful idea. You could create some wildly different sites that all relied on the same algorithm but with different constants. Want a site that surfaces very old content? Weight the time variable very low. Want Twitter? Weight the vote variable 0.
[^5]: The logarithmic scale accounts for vast differences in popularity throughout Reddit - the difference between 1 and 11 votes is much more important than the difference between 10,001 and 10,011 votes.
[^6]: This particular behavior is dependent on `seconds` being large enough to overpower `order`. In Reddit's implementation, it is.
[^7]: While testing, I noticed a number of odd phenomena surounding Reddit's vote scores. Scores would often fluctuate each time I refreshed the page, even on old posts in low-activity subreddits. I suspect they have something more going on, perhaps at the infrastructure level -- a load balancer, perhaps, or caching issues.
[^8]: [Of *course* it already exists](http://www.reddit.com/r/birdpics).
[^9]: I cannot provide a persistent link to this purgatory because the indexes seem to disappear after a day, but it's easy enough to find. First, find a recent negatively-scored submission and take note of its ID, which can be found in the URL. From the URL `http://www.reddit.com/r/birdpics/comments/1s33tt/fear_the_shrike/` we get the ID `1s33tt`. Now insert it into the following URL, substituting as necessary: `http://www.reddit.com/r/SUBREDDIT/?count=9999&after=t3_ID`. Our URL would become `http://www.reddit.com/r/birdpics/?count=9999&after=t3_1s33tt` - note that the ID is prepended by `t3_`. And yes, you may change the `count` to whatever you wish; that number is totally made up.
