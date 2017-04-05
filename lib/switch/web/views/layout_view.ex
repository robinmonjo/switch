defmodule Switch.Web.LayoutView do
  use Switch.Web, :view

  # Generates name for the JavaScript view we want to use
  # in this combination of view/template.
  def js_view_name(conn, view_template) do
    view =
      conn
      |> view_module()
      |> Phoenix.Naming.resource_name()

    template =
      view_template
      |> String.split(".")
      |> Enum.at(0)

    "#{view}_#{template}"
  end
end
