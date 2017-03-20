defmodule Switch.MeController do
  use Switch.Web, :controller

  alias Switch.User

  plug :authenticate_me

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = User.changeset(user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    IO.puts "--------------------------------------------------------------------"
    user = conn.assigns.current_user
    changeset = User.update_password_changeset(user, user_params)
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:error, "Password updated")
        |> redirect(to: me_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  # ensure all actions in this controller are performed on me
  defp authenticate_me(conn, _opts) do
    id = conn.params["id"]
    %{current_user: user}  = conn.assigns
    cond do
      id != user.id ->
        conn
        |> put_flash(:error, "Not yourself")
        |> redirect(to: me_path(conn, :show, user))
        |> halt()
      true ->
        conn
    end
  end

end
