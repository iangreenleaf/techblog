---
title: Unix Fortunes by Nietzsche
date: 2015-02-25
---

`fortune` is a venerable Unix utility with a simple purpose.
You call it and it returns a random quotation picked from a set of files.
You can set this up to run when a terminal is opened, and this way you get a nice quote-of-the-day thing.
`fortune` ships with virtually all Linux distributions.
There's just one problem: the default quote databases that ship with `fortune`, well, they stink.

Unix `fortune` is an intriguing window into the earlier days of the Internet, when neckbeards were still the dominant social group and BBS was still the dominant mode of communication.
It is, unfortunately, also a reminder that casual sexism on the Internet didn't start with Twitter.
The quotes in the `fortune` databases are largely unchanged since the days when the Internet was a bunch of pasty white guys snickering over dirty jokes in chat rooms.
It's not just that much of the content is sexist (or racist) enough to be offensive; it's that it's not even funny-offensive.
It's the kind of content that derives all its value from being transgressive, and stripped of that, becomes banal.

Of course, you can avoid the databases of raunchy humor in `fortune`.
Then what you're left with is an endless stream of barely-amusing Larry Wall quotes, and a tiresome flood of atheist dogma that truly rivals [/r/atheism](http://www.reddit.com/r/atheism) in obnoxiousness[^1].

What I'm saying is `fortune` needs some new content.

Where to get some?
Sure, I could troll Wikiquote or one of the many other quote-on-demand services, but I find that people who go looking for quotes to compile almost always have what I find to be terrible taste[^2].
Instead, what if I were to find some content written by one of the most iconoclastic philosophers in history?
One who produced several collections of aphorisms, a format perfectly suited to `fortune`?
One with a *glorious* mustache?

![Photo of Friedrich Nietzsche](/images/unix-fortunes-by-nietzsche/nietzsche.jpg)\


Yes, I very much want to be greeted by a Friedrich Nietzsche aphorism every day when I open my terminal.
That is what I want.

## Implementation ##

Luckily, `fortune` can be pointed at new database files from which to select a quote.
The format of these files is quite simple: they are plain text, usually normalized to 80 columns wide, and each entry is followed by a `%` character alone on a line.
And each of these files must be accompanied by a second file with a `.dat` extension.
This second file is a binary blob created with the `strfile` utility, used to help with random access.

I found a number of Nietzsche's works available electronically and under the public domain[^3], which was perfect for my purposes.
I had hoped to build a workflow to automatically parse these files into a suitable format, but the variability of the formatting meant it was far easier for me to tweak each book manually with regular expressions and Vim.

## Usage ##

I now have glorious Nietzsche fortunes on my command line, but what good would all this work be if I didn't share it with the world?
Thus I have created [a GitHub repository](https://github.com/iangreenleaf/nietzsche) with everything you need to get your own Nietzsche fortunes.

1. Either clone the repository with Git or [download the zip file here](https://github.com/iangreenleaf/nietzsche/archive/master.zip).
2. You can now point `fortune` at the data in this project:

        fortune -s -n 600 this_project/fortune

3. And of course, it wouldn't be quite the same if you didn't have your fortune delivered to you by a talking ASCII cow (or in my case, a dinosaur):

        cowsay -W 70 -f stegosaurus $(fortune -s -n 600 this_project/fortune)

Enjoy.
I know I will.

![Terminal screenshot of Unix fortune plus cowsay quoting Nietzsche](/images/unix-fortunes-by-nietzsche/terminal.png)\


[^1]: Internet atheists are an impressive group.
      Who else could take a subculture formed in opposition to orthodoxy, and turn it into a community rife with leader-worship and an irrepresible need to force your personal opinions on everyone else?
      N.B. I am more-or-less an atheist, and yet I absolutely cannot *stand* these people.
[^2]: Yes yes, I realize that *I am now one of those people*, and I fully appreciate the irony.
      Thanks for checking.
[^3]: Most of the books came from the wonderful and important [Project Gutenberg](http://www.gutenberg.org/ebooks/author/779), with one additional work from [Nietzsche's Features](http://turn.to/nietzsche).
