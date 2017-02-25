defmodule Switch.DomainServiceTest do
  use Switch.ServiceCase

  alias Switch.{DomainService, Domain}

  describe "insert" do
    test "should insert a valid domain" do
      assert {:ok, domain} = DomainService.insert(%{name: "http://domain.com", redirect: "http://redirect.com"})
      assert domain.name == "http://domain.com"
      assert domain.redirect == "http://redirect.com"
    end
  end

  describe "delete" do
    test "delete associated cache" do
      assert {:ok, domain} = DomainService.insert(%{name: "http://domain2.com", redirect: "http://redirect.com"})
      table = Application.fetch_env!(:switch, Switch)[:ets_cache_table]
      assert :ets.insert(table, {domain.name, domain.redirect}) == true
      DomainService.delete(domain)
      assert :ets.lookup(table, domain.name) == []
    end
  end

  test "validate domains exists" do
    cs = Domain.changeset(%Domain{}, %{name: "http://www.google.com", redirect: "http://unknown_unknown.unknow"})
    domain = Repo.insert!(cs)

    assert domain.name_checked == false
    assert domain.redirect_checked == false

    DomainService.async_validate_name_and_redirect(domain) |> Task.await

    domain = Repo.get!(Domain, domain.id)

    assert domain.name_checked == true
    assert domain.redirect_checked == false
  end

end
