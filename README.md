We have to unpack exactly what “GitHub URL for callback” means in your scenario — but generally speaking: no, you can’t reliably use a “GitHub URL” (e.g. a github.com/... URL) as your OIDC/OAuth callback redirect for capturing state from Okta (or any identity provider), unless you also own/control that URL and can host a handler there. The callback (redirect) must point to an endpoint you control (on your webserver or service) that can receive, validate, and process the state and authorization response.

Here’s more detail and considerations:

⸻

Why the redirect URI must be under your control
	1.	Security and trust model
In OAuth / OpenID Connect flows, the identity provider (in this case Okta) requires you to pre-register a redirect URI (or a set of them). During the authorization flow, after the user authenticates, Okta will redirect the browser to that registered URI (with parameters like code, state, error, etc.). If the callback URI is not one that you control, then you cannot securely verify or process the response.
	2.	Exact matching requirement
Most identity providers (including Okta) require exact string matching of the redirect URI. Using variable or wildcard URIs is typically disallowed (except in certain safe localhost cases) because of phishing and redirect attacks. For example, you can’t dynamically redirect to arbitrary domains.  ￼
	3.	Processing logic needs to exist
The callback endpoint must have logic to parse the incoming query (or fragment) parameters, validate the state (to protect against CSRF), and handle exchanging the authorization code for tokens (if using Authorization Code flow) or parsing token responses (in implicit/hybrid). If your callback is just a static page or something hosted where you cannot run backend logic, you cannot complete the flow.

⸻

Could a GitHub Pages URL ever work?
	•	If by “GitHub URL” you meant a GitHub Pages site (e.g. https://username.github.io/myapp/callback), then theoretically, if that page has JavaScript to parse the URL and communicate back to your backend, you might try a client-side-only flow (e.g. PKCE + implicit-like patterns). But this is generally not recommended for several reasons (security, token exposure, inability to securely store secrets, etc.).
	•	However, GitHub Pages does not support server-side processing (unless you combine it with serverless functions or an external backend). So you would lack the ability to securely exchange a code for a token, verify signatures, etc.

⸻

Typical correct setup: use your own webserver / backend

In practice, what you want is:
	1.	A backend (web server, microservice, cloud function) that can host an endpoint like /oauth2/callback (or whatever path) on your domain.
	2.	You configure that redirect URI in your Okta application settings.
	3.	During the login flow, you send the user to Okta’s authorization endpoint with parameters including redirect_uri, state, etc.
	4.	After user authenticates, Okta redirects back to your callback URL with state (and maybe code, error, etc.).
	5.	Your server handles the callback: validate state, exchange code for tokens, etc.

This is the standard approach used in virtually all OAuth / OIDC integrations.

⸻

If you like, I can dive deeper into your particular stack (which language / framework / hosting) and suggest how to set up the callback endpoint. Do you want me to tailor it for, say, Node.js, .NET, or whatever you’re using?
