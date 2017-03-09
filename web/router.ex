defmodule Switch.Router do
  use Switch.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Switch.Auth, repo: Switch.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Switch do
    pipe_through :browser  # Use the default browser stack

    get "/", RootController, :index

    resources "/users", UserController, only: [:index, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/domains", Switch do
    pipe_through [:browser, :authenticate_user]
    resources "/", DomainController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Switch do
  #   pipe_through :api
  # end
end
