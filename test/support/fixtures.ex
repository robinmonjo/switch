defmodule Switch.Fixtures do
  alias Switch.Repo

  def insert_user(attrs \\ %{}) do
    changes = Enum.into(attrs, %{
      email: "test@test.com",
      password: "supersecret"
    })

    %Switch.User{}
    |> Switch.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_domain(user, attrs \\ %{}) do
    {:ok, domain} = Switch.Domains.create_domain(user, attrs)
    domain
  end

end
