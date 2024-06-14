defmodule Mensaplan.Accounts.UserToken do
  use Ecto.Schema

  import Ecto.Query
  alias Mensaplan.Repo
  alias Mensaplan.Accounts.UserToken
  alias Mensaplan.Accounts.User

  @rand_size 32

  @session_validity_in_days 365

  schema "user_tokens" do
    field :token, :binary, primary_key: true
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual b_user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def generate_user_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    Repo.insert!(%UserToken{token: token, user_id: user.id})
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_token(token) do
    Repo.one(
      from t in UserToken,
        join: user in assoc(t, :user),
        where: t.token == ^token and t.inserted_at > ago(@session_validity_in_days, "day"),
        select: user
    )
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_token(token) do
    Repo.delete_all(from t in UserToken, where: t.token == ^token)
  end
end
