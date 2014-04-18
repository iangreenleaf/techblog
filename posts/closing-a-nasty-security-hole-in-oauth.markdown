---
title: Closing a nasty security hole in OAuth
date: 2014-04-18
---

Many web apps that use OAuth suffer from a fairly serious security flaw. Generic OAuth client libraries cannot completely patch this hole on their own, so you, the end-developer, are responsible for taking precautions. A small oversight when implementing the OAuth flow can open you up to someone impersonating your users and stealing their stuff. If you are using OAuth, you should definitely know about this and make sure you aren't exposed.

[More complete explanations](http://www.thread-safe.com/2012/01/problem-with-oauth-for-authentication.html) of the flaw have been written, and it is [mentioned in the OAuth spec](http://tools.ietf.org/html/rfc6749#section-10.16). This, instead, is a simple and practical guide to the problem. I'm going to explain how to know if you're vulnerable, how to fix it, and (for the curious) why this is a danger at all.

## Does it affect you? ##

You are at risk if **both** of the following apply to you:

* You are using an OAuth client to perform the "implicit grant" flow of OAuth. This is the flow that returns a token directly in the hash (instead of returning a code that's traded for a token). If your OAuth client exists anywhere on the front end, such as a JavaScript framework or a mobile app, you are probably using implicit grant. If your OAuth client is server-side, check anyhow. Could be someone decided to use the implicit flow improperly because it looked easier. If your `response_type` is set to `token`, you're using implicit grant.

* You are using OAuth for *authentication*, not just *authorization*. What does that mean, exactly? It means that when someone logs in with OAuth, you take this as proof of their identity and give them access to some private information or abilities beyond the information pulled from the OAuth provider. If you're storing any information of your own, this probably applies to you[^1]. If you're describing your OAuth client as "Sign in with [service]", this probably applies to you. If you're unsure, err on the side of caution; you can't do any harm by closing this hole preemptively.

You may be exempt if **both** of the following are true:

* You are using an official client maintained by your OAuth provider. This only counts if the client is specifically geared towards a single OAuth provider. Generic clients cannot solve this problem generically, no matter how official they are.
* The documentation for that client explicitly mentions this problem (may be called "confirming the token identity" or "validating the token"), and *promises* you that this step is handled automatically and you need to take no action.

## How to fix it ##

To close the security hole, you need to add one extra step. After you receive the OAuth callback with the token, you need to verify the token. Don't save it or do anything else with the token until it's verified.

Here's how you verify the token:

1. Find your own hardcoded[^2] client ID. This is what you sent as `client_id` earlier when you kicked off the whole OAuth flow.
2. Find the verification endpoint offered by the OAuth provider. It may be called "verification", or it may be called "token info" or "token debug" or something along those lines. Google offers [tokeninfo](https://developers.google.com/accounts/docs/OAuth2UserAgent#validatetoken). Facebook offers [debug_token](https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow#confirm). Doorkeeper, an OAuth provider for Rails, offers [token/info](https://github.com/doorkeeper-gem/doorkeeper/wiki/API-endpoint-descriptions-and-examples#get----oauthtokeninfo). The two important traits of this endpoint are that it must require a token, and it must return the application id.
3. Send a request to this endpoint with the token you received as authorization.
4. Find the application ID in the response. Facebook calls this `app_id`. Google calls it `audience`. Doorkeeper calls it `application.uid`. **Compare this ID to your own client ID**. Do they match? Then you're all set! Do they not match? Throw away the token and fail ungracefully[^3].

That's it! Verify the tokens and the security hole is closed. You've done your good deed for the day and you may carry on with your business. If you want to know *why* you just performed this extra step, read on.

## What's the danger? ##

The thing about receiving an OAuth callback is that *you don't know where that token has been*.

We assume that receiving a working token for a user means we're talking to that user. In fact, it's possible that someone else is impersonating the user. Here's how it would go down:

1. CapyApp is a photo-sharing community for capybara enthusiasts. Alice, the user, trusts CapyApp with her data. CapyApp offers login through Google, but has made the unfortunate mistake of not verifying the OAuth tokens they receive.
2. EvilApp is an app, secretly run by anti-capybara extremists, that offers "sinfully fun" games. Alice is bored and decides to try it out. EvilApp offers login through Google. Alice may not trust EvilApp but she's fine with giving it access to her public information.
3. Alice completes the OAuth flow in EvilApp. EvilApp now has a valid OAuth token from Google on behalf of Alice.
4. The evil people behind EvilApp open a browser and send that token to CapyApp's OAuth callback, pretending to be Alice completing the sign-in process.
5. CapyApp uses the token to pull Google profile information and sees that the token was issued on behalf of Alice.
6. CapyApp wrongly assumes that it's dealing with Alice and provides access to Alice's profile and private messages. All of Alice's private CapyApp data is now in the hands of EvilApp, including drafts of some rather unfortunate erotic fiction.

This mistake is very easy to commit. Our intuition dupes us into thinking that a call to an OAuth callback will always come directly from the provider's authentication, but the stateless nature of the web means that it may come from anywhere.

You can see now why verifying the token is important. That would break up the attack in step #5, when CapyApp would see that the application id associated with the token doesn't match CapyApp's own client id, and would discard the token instead of giving access to Alice's personal effects.

[^1]: The alternative, when this wouldn't apply to you, is when you are storing absolutely no user information of your own. Rather, you are *only* providing delegated access to the resources that the user has authorized via the token they've given you. *Iff* this is the case, you are not exposing anything the token holder couldn't get without your help and there is no security hole to close.
[^2]: Or hard-persisted, as the case may be. The point is that it's stored somewhere safe on your end as the counterpoint to information coming through the OAuth callback.
[^3]: Ungraceful failure is often the most appropriate type of failure. More on this someday later.
