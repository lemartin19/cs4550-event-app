# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EventApp.Repo.insert!(%EventApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias EventApp.Repo
alias EventApp.Users.User
alias EventApp.Events.Event
alias EventApp.Avatars

defmodule Inject do
  def photo(name) do
    photos = Application.app_dir(:event_app, "priv/photos")
    path = Path.join(photos, name)
    {:ok, hash} = Avatars.save_photo(name, path)
    hash
  end
end

blue_people = Inject.photo("blue_people.jpeg")
aang = Inject.photo("aang.jpeg")

IO.inspect(blue_people)

lynnsey = Repo.insert!(%User{name: "lynnsey", email: "lynnsey@gmail.com", avatar_hash: blue_people})
Repo.insert!(%User{name: "ally", email: "ally@yahoo.com", avatar_hash: aang})

Repo.insert!(%Event{
  user_id: lynnsey.id,
  name: "the twins' bday bash",
  description: "come celebrate lynnsey and ally's 23rd birthdays",
  date: ~N[2021-07-15 18:00:00]
})
