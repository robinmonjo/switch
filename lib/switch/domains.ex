defmodule Switch.Domains do
  alias Switch.Repo
  alias Switch.Domain

  def list_domains() do
    domains = Repo.all(Domain) |> Repo.preload(:user)
  end

end
