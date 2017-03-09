defmodule Switch.DomainViewTest do
  use Switch.ConnCase, async: true
  import Phoenix.View

  test "render index.html", %{conn: conn} do
    domains = [
      %Switch.Domain{id: "111111111111111111111111", name: "https://name.com", redirect: "http://redirect.com"},
      %Switch.Domain{id: "111111111111111111111112", name: "https://name1.com", redirect: "http://redirect1.com"},
      %Switch.Domain{id: "111111111111111111111113", name: "https://name2.com", redirect: "http://redirect2.com"}
    ]
    content = render_to_string(Switch.DomainView, "index.html", conn: conn, domains: domains)
    assert String.contains?(content, "Listing domains")

    for domain <- domains do
      assert String.contains?(content, domain.name)
    end

  end
end
