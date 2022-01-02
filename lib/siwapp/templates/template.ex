defmodule Siwapp.Templates.Template do
  @moduledoc """
  Template
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          name: binary | nil,
          template: binary | nil,
          print_default: boolean(),
          email_default: boolean(),
          subject: binary | nil,
          deleted_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
  @fields [:name, :template, :print_default, :email_default, :subject, :deleted_at]

  schema "templates" do
    field :name, :string
    field :template, :string
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
    |> validate_length(:subject, max: 200)
  end
end
