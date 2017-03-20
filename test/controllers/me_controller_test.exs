defmodule Switch.MeControllerTest do
  use Switch.AuthConnCase

  alias Switch.User

  test "requires user to be authentified", %{conn: conn} do
    Enum.each([
      get(conn, me_path(conn, :show, "some_id")),
      get(conn, me_path(conn, :edit, "some_id")),
      put(conn, me_path(conn, :update, "some_id", %{}))
    ], fn conn ->
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
    end)
  end

  @tag login_as: "me@me.com"
  test "only allow users to access their resources", %{conn: conn, user: user} do
    other_user = insert_user()
    %{id: id} = other_user
    Enum.each([
      get(conn, me_path(conn, :show, other_user)),
      get(conn, me_path(conn, :edit, other_user)),
      put(conn, me_path(conn, :update, other_user, %{}))
    ], fn conn ->
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/me/#{user.id}"
    end)
  end

  describe "show" do
    @tag login_as: "me@me.com"
    test "render show", %{conn: conn, user: user} do
      conn = get conn, me_path(conn, :show, user)
      assert html_response(conn, 200) =~ user.email
    end
  end

  describe "edit" do
    @tag login_as: "me@me.com"
    test "render edit", %{conn: conn, user: user} do
      conn = get conn, me_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit profile"
    end
  end

  describe "update" do
    @tag login_as: "me@me.com"
    @tag password: "some secret"
    test "render edit with errors", %{conn: conn, user: user} do
      conn = put conn, me_path(conn, :update, user), user: %{old_password: "wrong", password: "new_password"}
      assert html_response(conn, 200) =~ "Edit profile"
      assert String.contains?(conn.resp_body, "something went wrong")
    end
  end

end
