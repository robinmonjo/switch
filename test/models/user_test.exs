defmodule Switch.UserTest do
  use Switch.ModelCase, async: true

  alias Switch.User

  @valid_attrs %{email: "me@me.com", password: "secret"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset doesn't allow invalid email" do
    attrs = %{@valid_attrs | email: "invalid"}
    assert {:email, "has invalid format"} in errors_on(%User{}, attrs)
  end

  test "register_changeset password must be at least 6 characters" do
    attrs = %{@valid_attrs | password: "123"}
    changeset = User.registration_changeset(%User{}, attrs)
    assert {:password, {"should be at least %{count} character(s)", count: 6}} in changeset.errors
  end

  test "registration_changeset with valid attributes hashes password" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    %{password: pass, password_hash: pass_hash} = changeset.changes
    assert changeset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(pass, pass_hash)
  end

  test "update_password_changeset with invalid old password has error" do
    old_pwd = "some strong password"
    user = %User{
      email: "me@me.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt(old_pwd)
    }

    changeset = User.update_password_changeset(user, %{old_password: "123456", password: "new password"})
    assert {:old_password, {"doesn't match", []}} in changeset.errors
  end

  test "update_password_changeset with valid old password" do
    old_pwd = "some strong password"
    user = %User{
      email: "me@me.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt(old_pwd)
    }

    new_pwd = "my new password"
    changeset = User.update_password_changeset(user, %{old_password: old_pwd, password: new_pwd})
    assert changeset.valid?
  end



end
