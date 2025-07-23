defmodule TeamCollab.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :due_to, :date
    field :status, Ecto.Enum, values: [:on_time, :delayed, :delivered, :canceled]
    belongs_to :user, TeamCollab.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs, user_scope) do
    task
    |> cast(attrs, [:title, :description, :due_to, :status])
    |> validate_required([:title, :description, :due_to, :status])
    |> put_change(:user_id, user_scope.user.id)
  end
end
