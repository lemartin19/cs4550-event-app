defmodule EventAppWeb.SessionController do
  use EventAppWeb, :controller

  # This code was modeled after the SessionController from the notes
  # on 2/23 Photoblog

  def create(conn, %{"email" => email}) do
    IO.inspect(conn.params)
    redirect_path = conn.params["redirect_to"] || Routes.page_path(conn, :index)
    user = EventApp.Users.get_user_by_email(email)

    if user do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Welcome #{user.name}!")
      |> redirect(to: redirect_path)
    else
      conn
      |> put_flash(:error, "Login failed.")
      |> redirect(to: Routes.page_path(conn, :index, redirect_to: redirect_path))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
