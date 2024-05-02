defmodule Mensaplan.Repo do
  use Ecto.Repo,
    otp_app: :mensaplan,
    adapter: Ecto.Adapters.Postgres
end
