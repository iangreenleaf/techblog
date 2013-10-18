---
title: RSS the least wrong way
comments: |
  ## Some sources ##
  * https://github.com/dpk/diveintomark/blob/master/archive-html/0139b3aa54c3fd762645ac5dfe51d0ebb12297b5.html
  * http://blogs.msdn.com/b/rssteam/archive/2005/08/02/publishersguide.aspx
  * http://weblog.philringnalda.com/2005/04/15/what-feeds-should-firefox-discover
  * http://weblog.philringnalda.com/2005/11/19/the-checkered-history-of-rel
  * http://tools.ietf.org/html/draft-ietf-atompub-autodiscovery-01
  
  # Testing feeds
  cat feeds | while read line; do echo "$line"; curl -I "$line" | grep '^Content-Type'; done 2>/dev/null
  
  # Testing SmartFeed:
  export UA='Opera/7.0 (Windows NT 5.1; U)  [en]'
  curl 'http://feeds.feedburner.com/feedburner/EGam111111111111' -H "User-Agent: $UA" -H 'Accept: application/rss+xml' 2>/dev/null | less
---
*Disclaimer: Despite the title, I will discuss both RSS and Atom formats. A more accurate title would be "Content Syndication the least wrong way", but that is just not as snappy.*

Generating a static site? Building your own blog engine? Or otherwise need to configure your own content syndication feed? You may have noticed that RSS is a complete shitshow. RSS grew in the messy organic way that much of the web grew, and was standardized too little and too late, like much of the web. People can't even agree what the acronym RSS stands for. Most activity on the standard itself stopped years ago, and as a result so did discussion of it. Trying to serve your own feed comes with a number of small pitfalls, and searching for advice on the subject yields a slew of contradicting, badly outdated articles. The [top hit](http://www.petefreitag.com/item/381.cfm) searching for "rss content type" is *8 years old*. That's 218 in Internet years.

Let me guide you through this mess. Together we will seek simple solutions that work in today's world. Of course, if you're not interested in the details, you can skip to the end for my [recommended best practices](#in-summary).

## Generating the feed ##

A feed is nothing more than a simple XML file that lists entries. Whenever a new entry is added, the file is updated. Generating this file is outside the scope of this post. Hopefully you are using a tool that will do it for you. If not, you may need to look at [some examples](http://www.ibm.com/developerworks/library/x-atom10/) or dig into [the spec](http://tools.ietf.org/html/rfc4287).

The important thing is that once you have your feed, you use [the official validator](http://validator.w3.org/feed/) to ensure that it is a valid feed format. You should only be generating Atom 1.0 or RSS 2.0. There is no reason to use any older versions of the specs.

## Atom vs. RSS ##

Once upon a time, a syndication format arose, and it was called RSS. Then people got annoyed because RSS had some shortcomings, and created a better-thought-out standard called Atom. You will need to make a choice about which format you serve. The good news is it doesn't matter much. Both are perfectly sufficient for the needs of a simple blog or other standard content stream, and as we will see later, both are widely used and widely supported. No modern feed reader will handle one of these formats but not the other.

If your tool only generates one format or the other, your decision is made for you.

Otherwise, choose one. I recommend Atom. It was built with a spec from the beginning, so the *right* implementation is also the implementation that *works*. RSS has existed longer, so in theory some tools could lack Atom support, but in practice this isn't likely. There are echoes of descriptivism vs. prescriptivism here, and as usual I come down cautiously on the prescriptivist side. Atom is conceptually better, so barring any hurdles to its acceptance, I say we use Atom.

## Content type ##

You must serve your feed with a content type that identifies it as a feed. It's fairly important to get this right, or at least something approximating right. This ensures that browsers and feed readers recognize it as a feed and behave appropriately.

### Atom ###

Your content type should be `application/atom+xml`. This is the most correct, and will work well with everything. Using `text/xml` is technically acceptable but too vague to be a great idea.

### RSS ###

Your content type should be `text/xml`.

Given what I *just* said about Atom feeds, it seems like `application/rss+xml` would be a better idea. However, this [is not a registered MIME type](http://weblog.philringnalda.com/2005/04/15/what-feeds-should-firefox-discover), and while it will probably work, you still should not try it. RSS suffered greatly at the hands of those who loved it, and this content-type mess is one of the greatest legacies of that. Other content types used for RSS in the past have included `application/xml`, `text/html`, and `text/rss+xml`, which are all wrong and should be avoided.

### Getting the header right ###

You can easily use `curl` to check that your feed is being served with the correct content type:

```
$ curl -I technotes.iangreenleaf.com/feed.xml
```

Look through the headers in the response for this:

```
Content-Type: application/atom+xml
```

If you are serving your blog from Amazon S3, it will guess (and guess wrong) about the content type it should serve. Give it a hint when uploading the file to prevent this behavior. For example, I use the `s3cmd` tool and pass it an extra option[^7] like so:

```
s3cmd put --mime-type=application/atom+xml _site/feed.xml s3://technotes.iangreenleaf.com
```

## File names ##

Functionally, it doesn't matter at all what you name the files you generate. If they are served up with the correct content type, the file name is irrelevant (though some platforms, like S3, use the filename to guess at the content type if it isn't set explicitly). I suggest you go with something like `feed.xml` or `rss.xml`/`atom.xml`. This is not incorrect, and should result in roughly-correct behavior from text editors, etc.

## Auto-discovery ##

A nifty feature that you definitely want to provide is RSS discovery. Applications, when viewing a page on your site, can automatically find feed links and make them available in some special way. For example, I have an RSS button on my toolbar. If a page I'm on offers a feed, the icon will light up, and clicking on it will open the feed in my preferred feed reader.

![RSS icon in browser bar](/images/2013-10-17-rss-the-least-wrong-way/rss_icon.png)\ 

No need to search around the page for the link to the feed, my browser has found it for me!

The key to enabling RSS discovery is adding a `<link>` element inside your `<head>`. Here is an Atom feed:

```html
<link rel="alternate" type="application/atom+xml" href="/feed.xml" title="Atom Feed" />
```

And an RSS feed:

```html
<link rel="alternate" type="application/rss+xml" title="RSS Feed" href="/feed.xml" />
```

The `rel` attribute is very important. It must contain `alternate` and only `alternate`, or some clients will stumble.

The `type` attribute is also important. It must be either `application/atom+xml` or `application/rss+xml`. "But wait," you say, "why are we using `application/rss+xml` when you just told me that's not a valid content type?" You're so cute with your questions. But seriously, don't use it in the content type header, do use it here, stop asking questions and no one will get hurt.

The `title` attribute must exist, but may contain whatever you like. Just name it something descriptive.

It's also possible to offer multiple feeds from one page by using more than one `<link>`:

```html
<link rel="alternate" type="application/atom+xml" href="/feed.xml" title="Ian's Blog Feed" />
<link rel="alternate" type="application/atom+xml" href="./comments.xml" title='Comments on "This Post"' />
```

If you do this, users will be shown a selection screen to pick the feed they want.

![RSS feed selection menu](/images/2013-10-17-rss-the-least-wrong-way/rss_selection.png)\ 

The `title` attribute is what's shown here, so make sure you've picked good names!

You can even provide links to both an Atom feed *and* an RSS feed for the same content, and let users choose which format to use. However, I recommend *against* doing this - more on that later.

## The great feed survey ##

Dealing with a poorly-specified area of the web with a spotty history comes with its share of uncertainty. Several of the lessons in this post were learned the hard way after launching this blog and receiving bug reports. Questions of format choices and content types boil down to which combination is going to work correctly for almost everyone, almost all the time. With most of the literature on this subject badly out of date, it's hard to determine which compatibility issues still occur and which are effectively moot.

I decided the best way to find out which practices were safe would be to check very popular feeds and see what they did. If something doesn't work for a significant portion of the web population, I assume these people will have heard about it and taken corrective action. To that end, I conducted an unscientific survey of feeds published by popular blogging platforms and notable citizens of the web. I checked only the feeds made available by autodiscovery.

| Source | Format | Content Type | Autodiscovery |
|--------|--------|--------------|---------------|
| [Blogger (Atom)](http://googleblog.blogspot.com/feeds/posts/default) | Atom 1.0 | application/atom+xml; charset=UTF-8 | `<link rel="alternate" type="application/atom+xml" title="Official Blog - Atom" href="http://googleblog.blogspot.com/feeds/posts/default" />` |
| [Blogger (RSS)](http://googleblog.blogspot.com/feeds/posts/default?alt=rss) | RSS 2.0 | application/rss+xml; charset=UTF-8 | `<link rel="alternate" type="application/rss+xml" title="Official Blog - RSS" href="http://googleblog.blogspot.com/feeds/posts/default?alt=rss" />` |
| [Tumblr](http://staff.tumblr.com/rss) | RSS 2.0 | text/xml; charset=utf-8 | `<link rel="alternate" type="application/rss+xml" title="RSS" href="http://staff.tumblr.com/rss"/>` |
| [Wordpress.com](http://en.blog.wordpress.com/feed/) | RSS 2.0 | text/xml; charset=UTF-8 | `<link rel="alternate" type="application/rss+xml" title="WordPress.com News" href="http://en.blog.wordpress.com/feed/" />` |
| [Feedburner Status](http://feeds.feedburner.com/feedburnerstatus?format=xml) | Atom 1.0 | text/xml; charset=UTF-8 | |
| [Jekyll](http://jekyllrb.com/feed.xml) | RSS 2.0 | text/xml | `<link rel="alternate" type="application/rss+xml" title="Jekyll • Simple, blog-aware, static sites - Feed" href="/feed.xml" />` |
| [Octopress](http://octopress.org/atom.xml) | Atom 1.0 | text/xml | `<link href="/atom.xml" rel="alternate" title="Octopress" type="application/atom+xml">` |
| [Jeffrey Zeldman](http://www.zeldman.com/feed/) | RSS 2.0 | text/html | `<link rel="alternate" type="application/rss+xml" title="Jeffrey Zeldman Presents The Daily Report RSS Feed. Designing with web standards." href="/rss/" />` |
| [Eric Meyer](http://meyerweb.com/index.php?feed=rss2&scope=full) | RSS 2.0 | text/html | `<link rel="alternate" type="application/rss+xml" title="Thoughts From Eric" href="/eric/thoughts/rss2/full" />`[^4] |
| [Daring Fireball / John Gruber](http://daringfireball.net/index.xml)[^2] | Atom 1.0 | application/atom+xml | `<link rel="alternate" type="application/atom+xml" href="/index.xml" />` |
| [A List Apart](http://feeds.feedburner.com/alistapart/abridged) | RSS 2.0 | text/xml; charset=UTF-8 | `<link rel="alternate" type="application/rss+xml" title="A List Apart: The Full Feed" href="/site/rss" />` |
| [24 Ways](http://feeds.feedburner.com/24ways) | RSS 2.0 | text/xml; charset=UTF-8 | `<link rel="alternate" type="application/rss+xml" title="rss" href="http://feeds.feedburner.com/24ways" />  ` |
| [The W3 Consortium](http://www.w3.org/blog/news/feed)[^3] | RSS 2.0 | text/html | `<link rel="alternate" type="application/atom+xml" title="W3C News" href="/News/atom.xml" />`[^5] |

### RSS vs. Atom ###

RSS 2.0 is the clear favorite. Still, several important feeds use Atom 1.0, notably the Feedburner status feed and Daring Fireball. This leads me to conclude that either format is perfectly acceptable in today's web.

### Content types ###

There's little consensus here. For Atom feeds, `text/xml` makes an appearance, but several feeds use the most correct `application/atom+xml`.

In the RSS feeds, most stick with the safe bet of `text/xml`. I was surprised to discover that `text/html` is served by web evangelists Jeffrey Zeldman and Eric Meyer, and even more so that is is served by the official W3C news feed. Unless I am mistaken, this content type is just flat-out wrong and should not be used. I wonder if there is a rationale behind their decisions.

### Autodiscovery ###

Every feed surveyed supports autodiscovery. Notably, *none* of the feeds except Blogger offered a choice of both RSS and Atom in the autodiscovery tags. This is good UI: presenting users with a choice between two functionally interchangeable formats is unhelpful at best and badly confusing at worst. Given the widespread compatibility of both RSS and Atom, you should pick one and serve that by default.

This admonishment is directed at me as well. Until performing this survey, I had been offering both formats through autodiscovery (in the name of user choice). Upon realizing that I was in a serious minority, I reevaluated and realized that I had made a poor decision. From now on I will be pointing to only one format. I will probably continue to serve the other feed format, but will not be advertising it.

## In summary ##

Does your head hurt? Let's distill these discoveries down to a small set of best practices. Here's a mildly opinionated guide to serving a successful content feed:

1. Use Atom 1.0.
2. Generate a file named `feed.xml`. Serve it with the content type `application/atom+xml`.
3. Put this in the `<head>` element of your site:
   ```
   <link rel="alternate" type="application/atom+xml" href="/feed.xml" title="My Blog Feed" />
   ```
   Change only the `title`.
4. Try to forget all that you have witnessed here today.

[^1]: Feedburner offers an optional service for feed publishing called SmartFeed that claims to serve the best format (RSS or Atom) to each client. In practice, they serve Atom feeds by default, with a user-agent blacklist of clients that receive RSS instead. In practice, few Feedburner feeds seem to be using this service. The official Feedburner status feed and the official Google news feed both appear to have this option disabled, and always serve Atom.

[^2]: Daring Fireball actually respects the `Accept` header, and returns `406 Not Acceptable` when given `Accept: application/rss+xml`. I'm impressed.

[^3]: During the drafting of this article, W3C pushed a new site design and altered their news feed. The old feed was found at `http://www.w3.org/News/atom.xml`, and returned an Atom feed with `Content-Type: application/xml; qs=0.9`. An atom feed is still available, but is not visible to autodiscovery.

[^4]: Eric Meyer's final feed URL is hidden behind two redirects. `http://meyerweb.com/eric/thoughts/rss2/full` -> `http://meyerweb.com/eric/thoughts/feed/full/` -> `http://meyerweb.com/index.php?feed=rss2&scope=full`. o.O

[^5]: The W3 site still lists an Atom feed for autodiscovery, but this URL redirects to the new RSS feed (even though a new Atom feed is available at a different URL). This clearly seems like a mistake. I contacted the site maintainers and they are [planning to fix it](http://lists.w3.org/Archives/Public/site-comments/2013Oct/0006.html).

[^7]: If you don't have the very latest release of `s3cmd`, the story gets even more complicated. In older versions, the `guess_mime_type` option, if enabled, will actually override the one you specify (ugh). You'll want to turn that option off in your s3cmd config. Here's my bash hack to temporarily do so while uploading the file:

    ```sh
    cat ~/.s3cfg | sed 's/\(guess_mime_type.*\)True/\1False/' > .tmpconfig
    s3cmd put --mime-type=application/atom+xml _site/feed.xml s3://technotes.iangreenleaf.com
    rm .tmpconfig
    ```
