defmodule TeamCollab.Repo do
  use Ecto.Repo,
    otp_app: :team_collab,
    adapter: Ecto.Adapters.SQLite3
end
