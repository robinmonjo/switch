defmodule Switch.RootControllerTest do
  use Switch.ConnCase

  describe "index" do
    test "redirect to /domains", %{conn: conn} do
      conn = %{conn | host: "localhost"}
      conn = get conn, "/"
      assert redirected_to(conn) == "/domains"
    end

    test "redirect to the corresponding host redirect", %{conn: conn} do
      conn = %{conn | host: "abc.com"}
      conn = get conn, "/"
      assert html_response(conn, 200) =~ "abc.com"
    end
  end

end
