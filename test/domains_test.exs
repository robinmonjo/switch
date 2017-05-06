defmodule Switch.DomainsTest do
  use Switch.DataCase, async: false
  import Switch.Fixtures

  alias Switch.{Domain, Domains, User}

  @valid_attrs %{name: "http://domain.com", redirect: "https://redirect.com"}
  @invalid_attrs %{name: "domain.com", redirect: "invalid.com"}

  describe "list_domains/0" do
    test "list all domains and preload user" do
      user = insert_user()
      domain1 = insert_domain(user, %{name: "http://domain1.com", redirect: "https://redirect1.com"})
      domain2 = insert_domain(user, %{name: "http://domain2.com", redirect: "https://redirect2.com"})
      assert [d1, d2] = Domains.list_domains()
      assert %User{} = d1.user
      assert %User{} = d2.user
    end
  end

  describe "create_domain/2" do
    test "create a domain with provided user and attrs" do
      user = insert_user()
      assert {:ok, %Domain{} = domain} = Domains.create_domain(user, @valid_attrs)
      assert domain.name == @valid_attrs.name
      assert domain.redirect == @valid_attrs.redirect
      assert domain.user_id == user.id
    end

    test "returns error when provided invalid attrs" do
      user = insert_user()
      assert {:error, changeset} = Domains.create_domain(user, @invalid_attrs)
    end
  end

  describe "async_validate_name_and_redirect" do
    test "validate domains exists" do
      domain =
        Domain.changeset(%Domain{}, %{name: "http://www.google.com", redirect: "http://unknown_unknown.unknow"})
        |> Repo.insert!()

      assert domain.name_checked == false
      assert domain.redirect_checked == false

      Domains.async_validate_name_and_redirect(domain) |> Task.await

      domain = Repo.get!(Domain, domain.id)

      assert domain.name_checked == true
      assert domain.redirect_checked == false
    end
  end

end
