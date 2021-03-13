defmodule EventAppWeb.UserController do
  use EventAppWeb, :controller

  alias EventApp.Users
  alias EventApp.Avatars
  alias EventApp.Users.User
  alias EventAppWeb.SessionController

  alias EventAppWeb.Plugs
  plug Plugs.RequireUser when action not in [
    :new, :create, :show]
  plug :fetch_user when action in [
    :show, :edit, :update, :delete, :photo]
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

  def get_avatar_hash(params) do
    up = if Map.has_key?(params, "avatar") do
      params["avatar"]
    else
      %{
        content_type: "image/jpeg",
        filename: "default_avatar.png",
        path: Application.app_dir(:event_app, "priv/photos/default-avatar.png")
       }
    end

    {:ok, hash} = Avatars.save_photo(up.filename, up.path)
    Map.put(params, "avatar_hash", hash)
  end

  def new(conn, _params) do
    IO.inspect(conn.params)
    changeset = Users.change_user(%User{})
    IO.inspect(conn.assigns)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params = get_avatar_hash(user_params)
    redirect_path = if conn.params["redirect_to"]
        && conn.params["redirect_to"] != "" do
      conn.params["redirect_to"]
    else
      Routes.page_path(conn, :index)
    end
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} successfully added as a user.")
        |> SessionController.create(%{"email" => user.email})

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
    user_params = get_avatar_hash(user_params)
    user = conn.assigns[:user]
    if user_params["avatar_hash"] do
      Avatars.delete_photo(user.avatar_hash)
    end

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
    Avatars.delete_photo(user.avatar_hash)
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> SessionController.delete(%{})
  end

  def photo(conn, _params) do
    user = conn.assigns[:user]
    {:ok, _name, data} = Avatars.load_photo(user.avatar_hash)
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, data)
  end
end
