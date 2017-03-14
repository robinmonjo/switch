defmodule Switch.DomainViewTest do
  use Switch.ConnCase, async: true
  import Phoenix.View

  test "render index.html", %{conn: conn} do
    current_user = %Switch.User{id: "111111111111111111111111", email: "me@me.com"}
    other_user = %Switch.User{id: "111111111111111111111112", email: "test@test.com"}

    domains = [
      %Switch.Domain{id: "111111111111111111111111", name: "https://name.com", redirect: "http://redirect.com", user: current_user},
      %Switch.Domain{id: "111111111111111111111112", name: "https://name1.com", redirect: "http://redirect1.com", user: current_user},
      %Switch.Domain{id: "111111111111111111111113", name: "https://name2.com", redirect: "http://redirect2.com", user: other_user}
    ]
    content = render_to_string(Switch.DomainView, "index.html", conn: conn, domains: domains, current_user: current_user)
    assert String.contains?(content, "Listing domains")

    for domain <- domains do
      assert String.contains?(content, domain.name)
    end

  end
end
