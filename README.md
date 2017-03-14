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


## TODOs

- [x] users can see every domains but can't update or delete them
- [x] super admin has full access and can add users
- [x] delete user (keep its domains)
- [x] remove the registration form (only super admin can register people)
- [ ] test admin (domain controller / domain index)
- [ ] change password users
- [ ] move cache to a new service and add info about hit number / last hit at / last hit IP
- [ ] domain info service (check if it exists, whois, dig ...)
- [ ] live cache consultation (using channels)
- [ ] empty cache super admin
- [ ] add domains via "chat bot" wiht an ELM client for the chat interface
- [ ] migrate to phoenix 1.3

## TODO:

- [x] validate domains and redirect format (may do a custom validation with a DNS check to see if the redirected domain exists) => masterize this: https://hexdocs.pm/ecto/Ecto.Changeset.html
- [x] validate domain NX record in a background task (over engineering :))
- [x] validate name != redirect
- [x] validate uniqueness of name
- [x] invalidate cache when a domain get deleted
- [x] authentication from scratch

Mid project clean up
- [ ] allow users to see all domains (even if they didn't created them)
- [ ] prevent users to update or delete a domain they didn't created

- [ ] manually invalidate cache
- [ ] consult cache
- [ ] manually recheck domain existence

- last redirect_at
- domains users pagination

Login flow:
- generate invitation link (invitation token)
- send this link
- the guy can connect with email and add users
- only super admin can generate link to invite people
