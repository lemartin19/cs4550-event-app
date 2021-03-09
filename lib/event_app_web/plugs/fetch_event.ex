defmodule EventAppWeb.Plugs.FetchEvent do
  import Plug.Conn

  alias EventApp.Events

  def init(args), do: args

  def call(conn, _args) do
    id = conn.params["id"]
    IO.inspect(conn.params)
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end
end
