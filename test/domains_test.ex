defmodule Switch.DomainsTest do
  use Switch.DataCase, async: false
  import Switch.Fixtures

  alias Switch.{Domain, Domains, User}

  @valid_attrs %{name: "http://domain.com", redirect: "https://redirect.com"}
  @invalid_attrs %{name: "domain.com", redirect: "invalid.com"}

  describe "list_domains/0" do
    test "list all domains and preload user" do
      user = insert_user(email: "me@me.com")
      domain1 = insert_domain(user, %{name: "http://domain1.com", redirect: "https://redirect1.com"})
      domain2 = insert_domain(user, %{name: "http://domain2.com", redirect: "https://redirect2.com"})
      assert [d1, d2] = Domains.list_domains()
      assert %User{} = d1.user
      assert %User{} = d2.user
    end
  end

end
