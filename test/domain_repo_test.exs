defmodule Switch.DomainRepoTest do
  use Switch.DataCase

  alias Switch.Domain

  test "uniqueness of name" do
    url = "http://domain.com"
    cs = Domain.changeset(%Domain{}, %{name: url, redirect: "http://redirect.com"})
    Repo.insert!(cs)

    cs2 = Domain.changeset(%Domain{}, %{name: url, redirect: "http://redirect2.com"})
    assert {:error, changeset} = Repo.insert(cs2)
    assert {:name, {"has already been taken", []}} in changeset.errors
  end

  describe "async_validate_name_and_redirect" do
    test "validate domains exists" do
      domain =
        Domain.changeset(%Domain{}, %{name: "http://www.google.com", redirect: "http://unknown_unknown.unknow"})
        |> Repo.insert!()

      assert domain.name_checked == false
      assert domain.redirect_checked == false

      Domain.async_validate_name_and_redirect(domain) |> Task.await

      domain = Repo.get!(Domain, domain.id)

      assert domain.name_checked == true
      assert domain.redirect_checked == false
    end
  end
end
