defmodule Switch.Web.Router do
  use Switch.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Switch.Web.Auth, repo: Switch.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Switch.Web do
    pipe_through :browser  # Use the default browser stack

    get "/", RootController, :index

    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/domains", Switch.Web do
    pipe_through [:browser, :authenticate_user]
    resources "/", DomainController
  end

  scope "/users", Switch.Web do
    pipe_through [:browser, :authenticate_user, :authenticate_admin]
    resources "/", UserController, only: [:index, :new, :create, :delete]
  end

  scope "/me", Switch.Web do
    pipe_through [:browser, :authenticate_user]
    resources "/", MeController, only: [:show, :edit, :update]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Switch do
  #   pipe_through :api
  # end
end
