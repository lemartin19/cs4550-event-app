defmodule EventAppWeb.Plugs.RequireOwner do
  use EventAppWeb, :controller

  alias EventAppWeb.Helpers

  def init(args), do: args

  def call(conn, _args) do
    if Helpers.current_user_is_owner?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You do not own this.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
