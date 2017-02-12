defmodule Switch.DomainTest do
  use Switch.ModelCase

  alias Switch.Domain

  @valid_attrs %{name: "some content", redirect: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Domain.changeset(%Domain{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Domain.changeset(%Domain{}, @invalid_attrs)
    refute changeset.valid?
  end
end
