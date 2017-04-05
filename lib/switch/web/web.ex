defmodule Switch.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Switch.Web, :controller
      use Switch.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: Switch.Web

      alias Switch.Repo
      import Ecto
      import Ecto.Query

      import Switch.Web.Router.Helpers
      import Switch.Web.Gettext
      import Switch.Web.Auth, only: [authenticate_user: 2]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/switch/web/templates", namespace: Switch.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Switch.Web.Router.Helpers
      import Switch.Web.ErrorHelpers
      import Switch.Web.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Switch.Web.Auth, only: [authenticate_user: 2, authenticate_admin: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Switch.Repo
      import Ecto
      import Ecto.Query
      import Switch.Web.Gettext
    end
  end

  def service do
    quote do
      alias Switch.Repo

      import Ecto
      import Ecto.Query
    end
  end



  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
