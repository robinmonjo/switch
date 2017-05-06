defmodule Switch.Web.HostSwitchTest do
  use Switch.Web.ConnCase

  alias Switch.Domain
  alias Switch.DomainsCache, as: Cache

  test "redirect to the corresponding host redirect", %{conn: conn} do
    redirect = "https://redirect.com"
    domain = "http://abc.com"

    cs = Domain.changeset(%Domain{}, %{name: domain, redirect: redirect})
    Repo.insert!(cs)

    conn = %{conn | host: "abc.com"}

    conn = get conn, "/"
    assert redirected_to(conn) == "#{redirect}/"
  end

  test "no matching redirect", %{conn: conn} do
    conn = %{conn | host: "unknown.com"}

    conn = get conn, "/"
    assert html_response(conn, 200) =~ "unknown.com is not registered :("
  end

  test "redirect with a path and a query", %{conn: conn} do
    redirect = "https://redirect.com"

    cs = Domain.changeset(%Domain{}, %{name: "http://abc.com", redirect: redirect})
    Repo.insert!(cs)

    conn = %{conn | host: "abc.com"}

    path_and_query = "/some/path?some=query&with=params"
    conn = get conn, path_and_query
    assert redirected_to(conn) == "#{redirect}#{path_and_query}"
  end

  test "lookup in cache before looking up in the database", %{conn: conn} do
    assert Cache.add_sync("http://abcd.com", "http://redirect.com") == true
    conn = %{conn | host: "abcd.com"}
    conn = get conn, "/"
    assert redirected_to(conn) == "http://redirect.com/"
  end

end
