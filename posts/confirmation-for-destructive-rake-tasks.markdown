---
title: Confirmation for destructive Rake tasks
date: 2015-02-02
---

Lately I've been building some Rake tasks that do destructive things. I need them, and I need them to be destructive. But I also need to be very sure they don't run at the wrong time.

This is part of my sysadmin philosophy: automate everything that's possible to automate, and double- or triple-guard everything else against my own presumed and eventual incompetence.

```ruby
# lib/tasks/my_task.rb
desc 'Delete stuff that I might still want (careful!)'
task :reset_data => :environment do
  # Delete all the things
end
```

Yikes. One misplaced `rake reset_data` and I'm in trouble.

It's not enough to let allow destruction to proceed when the command is entered on the command line. Shell history can be your own worst enemy. Tab completion can stab you in the back. Distraction and urgency can gang up on you. And it's certainly not enough to leave a note in the task descriptions advising caution. Who reads those descriptions anyways?

No, these tasks need a confirmation; an "are you sure?". They need to stop me and demand my attention and say "Hey, look at what you just entered and make absolutely certain that's what you meant." And I need an easy way to do this for several different Rake tasks—so easy that I can't possibly get lazy and leave it off, and so foolproof that I can't screw it up.

Let's get started.

```ruby
class Nope < RuntimeError; end
```

This is my favorite line. Heck, this is my favorite line of Ruby I've written in *months*.

```ruby
# Rakefile
task :destructive do
  puts "This task is destructive! Are you sure you want to continue? [y/N]"
  input = STDIN.gets.chomp
  raise Nope unless input.downcase == "y"
end
```

This helper task prompts for input[^1], and insists on seeing a "y" before it continues. Why the `raise`? Well, Rake tasks aren't actually methods, so they freak out if you try to `return`. And normally a `next` will exit the task, but in this case we want to exit not only this task, but also the one that called it. `next` would pass execution right to the next task, which is exactly what we do not want.

Raising an error is fighting dirty, but it's an effective way to end Rake's execution.

```ruby
# lib/tasks/my_task.rb
desc 'Delete stuff that I might still want (careful!)'
task :reset => [:destructive, :environment] do
  # Delete all the things
end
```

Back to our original task, with one minor modification. The prompting is all taken care of by adding `:destructive` to the dependencies. This ensures that our helper will be run first, and will bail out of everything if it doesn't get a confirmation. The task itself can get right down to the business of whatever destruction it's responsible for.

Fair warning: this technique slightly perverts the semantics of the Rake system. Some people might not like it on ideological grounds, which is fine. There are other ways to accomplish the same functionality. But in my book, nothing beats this for simplicity.

[^1]: Confused by the `[y/N]`? This is a Unix convention when asking for input on the command line. It shows what characters are valid options to select, so if we had more options it might look something like `[y/N/s/a]`. The capitalized character indicates a default option—if you hit enter without entering input, this is the option that will be selected. The actual case should not matter, thus we use `downcase` before comparing to accept either "y" or "Y".
