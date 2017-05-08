defmodule Switch.DomainsCacheTest do
  use ExUnit.Case, async: true
  alias Switch.Domains.Cache

  test "insert, lookup and delete" do
    domain_url = "http://domain.com"
    redirect_url = "http://redirect.com"
    assert Cache.add_sync(domain_url, redirect_url) == true
    assert Cache.lookup(domain_url) == redirect_url
    assert Cache.delete_sync(domain_url) == true
    assert Cache.lookup(domain_url) == :not_found
  end

end
