defmodule Switch.RootController do
  use Switch.Web, :controller

  alias Switch.Domain

  def index(%{host: "localhost"} = conn, _params) do
    redirect conn, to: "/domains"
  end

  def index(%{host: host, request_path: request_path, query_string: query_string} = conn, _params) do
    query = from d in "domains",
            where: d.name == ^"#{conn.scheme}://#{host}",
            select: d.redirect

    case Repo.all(query) do
      [redirect | _] -> redirect(conn, external: "#{redirect}#{request_path}?#{query_string}")
      _ -> render conn, "not_found.html"
    end
  end

end
