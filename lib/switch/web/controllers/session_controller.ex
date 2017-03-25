defmodule Switch.Web.SessionController do
  use Switch.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    case Switch.Web.Auth.login_by_email_and_pass(conn, email, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back")
        |> redirect(to: domain_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "invalid email/password")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Switch.Web.Auth.logout
    |> redirect(to: root_path(conn, :index))
  end

end
