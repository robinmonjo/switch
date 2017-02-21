defmodule Switch.RootController do
  use Switch.Web, :controller

  def index(conn, _params) do
    redirect conn, to: "/domains"
  end

end
