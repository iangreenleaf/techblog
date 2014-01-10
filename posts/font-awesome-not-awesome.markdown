---
title: Font Awesome? Not awesome at all
date: 2014-01-10
---

The hottest new thing in our increasingly fad-obsessed web development world is icon fonts. The most popular one of these is [FontAwesome](http://fortawesome.github.com/Font-Awesome/), which found the magic combination of providing a nice icon set and piggybacking on the ultimate web design fad, Bootstrap. Yes, FontAwesome is a nicely-designed icon set, and I have nothing against it personally, it's just that FontAwesome and every other icon font are built on a *stupid fucking idea*.

<div class="image-container">
  <svg width="192" height="192" class="image">
    <image xlink:href="/images/font-awesome-not-awesome/poop.svg" src="/images/font-awesome-not-awesome/poop.png" width="192" height="192"/>
  </svg>
  <span class="image-attr">[^1]</span>
</div>

We're two weeks into a new project and our designers are adding extra markup to just one of the elements in a navigation list so they can apply a CSS rotate transform, because they need an ellipsis icon which FontAwesome doesn't fucking provide, so they're turning one of the "list" icons on its side instead so it looks like an ellipsis if you squint. Now, this is a problem one has with any stock icon set - you inevitably run into situations where the set, no matter how large, is missing that one crucial icon that you need right now. So you face the choice of shoehorning in some icon that doesn't really fit and will definitely confuse your users, or creating your own addition and trying to match the style of the others. However, when you use an icon font your problems have just **doubled** because nobody, anywhere, incorporates editing font faces as an ordinary part of their workflow. How many of your designers know how to use FontForge? Zero? Yeah, I thought so.

Why is everyone so infatuated with FontAwesome? It's because we started designing responsive layouts and realized that managing lots of different sizes of the same image kinda sucks, and then the Retina display came out and everyone shit our pants over how bad everything looked on it. So people started thinking gee, wouldn't it be nice if we could use vector graphics? Infinite resizing without a loss of fidelity, no finicky image sizes to deal with, and often much smaller file sizes to boot. This is a valid observation, which is why **we have a format expressly for vector graphics that works great**. It's called SVG, and it's implemented in all modern browsers, and it's actually *intended* for vector graphics instead of some insane abuse of font faces, for chrissake. SVG is an actual vector graphics format. Icon fonts are an unplanned loophole that provides behavior approximating vector graphics. Let me emphasize that these two are not the same.

Why is it that the idea of icon fonts sounds so familiar? Can you place it? It's because we tried them *20 years ago* when it was called WingDings and it was just as shitty an idea then as it is now. It was a shitty idea because fonts are not a language and it doesn't make any sense to have the letter "Z" represented as a star and crescent. Leaving aside the issue of Unicode's own symbol sets (which at least lay some claim to functioning as a universal language), having your pictures come from little letters that you've made a special font to represent *just doesn't make any sense*.

You can see shades of how little sense this makes reflected in the markup FontAwesome prescribes:

```html
<i class="icon-camera-retro"></i>
```

What's that `<i>` element doing? Is that like 'i' for 'icon'? No, it's fucking not. It's 'i' for 'italic text style', just like it has always been. By not only abusing an HTML element like this, but by choosing one of the most obsolete, non-semantic elements *to* abuse, it almost seems that someone realized the absurdity of what they were doing when they designed this. That would make sense. Icon fonts are the kind of hack you come up with when your project has been hitting roadblocks all week, and on Sunday evening you drink a bunch of Coke and bang out an idea so ridiculous you're a little surprised when it actually works. On Monday you show your coworkers and everyone has a good laugh and a little head-shake of disbelief, and they call you "crazy bastard" endearingly, and you throw a comment in the code stating that "this should probably change" and hope you have time to come back to it before release day. *That* is the kind of advancement that icon fonts are. That would be fine; we've all committed a few outrageous pieces of code in our careers. What's **not** okay is promoting this ugly hack as a real solution, building on top of it, and trying to spread it far and wide across the web. That means all of you; tweeting your tweets and blogging your blogs about "how great this FontAwesome thing is". Icon fonts are an ugly half-solution, and treating them as anything more than that is a sure route to woe, for us and for the rest of the web. Every bit of energy we expend propping up a bad solution like icon fonts is energy we could be putting into using SVG and degrading gracefully in the few relevant browsers that don't support it.

Mark my words: in a few years we'll look back at icon fonts as another stupid detour on a route littered with mistakes like `<marquee>` and table layouts. There is no future for this technology except regret and hurried backpedaling. So think on this: when someone in the future reminisces about the days of icon fonts and asks "can you believe we ever thought those were a good idea?", you don't want to be the one who averts your eyes and, full of shame, mumbles, "No... I really can't."

[^1]: Poop icon designed by [Ricardo Moreira](http://thenounproject.com/skatakila) from the [Noun Project](http://www.thenounproject.com/).
