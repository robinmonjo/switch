defmodule Switch.Web.RootController do
  use Switch.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
