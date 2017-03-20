defmodule Switch.AuthConnCase do
  @moduledoc """
  Similar to conn_case but take into account the @login_as and @admin tags to setup the connection with a user
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Switch.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Switch.Router.Helpers
      import Switch.TestHelpers

      # The default endpoint for testing
      @endpoint Switch.Endpoint
    end
  end

  setup tags do
    unless tags[:async] do
      Mongo.Ecto.truncate(Switch.Repo, [])
    end

    conn = Phoenix.ConnTest.build_conn()

    admin = tags[:admin] || false
    if email = tags[:login_as] do
      user = Switch.TestHelpers.insert_user(email: email, admin: admin, password: tags[:password] || "secret")
      conn = Plug.Conn.assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      {:ok, conn: conn}
    end
  end
end
