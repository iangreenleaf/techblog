---
title: How to use Rails migrations and schema
---

If you've worked on a serious Rails project, chances are you've been told at some point to [check in your schema](http://webcache.googleusercontent.com/search?q=cache:pOhqkWFMkx8J:www.saturnflyer.com/blog/jim/2010/09/14/always-check-in-schema-rb/+&cd=1&hl=en&ct=clnk&gl=us&client=firefox-a). However, the reasons *why* we do this are often glossed over by long-time Rails developers who know the history of the feature, leaving newcomers frustrated by a habit that seems confusing or redundant.

To understand the Rails database management plan, you'll need to keep in mind the needs of two different kinds of people who will be consuming your database changes: those with an **existing environment** and those setting up a **new environment**.

The **existing environment** might be your local development environment, or a colleague's. It might be your production machine. It might be someone to whom you are distributing code. All these have something in common: they are already using your application with an existing database. These environments need a way to *upgrade* the database to the newest version. This is what migrations do wonderfully well.

The **new environment** might be someone setting up your application for the first time. It might be the developer you just hired getting her machine up and running. It might be you, a month from now, when you've massively screwed up your existing database and want to drop it and start fresh. Be certain of one thing: sooner or later, a new environment *will* come along, even if one doesn't exist right this moment.

The new environment doesn't need anything upgraded; it needs to create a new database that mirrors your latest. It may also need to seed the database with some defaults or dummy data. Migrations do neither of these things well.

In ages past, we *did* use migrations for new environments. The idea was that you would run all the migrations, in order, and by the end of the chain you would have the latest database structure. While this works in theory, it has fallen out of favor with the Rails community because in practice, it sucks.

 1. It's slow. As your application grows, you probably first create a few small tables, then add columns to them bit by bit as needed. Then they get too large and you move some columns to a new associated table. Then your priorities change and you delete some columns. Then you add some more columns. Then you have to change the type of one of your columns from `varchar` to `text`.

    Running all the migrations means that you have to replay all of these migrations, one at a time, as they originally happened. This is pretty wasteful when you think about the simple `CREATE TABLE` commands that would achieve the same result. This isn't merely a theoretical problem either -- loading from schema is measured in seconds, while running the full migration chain for even a modestly mature application will almost certainly be measured in minutes.

 2. It's fragile. So, *so* fragile. Running the full chain of migrations means that every migration must continue to function, forever. The classic pitfall that almost every Rails project encountered was using classes in migrations. We would pull in a class to make use of the ActiveRecord queries, or use it to manipulate data that needed to be changed. This was all well and good at the time, but months later we would rename the method, or delete the class, and suddenly the migration would be broken. Our code had changed, but the migration had not.

    Worse, this is just the most common failure mode for migrations; it's certainly not the *only* one. Did you use `Time.now` to set a default timestamp? That was a bad plan. Using a Rails 2 method but you've since upgraded to Rails 3? Oops. Updating existing data with an SQL query that fails if the table is empty? *Tsk.*

    It's possible to protect against *some* of these failures by defining all classes within the migration rather than autoloading them from the rest of your Rails app, and copy-pasting any needed methods. However, this is a nuisance to follow, difficult to enforce, and easy to forget. Running a large migration suite in sequence is a messy, slow, error-prone process, and making it less so means spending time on ceremony that doesn't actually improve anything -- the worst kind of maintenance. Migrations have no test coverage and are not loaded by the server process. Migration upkeep does not happen because migrations are invisible until the moment someone wants to run them, which happens to be the worst time to discover that they are broken.

So while migrations are the right tool for **existing** environments, they're not a good option for **new** environments. Thankfully, the Rails community has settled on a better solution: check in your `schema.rb`. When a new developer wants their own database, they simply load the structure specified in your schema by running `rake db:setup` (or `rake db:schema:load`). No messy chain of migrations, just a direct creation of the newest database tables. This method is faster, cleaner, and avoids all the ugly failures that can crop up in an extensive migration chain.

What seems like two different solutions is actually two parts of the same solution. The schema file represents *the current state of the database*. The migrations explain *how to reach that state* from somewhere else. I like to check in a new migration and the changes it causes to `schema.rb` in the same commit.

Common objections:

 * **But I use migrations to add data to the tables!**

    Don't. This is one of the most pernicious and difficult-to-fix causes of the fragility issues in migrations. The proper place for this kind of data is in `db/seeds.rb`. Seed data will be loaded when someone runs `rake db:setup` (or `rake db:seed`), so it will show up for someone setting up their db from scratch. If it's imperative that this seed data is pushed out to existing environments as well, go ahead and add it to your migration, but realize that this is *in addition to*, not *instead of* a clean, complete set of seeds.

 * **But it's a machine-generated file!**

    This is true, but for once this is a generated file you want to check in. The format of `schema.rb` is very clean and human-readable, so changes to it are easy to understand and limited to a small number of lines. Merge conflicts are rare unless you are simultaneously modifying the same database table as someone else, which is a dodgy proposition anyhow. And Rails automatically updates `schema.rb` every time you migrate, so it's hard to forget to commit your changes.

 * **But we're having trouble getting all the developers' schemas to agree!**

    Some ugly problems can crop up when you start checking in `schema.rb` on a project where it was previously not checked in. Different developers might have slightly different existing databases. One might have an older default date in a timestamp column; another might have a different `VARCHAR` length; another might be missing a `:null => false` on a column. You'll discover all these inconsistencies when a developer runs the latest migrations and ends up with uncommitted changes to his schema.rb. If he commits them, the first developer will encounter uncommitted changes the next time *she* runs a migration. Their competing schemas are battling for dominance through your source control system.

    This situation sucks, no doubt about it. However, don't let it dissuade you from making the switch! This is a convincing demonstration of how many things can go wrong with migration chains -- your databases have been drifting apart and no one even realized it! You're going to need to do some grunt work on this one. Track down the offending developers one by one and insist that they come into compliance. Often this means backing up their data with `mysqldump`, running `rake db:drop && rake db:setup`, then re-importing the data. If that's not enough you might have to handcraft some `ALTER TABLE` statements to fix the worst of the problems. Bite the bullet and make it happen. Remember, the alternative is leaving your developers' databases in a known broken state.
