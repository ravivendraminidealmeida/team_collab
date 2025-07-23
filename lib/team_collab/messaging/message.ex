defmodule TeamCollab.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs, user_scope) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
    |> put_change(:user_id, user_scope.user.id)
  end
end
