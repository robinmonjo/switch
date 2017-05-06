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
end
