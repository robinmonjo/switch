defmodule Switch.AuthTest do
  use Switch.ConnCase
  alias Switch.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Switch.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Switch.User{})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "authenticate_admin halts when current_user not admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Switch.User{})
      |> Auth.authenticate_admin([])
    assert conn.halted
  end

  test "authenticate_admin continues when current_user is admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Switch.User{admin: true})
      |> Auth.authenticate_admin([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Switch.User{id: "111111111111111111111111"})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == "111111111111111111111111"
  end

  test "logout remove the user in the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, "111111111111111111111111")
      |> Auth.logout()
      |> send_resp(:ok, "")
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with a valid email and pass", %{conn: conn} do
    user = insert_user(email: "me@me.com", password: "secret")
    {:ok, conn} = Auth.login_by_email_and_pass(conn, "me@me.com", "secret", repo: Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} = Auth.login_by_email_and_pass(conn, "me@me.com", "secret", repo: Repo)
  end

  test "login with password mismatch", %{conn: conn} do
    insert_user(email: "me@me.com", password: "secret")
    assert {:error, :unauthorized, _conn} = Auth.login_by_email_and_pass(conn, "me@me.com", "wrong", repo: Repo)
  end

end
