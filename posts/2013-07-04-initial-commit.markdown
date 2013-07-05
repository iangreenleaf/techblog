---
title: Initial Commit
---

I like to start all of my personal "chains" -- blogs, social network accounts, and so on, with a small, unimportant placeholder post. I'm not sure why, exactly. I could claim it's to see if everything is configured correctly, but that would only be a partial truth. I do it because it just seems... right.

Rather than delve further into my psyche, let me share a neat trick to follow this same practice in Git. Every Git repository has a first commit. As a matter of religion I have always commented these commits with simply `Initial commit`. In the past I would commit some placeholder for the project -- a Rails skeleton, or a Readme, or whatever code I had so far.

The first commit in Git is tricky, though. It's not quite as malleable as the other commits if you later try to modify the history. Better to make a true placeholder: an empty commit. It's actually quite easy to do this.

    git init
    git commit --allow-empty -m "Initial commit"

Boom. Enjoy the new technique, and enjoy the irony that in showing you this, my first post has grown to something not entirely inconsequential.
