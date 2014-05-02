---
title: Closing another nasty security hole in OAuth
date: 2014-05-02
---

News broke today about a [widespread security flaw in OAuth and OpenID](http://tetraph.com/covert_redirect/oauth2_openid_covert_redirect.html). The written material is a bit short on actual explanations or actionable steps, which is unfortunate when the flaw claims to affect virtually all OAuth providers and must be patched in the OAuth client applications.

In the spirit of [my previous post on OAuth security issues](http://technotes.iangreenleaf.com/posts/closing-a-nasty-security-hole-in-oauth.html), I want to give you a practical guide to the issue. We're going to learn, in order: how to know if you’re vulnerable, how to fix it, and (for the curious) what the flaw actually is.

## Does it affect you? ##

Quite likely[^1]. The flaw is not tied to a particular OAuth implementation or usage pattern[^2]. The simplest way to know if you are affected is to follow the steps to fix it in the next section. If there's nothing there for you to do, you weren't vulnerable.

## How to fix it ##

Thankfully, closing the security hole is simple. Follow these steps for each of the OAuth providers (Facebook, Google, GitHub, etc) that you use:

1. Log in to the provider's OAuth management page. This is where you first registered your application with the provider, and where they show you the Client ID and Client Secret.

2. Find the place to enter your application's redirect URL. Google calls this the "Authorized redirect URI". GitHub calls it the "Authorization callback URL". In Facebook, you will find this under "Settings -> Advanced -> Valid OAuth redirect URIs"[^3].

3. Enter your **full** callback URL(s) in this field. This means you should be providing the entire path, such as `https://mysite.com/oauth/callback`. Do *not* use wildcards, and do *not* use only the domain.

That's it! You're safe[^4].

## What's the danger? ##

This vulnerability has two parts: trick the OAuth provider into redirecting to an unusual place, then as a result trick the OAuth client into leaking credentials.

Here's how it would go down:

1. CoypuApp is the trendiest web community for fans of obscure rodent species[^8]. CoypuApp lets users log in with Facebook. Alice, the user, trusts CoypuApp and uses her Facebook account as her identity.

2. When CoypuApp registered as a Facebook developer, they set it to trust their entire domain, `www.coypu.ar`.

3. CoypuApp offers a common convenience feature - when a user lands on a page and then logs in, they will be returned to the page they were viewing. To accomplish this, CoypuApp's home page takes an optional extra parameter, like this: `http://www.coypu.ar/welcome?return_to=http%3A%2F%2Fwww.coypu.ar%2Fvideos%2F2243`. When `return_to` is present, it will redirect to the specified page, thus returning the user to the coypu video they were watching.

4. A malicious user posts on the CoypuApp forums[^5] purporting to link to an awesome coypu blog. In fact the URL is a handcrafted attack URL:

    ```
    https://www.facebook.com/dialog/oauth?client_id=5564&redirect_uri=http%3A%2F%2Fwww.coypu.ar%2Fwelcome%3Freturn_to%3Dhttp%253A%252F%252Fcoypu-haters.nz%252Fattack
    ```

    Let's break this link down: it initiates the OAuth login process with Facebook. One of the OAuth params is `redirect_uri`, which names the endpoint that Facebook will redirect to with a token. Normally, this would be `http://www.coypu.ar/oauth`, and CoypuApp would pull the token out of the hash and use it to authenticate the user[^6].

    But in this link, something is wrong. `redirect_uri` is set to another value: `http://www.coypu.ar/welcome?return_to=http%3A%2F%2Fcoypu-haters.nz%2Fattack`. Facebook looks at this link and sees that it is at the `www.coypu.ar` domain. Facebook thus assumes it is safe. But remember that convenience feature we talked about? The attacker has snuck the `return_to` param into this URL, and it is pointing to a malicious site, `coypu-haters.nz`!

5. Alice sees the link to "awesome coypu blog" and clicks it. In the worst case, she still has a valid session at Facebook and it remembers her authorization of CoypuApp, so she is immediately passed through the OAuth process[^7].

6. Alice's browser is redirected with the OAuth token in the hash: `http://www.coypu.ar/welcome?return_to=http%3A%2F%2Fcoypu-haters.nz%2Fattack#access_token=d34db33f`.

7. The convenience feature sees that `return_to` is present, so it redirects to the URL it is given: `http://coypu-haters.nz/attack#access_token=d34db33f`.

8. Oh crap. The owner of `coypu-haters.nz` now has Alice's OAuth token and has access to anything that Alice authorized CoypuApp to do. They immediately start posting vile anti-coypu screeds to Alice's facebook wall, badly tarnishing her reputation.

It's a clever attack. It combines the unavoidably stateless nature of OAuth with the unrelated (but common) occurrence of open redirection endpoints in OAuth client domains to manipulate the provider's trust and the client's lack of caution. The root cause here is the poor choice of trusting all routes in a client's domain. OAuth providers must start demanding exact redirect paths when client apps are registered, and this problem will be effectively eliminated.

[^1]: I *could* say that you are only vulnerable if your domain hosts an "open redirection" endpoint - an endpoint that takes another URL as a parameter and indiscriminately redirects to it. However, it is my belief that an open redirection endpoint is a natural waste product of any sufficiently complicated web application, and so it is unwise both to assume that you will be aware of any that exist, and to believe that you will not introduce one at a later date. It is far easier to fix this vulnerability as I proscribe than it is to audit your entire infrastructure for open redirections.

[^2]: Clients that use the "authorization code" flow of OAuth **and** authenticate the token request with a secret known only to the client server are not directly vulnerable. However, this does you no good unless the provider is locked down to allow only the authorization code flow for your application. The attacker can craft a malicious URL with `response_type=token`, and most providers will happily honor that regardless of whether you ever implemented the implicit grant flow. At this point you are every bit as vulnerable as anyone else.

[^3]: Facebook's handling of this is shoddy and irresponsible. By hiding this option in the "Advanced" settings and defaulting to trusting the full domain, they've ensured that the vast majority of Facebook OAuth clients will be vulnerable to this. Your data is deeply unsafe in Facebook's hands, but then again, you should have already known that.

[^4]: Hopefully it goes without saying that your OAuth callback endpoint doesn't itself perform open redirection while keeping the hash params intact. If you've made that poor of a decision, maybe you should let someone else handle the OAuth code from now on.

[^5]: The malicious user could post this link anywhere, but the easiest way to target coypu enthusiasts is through their own forums.

[^6]: Let's hope CoypuApp is following [my previous advice](http://technotes.iangreenleaf.com/posts/closing-a-nasty-security-hole-in-oauth.html) on authenticating their tokens.

[^7]: The best case is that Alice has not yet signed in to CoypuApp, and so when she clicks the link she is prompted to "Allow CoypuApp to see my Facebook information". This might tip Alice off that something is wrong. But ordinary people find the Internet very confusing and more often than not will simply follow the instructions. So this isn't much of a "best" case.

[^8]: [Ian Lunderskov](https://twitter.com/lundersaur) insists that I credit him for his role in the development of this imaginary web application.
