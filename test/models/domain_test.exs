defmodule Switch.DomainTest do
  use Switch.DataCase, async: true

  alias Switch.Domain

  @valid_attrs %{name: "http://domain.com", redirect: "https://redirect.com"}

  test "changeset with valid attributes" do
    changeset = Domain.changeset(%Domain{}, @valid_attrs)
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

    test "redirect URL equals name" do
      url = "http://domain.com"
      changeset = Domain.changeset(%Domain{}, %{name: url, redirect: url})
      assert {:redirect, {"must be different than name", []}} in changeset.errors
      refute changeset.valid?
    end

    test "URL with path" do
      changeset = Domain.changeset(%Domain{}, %{name: "http://domain.com/", redirect: "http://redirect.com/test"})
      assert {:name, {"no path must be set", []}} in changeset.errors
      assert {:redirect, {"no path must be set", []}} in changeset.errors
      refute changeset.valid?
    end

  end


end
