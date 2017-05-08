defmodule Switch.DomainsTest do
  use Switch.DataCase, async: false
  import Switch.Fixtures

  alias Switch.{Domains, User}
  alias Switch.Domains.Domain

  @valid_attrs %{name: "http://domain.com", redirect: "https://redirect.com"}
  @valid_attrs_bis %{name: "http://domain1.com", redirect: "https://redirect2.com"}
  @invalid_attrs %{name: "domain.com", redirect: "invalid.com"}

  describe "list_domains/0" do
    test "list all domains and preload user" do
      user = insert_user()
      insert_domain(user, @valid_attrs)
      insert_domain(user, @valid_attrs_bis)
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
      assert {:error, _changeset} = Domains.create_domain(user, @invalid_attrs)
    end
  end

  describe "update_domain/2" do
    test "update a domain with provided attrs" do
      user = insert_user()
      domain = insert_domain(user, @valid_attrs)
      assert {:ok, %Domain{} = domain} = Domains.update_domain(domain, @valid_attrs_bis)
      assert domain.name == @valid_attrs_bis.name
      assert domain.redirect == @valid_attrs_bis.redirect
    end

    test "update_domain/2 with invalid data returns error changeset" do
      user = insert_user()
      domain = insert_domain(user, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Domains.update_domain(domain, @invalid_attrs)
    end
  end

  describe "delete_domain/1" do
    test "deletes the domain" do
      user = insert_user()
      domain = insert_domain(user, @valid_attrs)
      assert {:ok, %Domain{}} = Domains.delete_domain(domain)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_domain!(user, domain.id) end
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
