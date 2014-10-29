---
title: If you're having Ruby environment problems, I feel bad for you son
date: 2014-10-29
---

## The short version ##

If you are working on a Ruby application and trying to run something on the command line and getting an error message you don't understand, you might be having a problem with your Ruby environment.
The first thing you should do is run the command prepended by `bundle exec`.
So if you were originally trying to run:

```sh
rspec --seed=123 spec/awesome_spec.rb
```

Just run this:

```sh
bundle exec rspec --seed=123 spec/awesome_spec.rb
```

Did that work?
Great.
You now have a workaround, and you know that your problem is a Ruby environment problem.

Didn't work?
If you are using rbenv[^1], there are two things to try.
First, run `rbenv rehash` and then try your command again:

```sh
rbenv rehash
bundle exec rspec --seed=123 spec/awesome_spec.rb
```

If it still doesn't work, try prepending an `rbenv exec` to your command, *still keeping* the `bundle_exec`:

```sh
rbenv exec bundle exec rspec --seed=123 spec/awesome_spec.rb
```

Yes, this is silly, but it's also a great way to troubleshoot.
If you've tried both of these steps and you're still getting the same error, your problem is probably something other than a Ruby environment problem.
If one of these steps fixed the problem, you know it was a Ruby environment problem and you can take steps to fix it permanently.

## A permanent fix ##

Nobody wants to prepend all this stuff every time you run a command.
Nobody.
It boggles my mind that anyone is even *willing* to live that way.
Dijkstra chiseled the first NAND gate out of the bleeding flesh of his own bicep so that you and I might live in a better world, and you would let his sacrifice go to waste?
Let's fix this once and for all.

### For Bundler problems ###

Was your problem solved by using `bundle exec`?
There are two parts to this.
First, open your `~/.bashrc` or `~/.bash_profile`, whichever you prefer[^2].
Add this line, probably somewhere near the bottom:

```
export PATH=./bin:$PATH
```

Now, `cd` to your Ruby project and run this command:

```
bundle install --binstubs
```

This will create a `bin` directory with some files in it.
Commit this directory to your version control system.

Now open a new shell and try running your command again without the extra stuff on the front.
It should work.

### For rbenv problems ###

Did `rbenv rehash` solve your problem?
You need to run this command just once any time you install a new gem it hasn't seen before that has an executable part (such as `rake`, `rspec`, `pry`, etc).
You won't find yourself needing to do this very often, just remember it the next time you hit the same problem.

Did you have to add `rbenv exec` before your problems went away?
Add the following line to your `~/.bashrc` or `~/.bash_profile`, but make sure to add it **before** the `PATH` line we added for Bundler:

```
eval "$(rbenv init -)"
```

Now open a new shell and try running your command again without the extra stuff on the front.
It should work.

## The long version ##

If you're the impatient type, you are no longer reading this because you left as soon as it started working.
Enjoy!

If you're the curious/suspicious type, you might want to know what exactly these magical incantations mean and why running them solved your problem.
Read on!

All of the problems we've covered boil down to the issue of *paths*.
Say you run something on your command-line, like this:

```
foobar --baz
```

Your shell doesn't actually know what you want when you ask for `foobar`.
But it has a list of paths that it will search until it finds a matching executable file to run.
So it will try a list like the following until it finds something that exists:

```
/usr/local/sbin/foobar
/usr/local/bin/foobar
/usr/bin/foobar
/sbin/foobar
/usr/sbin/foobar
```

Your shell stores this list of paths in the `PATH` variable.
You can see what your `PATH` currently looks like by running this:

```
echo $PATH
```

That will print out a bunch of directory paths separated by `:`s.
This is your `PATH`, and it's the only way your shell knows how to run anything you ask for.

Now, most of the executables you run from the command line, like `echo` or `ls`, are installed in standard locations that your shell already knows about.
And when you use the default version of Ruby installed on your system, the executables from Ruby and its installed gems, such as `ruby` and `rspec`, are also available in a common path.

One of the most important things that Bundler does is let us install specific versions of gems for a given application -- even if we have several applications on one machine that use different versions of the same gem, each application will get the correct version.
This is a wonderful thing, but it introduces a new problem: when you ask the command line to run `rspec`, which version of the RSpec gem should it run?
Bundler can look at the `Gemfile` and determine which version is desired, but your shell doesn't know anything about Rubygems - all it has is its paths.

So Bundler does the best available thing - it puts a simple executable "stub" inside the project's hierarchy, in a place that can be included in the shell's paths.
This is what happens when you run `bundle install --binstubs` -- Bundler looks at your Gemfile and builds a stub file for all the executable bits from those gems.
These stubs are named to mimic the executables, like `bin/rspec` and `bin/rake`.
Each stub is in charge of activating Bundler, determining which version of the gem should be run, and then passing along all the arguments from the command line to the real executable from the gem.

With rbenv, we have the same problem at a greater scale.
All its special versions of Ruby are kept in a special directory like `~/.rbenv/versions`.
This is great because it doesn't cause any conflicts with system packages, but it does leave your shell in another quandary.
The shell doesn't know which version of Ruby you want to be using at the moment, so it can't even begin to search for the correct Ruby executables.

The solution for rbenv is similar to Bundler's: when you run `rbenv rehash`, it creates some "shim" files in `~/.rbenv/shims` named again to mimic the executables.
These find the correct version of Ruby, then pass the entire command through to be handled by that Ruby.
Because it's also in charge of Ruby as a whole, rbenv also maintains shim files for built-in executables like `ruby` and `gem`.

Now that we have our stubs and shims, the only thing that remains is to point our shell towards them.
This is where we come back to the `$PATH` variable.
Besides storing all the default paths, this variable can be modified by the user to add custom paths to search for executables.
That's exactly what we do: we add `./bin` and `~/.rbenv/shims` to the `$PATH` (importantly, we add these near the *front* of the paths list).
This way, when we run something like `rspec` in our shell, the shell starts looking through the paths in order, and the first thing it finds is `./bin/rspec` -- our Bundler stub.
So it runs that, and Bundler and rbenv take care of the rest[^3].

## I got 99 problems, but a Ruby environment ain't one ##

Congratulations!
If you've made it this far, not only is your Ruby environment working flawlessly, but you also understand what it is that makes it work.
You've done good work today.


[^1]: If you are using rvm, there is probably an equivalent step you should take to ensure that the command is running with the right set of paths, but I don't use rvm much so I don't know what it is.
      If someone tells me, I'll update this article.
[^2]: If you don't have a preference already, use `.bashrc`.
      It's marginally more correct.
[^3]: One more subtlety: when you run a gem executable like `rspec`, it actually needs help from both Bundler *and* rbenv -- rbenv to find the correct Ruby version and Bundler to find the correct gem version.
      How do they cooperate?
      Well, by relying properly on Unix conventions, each package is able to do the right thing without explicitly knowing about the existence of the other.
      The only thing they need from us is to have the directories added to `$PATH` in the right order.
      When the shell searches for `rspec` the first thing it finds is `./bin/rspec`, the Bundler stub, so it executes that.
      That file contains a [sh-bang](http://en.wikipedia.org/wiki/Shebang_%28Unix%29) line instructing the shell that it is to be executed using the `ruby` program.
      So the shell searches for `ruby`, and this time it finds `~/.rbenv/shims/ruby`.
      It invokes the `ruby` shim, which selects the correct version of Ruby and uses that to run the rest of the Bundler stub, which finds and runs the correct version of the gem executable.
      Alternate explanation: Unix Magic!
