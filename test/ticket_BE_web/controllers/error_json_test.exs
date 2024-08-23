defmodule Ticket_BEWeb.ErrorJSONTest do
  use Ticket_BEWeb.ConnCase, async: true

  test "renders 404" do
    assert Ticket_BEWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Ticket_BEWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
