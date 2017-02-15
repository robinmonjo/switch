defmodule Switch.DomainTest do
  use Switch.ModelCase

  alias Switch.Domain

  test "changeset with valid attributes" do
    changeset = Domain.changeset(%Domain{}, %{name: "http://domain.com", redirect: "https://redirect.com"})
    assert changeset.valid?
  end

  describe "changeset with invalid attributes" do

    test "required attributes" do
      changeset = Domain.changeset(%Domain{}, %{})
      refute changeset.valid?

      changeset = Domain.changeset(%Domain{}, %{name: "http://domain.com"})
      refute changeset.valid?
    end

    test "URLs without HTTP or HTTPS schemes" do
      changeset = Domain.changeset(%Domain{}, %{name: "ftp://domain.com", redirect: "http://redirect.com"})
      assert {:name, {"only HTTP and HTTPS schemes are alowed", []}} in changeset.errors
      refute changeset.valid?

      changeset = Domain.changeset(%Domain{}, %{name: "http://domain.com", redirect: "redirect.com"})
      assert {:redirect, {"missing HTTP or HTTPS scheme", []}} in changeset.errors
      refute changeset.valid?
    end

    test "URLs without host" do
      changeset = Domain.changeset(%Domain{}, %{name: "http://", redirect: "http://redirect.com"})
      assert {:name, {"host can't be nil", []}} in changeset.errors
      refute changeset.valid?
    end

  end


end
