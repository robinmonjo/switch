defmodule Switch.UserRepoTest do
  use Switch.DataCase

  alias Switch.User

  @valid_attrs %{email: "me@me.com", password: "secret"}

  test "convert unique_constraint on email to error" do
    insert_user(email: "me@me.com")
    changeset = User.changeset(%User{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert(changeset)
    assert {:email, {"has already been taken", []}} in changeset.errors
  end

end
