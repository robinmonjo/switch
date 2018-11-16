defmodule Switch.Web.HostSwitch do
  import Plug.Conn

  alias Switch.Domains

  @letsencrypt_challenge_root_path "/.well-known/acme-challenge"
  @hostname Application.fetch_env!(:switch, Switch)[:hostname]

  # the plug that performs the domain switch
  def init(opts), do: opts

  # if host is app host, the user wants to access the app
  def call(%{host: @hostname} = conn, _opts), do: conn

  # else this request should be redirected
  def call(%{host: host, scheme: scheme, request_path: request_path, query_string: query_string} = conn, _opts) do
    if String.starts_with?(request_path, @letsencrypt_challenge_root_path) do
      conn
    else
      case Domains.lookup_redirect("#{scheme}://#{host}") do
        {:ok, redirect} ->
          query = if query_string == "", do: "", else: "?#{query_string}"
          conn
          |> put_resp_header("location", "#{redirect}#{request_path}#{query}")
          |> resp(302, "You are being redirected.")
          |> halt
        :no_match ->
          conn
          |> Phoenix.Controller.render(Switch.Web.RootView, "not_found.html", %{})
          |> halt
      end
    end
  end
end
