defmodule EventAppWeb.Plugs.RequireOwner do
  use EventAppWeb, :controller

  def init(args), do: args

  def call(conn, _args) do
    current_user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    if current_user.id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You do not own this.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
