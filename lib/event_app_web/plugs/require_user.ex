defmodule EventAppWeb.Plugs.RequireUser do
  use EventAppWeb, :controller

  def init(args), do: args

  def call(conn, _args) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to do that.")
      |> redirect(to: Routes.user_path(conn, :new, redirect_to: conn.request_path))
      |> halt()
    end
  end

end
