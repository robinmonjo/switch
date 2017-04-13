defmodule Switch.Web.DomainControllerTest do
  use Switch.Web.AuthConnCase

  alias Switch.Domain
  @valid_attrs %{name: "http://domain.com", redirect: "https://redirect.com"}
  @invalid_attrs %{name: "domain.com", redirect: "invalid.com"}

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, domain_path(conn, :new)),
      get(conn, domain_path(conn, :index)),
      get(conn, domain_path(conn, :show, "some_id")),
      get(conn, domain_path(conn, :edit, "some_id")),
      put(conn, domain_path(conn, :update, "some_id", %{})),
      post(conn, domain_path(conn, :create, %{})),
      delete(conn, domain_path(conn, :delete, "some_id"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
    end)
  end

  describe "index" do
    @tag login_as: "me@me.com"
    test "list all domains on index", %{conn: conn, user: user} do
      user_domain = insert_domain(user, @valid_attrs)
      other_domain = insert_domain(insert_user(email: "other@other.com"), %{name: "https://testX.com", redirect: "https://testY.com"})

      conn = get conn, domain_path(conn, :index)
      assert html_response(conn, 200) =~ ~r/Listing domains/
      assert String.contains?(conn.resp_body, user_domain.name)
      assert String.contains?(conn.resp_body, other_domain.name)
    end
  end

  describe "create" do
    @tag login_as: "me@me.com"
    test "creates user domain and redirects", %{conn: conn, user: user} do
      conn = post conn, domain_path(conn, :create), domain: @valid_attrs
      assert redirected_to(conn) == domain_path(conn, :index)
      assert Repo.get_by(Domain, @valid_attrs).user_id == user.id
    end

    @tag login_as: "me@me.com"
    test "doesn not create domain and render errors when invalid", %{conn: conn} do
      conn = post conn, domain_path(conn, :create), domain: @invalid_attrs
      assert html_response(conn, 200) =~ "check the errors"
      refute Repo.get_by(Domain, @invalid_attrs)
    end
  end

  describe "update" do
    @tag login_as: "me@me.com"
    test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
      domain = insert_domain(user, @valid_attrs)
      updated_redirect = "http://updated_redirect.com"
      conn = put conn, domain_path(conn, :update, domain), domain: %{redirect: updated_redirect}
      assert redirected_to(conn) == domain_path(conn, :show, domain)
      assert Repo.get(Domain, domain.id).redirect == updated_redirect
    end

    @tag login_as: "me@me.com"
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
      domain = insert_domain(user, @valid_attrs)
      conn = put conn, domain_path(conn, :update, domain), domain: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit domain"
    end

    @tag login_as: "me@me.com"
    test "do not allow users to modify a domain that doesn't belong to them", %{conn: conn} do
      domain = insert_domain(insert_user(), @valid_attrs)
      assert_error_sent 404, fn ->
        put conn, domain_path(conn, :update, domain), domain: domain
      end
    end

    @tag login_as: "admin@admin.com"
    @tag :admin
    test "admin users can update a domain that they don't own", %{conn: conn} do
      domain = insert_domain(insert_user(), @valid_attrs)
      updated_redirect = "http://updated_name.com"
      conn = put conn, domain_path(conn, :update, domain), domain: %{redirect: updated_redirect}
      assert redirected_to(conn) == domain_path(conn, :show, domain)
      assert Repo.get(Domain, domain.id).redirect == updated_redirect
    end
  end

  describe "delete" do
    @tag login_as: "me@me.com"
    test "delete the resource", %{conn: conn, user: user} do
      domain = insert_domain(user, @valid_attrs)
      conn = delete conn, domain_path(conn, :delete, domain)
      assert redirected_to(conn) == domain_path(conn, :index)
      refute Repo.get(Domain, domain.id)
    end

    @tag login_as: "me@me.com"
    test "should not allow delete other user domain", %{conn: conn} do
      other_domain = insert_domain(insert_user(email: "other@other.com"), @valid_attrs)
      assert_error_sent 404, fn ->
        delete conn, domain_path(conn, :delete, other_domain)
      end
    end

    @tag login_as: "admin@admin.com"
    @tag :admin
    test "admin user can delete other users domains", %{conn: conn} do
      other_domain = insert_domain(insert_user(email: "other@other.com"), @valid_attrs)
      conn = delete conn, domain_path(conn, :delete, other_domain)
      assert redirected_to(conn) == domain_path(conn, :index)
      refute Repo.get(Domain, other_domain.id)
    end
  end

  describe "show" do
    @tag login_as: "me@me.com"
    test "renders show", %{conn: conn, user: user} do
      domain = insert_domain(user, @valid_attrs)
      conn = get conn, domain_path(conn, :show, domain)
      assert html_response(conn, 200) =~ domain.name
    end

    @tag login_as: "me@me.com"
    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, domain_path(conn, :show, "111111111111111111111111")
      end
    end
  end

  describe "edit" do
    @tag login_as: "me@me.com"
    test "renders form to edit resource", %{conn: conn, user: user} do
      domain = insert_domain(user, @valid_attrs)
      conn = get conn, domain_path(conn, :edit, domain)
      assert html_response(conn, 200) =~ "Edit domain"
    end
  end

  describe "new" do
    @tag login_as: "me@me.com"
    test "renders form for new resources", %{conn: conn} do
      conn = get conn, domain_path(conn, :new)
      assert html_response(conn, 200) =~ "New domain"
    end
  end

end
