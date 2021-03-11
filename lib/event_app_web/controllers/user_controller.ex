defmodule EventAppWeb.UserController do
  use EventAppWeb, :controller

  alias EventApp.Users
  alias EventApp.Users.User
  alias EventAppWeb.SessionController

  alias EventAppWeb.Plugs
  plug Plugs.RequireUser when action not in [
    :new, :create, :show]
  plug :fetch_user when action in [
    :show, :edit, :update, :delete]
  plug :require_owner when action in [
    :edit, :update, :delete]

  def fetch_user(conn, _args) do
    id = conn.params["id"]
    user = Users.get_user!(id)
    assign(conn, :user, user)
  end

  def require_owner(conn, _args) do
    current_user = conn.assigns[:current_user]
    user = conn.assigns[:user]
    if current_user.id == user.id do
      conn
    else
      conn
      |> put_flash(:error, "You do not own this.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} successfully added as a user.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    user = conn.assigns[:user]
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = conn.assigns[:user]
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns[:user]

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    user = conn.assigns[:user]
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> SessionController.delete(%{})
  end
end
