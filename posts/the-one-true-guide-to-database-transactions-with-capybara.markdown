---
title: The One True Guide to database transactions with Capybara
date: 2015-08-11
---

So you have a Rails app, and you wrote some tests because you're a responsible developer.
You want these tests to run quickly, so you want to use [database transactions] to handle database cleanup.
Yes, really, you do.

Using transactions instead of deletion or truncation is the hugest and easiest performance win you will find in your test suite.
I've seen this change shave off 5 seconds *per test* on a database with a very ordinary number of tables.
Savings of 5 seconds per test, with a modest test suite, can easily equal savings of 30 minutes per test run.
Now multiply that by every developer on your team, every time they need to run the tests and have nothing to do while sitting there waiting for the results.
Yes, you really want to be using transactions.

There's just one problem: you probably wrote some integration tests, because as previously mentioned, you're a responsible developer.
You probably used [Capybara].
And since this is 2015 and JavaScript is unavoidable, you're probably using a JavaScript-enabled driver like [Selenium] or [Webkit].
So you mix these ingredients together and **all hell breaks loose**.

## Why all your tests are broken ##

There are two problems that are teaming up right now to make your life miserable:

1.  Database transactions aren't shared between threads.
    Unfortunately, Capybara needs to use a separate thread to fire up the server that it's going to run against.
    So you've got all your seed data inserted into the database, all wrapped up in a transaction in thread #1.
    But your server is running in thread #2, without access to that transaction, so all it sees is an empty database.
    So you run your test suite and everything fails because all the data is "missing".

    Now, it's possible to fix this problem, which we'll cover below.
    But when you do, you will run your tests again and they will fail *even harder* than before.

2.  Turns out there's a reason that threads don't usually share database connections.
    Trouble arises most often in this scenario: your integration test performs an action, sees the results it was expecting, and passes.
    At this point, control of the test thread returns to your test cleanup, which will proceed to roll back the transaction.

    *However*, the browser thread may not have finished yet.
    It's not at all uncommon to have an AJAX request or two that are still pending even when your test has passed.
    Maybe it's a follow-up action to what your test performed, like refreshing resource attributes.
    Or maybe it's something unrelated, like credentials verification.
    Whatever the content, the result is that this AJAX request hits your test server, which tries to access the database through the same connection that the other thread is trying to use to clean up.

    Databases don't like having multiple concurrent attempts to use a connection.
    When this happens, MySQL will give vague and varying errors, the most frequent of which look like this:

    ```
    Mysql2::Error: This connection is in use by: #<Thread:0x0000000bb400b8>
    ```

    PostgreSQL handles the situation *even worse*, and will silently hang in a way that may force you to kill your test suite and possibly restart the database daemon.

    And to make it all even worse, these errors are not only hard to understand but also inconsistent to reproduce.
    You might get them once every 5 test runs.
    You might get them only when the full suite runs, but not with smaller subsets of tests.
    You might see them happen in only one environment (say, on the CI server but not on your development machine).
    It's enough to make you consider a new career.
    North Dakota is hiring right now, FYI.

## Two simple steps to fix everything ##

We've identified the problems, which in this case is well over half the battle.
Now let's fix them.

1. First we'll need to share the database connection so everyone gets the same transaction.
   There's a fairly standard way to do this, [documented by Capybara][capybara_shared_connection], that involves dropping a monkey-patch into your test setup.
   Sure, it's a little kludgy, but it's only in your test suite so it's not gonna hurt production.

2. Now the harder part: we need the tests to wait for the browser to finish any outstanding requests before they pass and continue on to the next step.
   We could throw a `sleep 5` at the end of our test[^1], but remember, the whole point of this was to make the tests *faster*!
   Instead, the best solution is for us to ask the browser about pending requests, and wait until it reports that it's finished.
   There are [a few different versions of this general idea][ajax_waiting] floating around, but it gets tricky because there's not a standard way to check pending requests, so you gotta make use of whatever your JavaScript framework provides.
   And then you probably need a safeguard for pages where that framework isn't present.
   And may you be lucky enough to never test an app that uses several different frameworks in various combinations.
   And so on…

## One simple step to avoid the two previous steps ##

I thought this should be easier, for everyone.
So I made [transactional_capybara] to do just that.
It bundles up the shared connection hack plus AJAX waiting logic for the more common JavaScript frameworks.
And for a typical test suite, using it is as easy as adding something like this to your test helper:

```ruby
require 'transactional_capybara/rspec'
```

Yeah.
That good.

## Go forth and use transactions in your tests ##

I free you from the dread of Capybara heisenbugs!
I raise you from the agony of exacting parallelism management!
I cast out the foul demons of database deadlock!
Go forth and use transactions with Capybara, now and forever![^2]

[database transactions]: http://api.rubyonrails.org/v3.2.8/classes/ActiveRecord/Fixtures.html#label-Transactional+Fixtures
[Capybara]: https://jnicklas.github.io/capybara/
[Webkit]: https://github.com/thoughtbot/capybara-webkit
[Selenium]: https://github.com/seleniumhq/selenium
[capybara_shared_connection]: https://github.com/jnicklas/capybara/blob/2.4.4/README.md#transactions-and-database-setup
[ajax_waiting]: https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
[transactional_capybara]: https://github.com/iangreenleaf/transactional_capybara

[^1]: For the record, I fully endorse using this method *temporarily*.
      It's a great way to confirm that the errors are, in fact, caused by pending requests.
      Throw a `sleep` at the end of your problem tests, and if the trouble goes away you know it's a race condition and you can carry on with this solution.
      If a `sleep` doesn't solve it, then you might have some other problem on your hands and this might not be the blog for you.
[^2]: Just, whatever you do, don't have your integration tests do some model-level database queries at the end to assert shit.
      That's not how integration tests work, okay?
      And it's going to break everything again and I won't help you.

      Okay fine I'll help you.
      Just do five lashes of penitence, then call `TransactionalCapybara::AjaxHelpers.wait_for_ajax(page)` in between your browser commands and your weird database shit, and you should be fine.
