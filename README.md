# Switch

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create your database with `mix ecto.create`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix



## TODO:

- [x] validate domains and redirect format (may do a custom validation with a DNS check to see if the redirected domain exists) => masterize this: https://hexdocs.pm/ecto/Ecto.Changeset.html
- [x] validate domain NX record in a background task (over engineering :))
- [x] validate name != redirect
- [x] validate uniqueness of name
- [ ] invalidate cache when a domain get deleted
- [ ] manually invalidate cache
- [ ] consult cache
- [ ] manually recheck domain existence
- [ ] authentication from scratch: http://nithinbekal.com/posts/phoenix-authentication/
- last redirect_at
- domains users pagination

Login flow:
- generate invitation link (invitation token)
- send this link
- the guy can connect with email and add users
- only super admin can generate link to invite people
