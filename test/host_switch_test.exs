defmodule Switch.HostSwitchTest do
  use Switch.ConnCase

  alias Switch.Domain

  test "redirect to the corresponding host redirect", %{conn: conn} do
    redirect = "https://redirect.com"

    cs = Domain.changeset(%Domain{}, %{name: "http://abc.com", redirect: redirect})
    Repo.insert!(cs)

    conn = %{conn | host: "abc.com"}

    conn = get conn, "/"
    assert redirected_to(conn) == "#{redirect}/"
  end

  test "no matching redirect", %{conn: conn} do
    conn = %{conn | host: "abc.com"}

    conn = get conn, "/"
    assert response(conn, 404) =~ "abc.com has no match"
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

end
