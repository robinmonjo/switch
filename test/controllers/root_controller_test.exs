defmodule Switch.RootControllerTest do
  use Switch.ConnCase

  describe "index" do
    test "redirect to /domains", %{conn: conn} do
      conn = get conn, "/"
      assert redirected_to(conn) == "/domains"
    end
  end

end
