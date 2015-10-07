---
title: Reddit has no idea how their front page works
date: 2015-10-07
---

Vice:Motherboard yesterday carried a story titled ["Reddit Is Working on an Entirely New Front Page Algorithm"](http://motherboard.vice.com/read/reddit-admits-its-front-page-is-broken-is-working-on-an-entirely-new-algorithm). It covers recent dissatisfaction among Redditors with perceived changes in how articles reach the front page. It's a fine title, but I think mine is at least as accurate.

The conclusion of the Vice article seems plausible: that the algorithm hasn't changed, but growth of the site and the usage patterns that came with it caused an imbalance in the factors used for scoring. But the real story lies in what Reddit had to say about the scoring problems.

<blockquote cite="http://motherboard.vice.com/read/reddit-admits-its-front-page-is-broken-is-working-on-an-entirely-new-algorithm">"Users have been complaining about the front page being stale, and they might be right," Steve Huffman, Reddit's CEO, told me in a phone interview. "I've noticed it too. We didn't change anything, but it feels slower."</blockquote>

Asked about it a month ago, the CTO (that's Chief *Technical* Officer) admitted he didn't know. He [relayed the question to a developer](https://www.reddit.com/r/announcements/comments/3lv3qo/marty_weiner_reddit_cto_back_to_cto_all_the_things/cv9jiku), who responded with gaslighting:

<blockquote cite="https://www.reddit.com/r/announcements/comments/3lv3qo/marty_weiner_reddit_cto_back_to_cto_all_the_things/cv9jiku">…whatever you're perceiving is almost certainly imaginary in terms of change to the site. Software wise, absolutely nothing has changed.</blockquote>

This response isn't hugely surprising. After all, [a serious bug in the "hotness" algorithm's downvote scoring](http://technotes.iangreenleaf.com/posts/2013-12-09-reddits-empire-is-built-on-a-flawed-algorithm.html) existed for over 6 years before being patched, including 2 years after Reddit was notified of the bug.

This latest scoring problem has been growing for a long time, even if public uproar only started recently. Besides a conceptual analysis of the scoring algorithm, there are other ways this could have been detected. If Reddit tracked some basic metrics about front-page stories, such as "average/max story age" and "time to reach front page", they could have identified the changing nature of the site long before it became obvious to the public. But instead it grew to a point where it was identifiable even with a "black box" view of the site, and where the first official acknowledgement came from the CEO eyeballing the site in his browser.

<blockquote cite="http://motherboard.vice.com/read/reddit-admits-its-front-page-is-broken-is-working-on-an-entirely-new-algorithm">"I'm 90 percent sure it's as simple as that. The other 10 percent is, maybe there's something else going on."</blockquote>

**No one at Reddit fully understands how their front page algorithm works.** Reddit is the top and only source of news for thousands (millions?) of people, and a drastic shift occurred in the selection of which news is made visible, and no one at Reddit had any control over this process.

None of this is meant to particularly knock the Reddit developers' competence[^1]. The only unusual thing about their situation is that most of Reddit's code is public[^2], allowing outsiders to analyze the situation and make more educated guesses about what's going on.

This exact same scenario is playing out at countless other tech companies, only shrouded in secrecy and misdirection. Most of them we will never even know that something is wrong, since there is more to be learned by what we *don't* see than by what we *do*. Most of them will never answer for their mistakes, nor correct them.

Google decides what we find when we search. Facebook decides which of our friends we speak to. LinkedIn directs the course of our professional lives. Netflix tells us how much we will like a movie. Hulu decides which commercials we see. Twitter, if they ever manage to stop patching leaks long enough to build anything new[^3], will definitely start controlling their stream algorithmically. And I bet none of these companies has a single employee with a complete and 100% accurate understanding of how their respective algorithms work in practice.

These are only the tech "giants". A second wave of algorithmic takeover is underway among a thousand smaller companies that interact with every other facet of our lives. Algorithms decide which coupons print for you at Target. Algorithms decide how long you brush your teeth. Algorithms decide which streets you travel on. Algorithms decide which words to suggest in your phone's autocorrect. Algorithms may soon decide [which tech startups get funded](https://www.conspire.com/welcome) to build *more algorithms*. And as the [Internet of Things](http://weputachipinit.tumblr.com/) expands, algorithms are going to push their way into our shopping lists and water bottles and a hundred other tiny facets of our lives[^4], each one coded up by a different company working mostly in isolation and without outside review.

These companies don't all attract the top tech talent. They don't all have enormous technical budgets. They don't all have company culture conducive to good engineering practices. So when these companies hand over a piece of their business to an algorithm, odds are good they're making uneducated guesses and testing them poorly. If Reddit cannot write an algorithm that functions properly in the first place, nor maintain enough insight into its behavior to know when things go wrong, what chance do all the others have?

We've voiced concerns about the ["filter bubble"](http://www.ted.com/talks/eli_pariser_beware_online_filter_bubbles) that shapes what we see online. But our problems extend beyond the blinders of our past preferences. A world is looming where our lives are not only controlled by algorithms, but where even their creators lack basic visibility into how these algorithms work or if they are behaving as expected.

I'm no King Ludd urging you to smash the looms. Algorithms can do great things. They can produce incredible effectiveness, beauty, or serendipity. But it's time to recognize them not as magic, but as tools that do good or harm dependent on our skill in applying them.

One good step is the movement to recognize that [algorithms can be discriminatory](https://www.propublica.org/article/when-big-data-becomes-bad-data). It is important we establish that *an algorithm is discriminatory if its results are discriminatory*. This pushes responsibility back on to the administrator of the algorithm, and recognizes that they are not cleared of fault simply because they never thought to check.

Our legal system is also working through the question of [legal responsibility for algorithmic market manipulation](http://www.newyorker.com/business/currency/when-bots-collude). The need to show "intent" in price-fixing is ripe for exploitation—a dishonest capitalist can provide a seemingly-innocuous algorithm that just happens to converge on a certain behavior over time that just happens to produce unfairly advantageous market conditions, all without the capitalist take any overt action. Hopefully we can land on a stronger definition that doesn't let the owner off the hook just because the algorithm did the dirty work for them.

In the end, maybe the simplest way to think about our algorithms is like our pets. Yes, they respond to their environment and make decisions independently. But the owner is ultimately responsible for their behavior. When you adopt a dog you accept responsibility for properly feeding, housing, and training it, and you implicitly accept that failure to perform these duties would leave you legally liable. Let's do the same for algorithms. You want one, you better care for it properly, or I'll call Algorithm Control on you and get that thing carted off to a shelter.

Further reading: [The "digital star chamber"](http://aeon.co/magazine/technology/judge-jury-and-executioner-the-unaccountable-algorithm/) by Frank Pasquale.

[^1]: Though frankly, maybe they could start being nicer to outsiders who come to them with bug reports. Their track record at this point doesn't really justify rudeness.

[^2]: This is majorly to their credit, despite my other gripes.

[^3]: If you want a top example of an important company with a staggering level of technical incompetence, look no further than Twitter. Twitter, who inadvertently coined the phrase "fail whale". Twitter, who doesn't understand hyperlinks. Twitter, who is still convinced that [I am a small business instead of a person](https://twitter.com/iangreenleaf/status/566479506039246848). When they build an algorithm to control your entire Twitter experience, how confident do you feel that they'll get it right?

[^4]: I've chosen examples that you might consider mundane because I think the mundane is plenty important. But if you need to feel more alarmed, companies are also eager to start using algorithms with serious consequences like [deciding who gets a bank loan](https://www.newscientist.com/article/mg22630182-400-your-smartphones-secrets-could-help-you-bag-a-bank-loan/).
