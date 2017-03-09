defmodule Switch.TestHelpers do
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
    user
    |> Ecto.build_assoc(:domains, attrs)
    |> Repo.insert!()
  end

end
