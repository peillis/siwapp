defmodule Siwapp.Templates.Template do
  use Ecto.Schema

  import Ecto.Changeset

  @fields [:name, :template, :models, :print_default, :email_default, :subject, :deleted_at]

  schema "templates" do
    field :name, :string
    field :template, :string
    field :models, :string
    field :print_default, :boolean, default: false
    field :email_default, :boolean, default: false
    field :subject, :string
    field :deleted_at, :utc_datetime

    timestamps()
  end

  def changeset(template, attrs \\ %{}) do
    template
    |> cast(attrs, @fields)
    |> validate_required([:name, :template])
    |> validate_length(:name, max: 255)
    |> validate_length(:models, max: 200)
    |> validate_length(:subject, max: 200)
  end
end
