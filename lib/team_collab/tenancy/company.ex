defmodule TeamCollab.Tenancy.Company do
  use Ecto.Schema
  import Ecto.Changeset

  schema "companies" do
    field :name, :string
    has_many :user, TeamCollab.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(company, attrs, user_scope) do
    company
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
