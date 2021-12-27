defmodule Siwapp.Templates do
  @moduledoc """
  The Templates context. It handles Templates.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo

  alias Siwapp.Templates.Template

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list()
      [%Template{}, ...]

  """
  @spec list() :: [%Template{}]
  def list() do
    Template
    |> order_by(asc: :id)
    |> Repo.all()
  end

  @doc """
  Gets a single template.

  ## Examples

      iex> get(2)
      %Template{}

      iex> get(5)
      nil
        # because that template doesn't exist

  """
  @spec get(non_neg_integer) :: %Template{} | nil
  def get(id), do: Repo.get(Template, id)

  @doc """
  Creates a template.

  ## Examples

      iex> create(%{name: "Print Default", template: "<html>..."})
      {:ok, %Template{}}

      iex> create(%{name: "Print Default"})
      {:error, %Ecto.Changeset{}}
        # because template field is required

      iex> create(%{print_default: true})
      {:error, "You cannot directly assign..."}
  """
  @spec create(map) ::
          {:ok, %Template{}} | {:error, any()}
  def create(attrs \\ %{})

  def create(attrs) when is_map_key(attrs, :print_default) or is_map_key(attrs, :email_default) do
    {:error,
     "You cannot directly assign a default key. Use the change_default/2 function instead."}
  end

  def create(attrs) do
    with {:ok, template} <- insert_new(attrs),
         {:yes, template} <- check_if_its_the_first(template),
         {:ok, template} <- change_default(:print, template),
         {:ok, template} <- change_default(:email, template) do
      {:ok, template}
    else
      any -> any
    end
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update(template, %{name: "Print Default"})
      {:ok, %Template{}}

      iex> update(template, %{name: 8})
      {:error, %Ecto.Changeset{}}
        # because name cannot be an integer

      iex> update(template, %{email_default: true})
      {:error, "You cannot directly assign..."}
  """
  @spec update(%Template{}, map) ::
          {:ok, %Template{}} | {:error, any()}
  def update(_template, attrs)
      when is_map_key(attrs, :print_default) or is_map_key(attrs, :email_default) do
    {:error,
     "You cannot directly assign a default key. Use the change_default/2 function instead."}
  end

  def update(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets the unique template that has the default attribute set to 'true', for the given 'type'
  ## Examples
      iex> get_default(:email)
      %Template{}
      iex> get_default(:email)
      nil
        # there is no default template for emails
  """
  @spec get_default(:print | :email) :: %Template{} | nil
  def get_default(type) do
    Repo.get_by(Template, %{"#{type}_default" => true})
  end

  @doc """
  Choose a new template for being the default one, either for printing or emails.

  You'll have to indicate of which type this template will be the default: printing
  (the parameter you need to pass is ':print') or email (':email').

  You can call this function without parameters, so the default template will be
  the first one in the list of Templates; or with a 'template' given, so that one
  will be the default.

  ## Examples

      iex> change_default(:print, template)
      {:ok, %Template{}}
        # That template now has the default_print attribute as true,
        and the others templates as false

      iex> change_default(:print, template)
      {:error, %Ecto.Changeset{}}
        # That template doesn't exist

      iex> change_default(:email)
      {:ok, %Template{}}
        # The first template in the list now has its default_email attribute
        as true, and the other templates as false

  """
  @spec change_default(:print | :email, %Template{} | nil) ::
          {:ok, %Template{}} | {:error, %Ecto.Changeset{}}
  def change_default(type, template \\ nil)

  def change_default(type, nil) do
    key = "#{type}_default"

    list()
    |> List.first()
    |> update_by(key, true)
  end

  def change_default(type, default_template) do
    key = "#{type}_default"

    for template <- list() do
      update_by(template, key, false)
    end

    update_by(default_template, key, true)
  end

  @doc """
  Deletes a template.

  ## Examples

      iex> delete(template)
      {:ok, %Template{}}

      iex> delete(template)
      {:error, %Ecto.Changeset{}}
        # because that template doesn't exist

      iex> delete(template)
      {:error, "The template you're aiming..."}
        # because that template is the default one

  """
  @spec delete(%Template{}) :: {:ok, %Template{}} | {:error, %Ecto.Changeset{}}
  def delete(%Template{} = template) do
    if get_default(:print) == template or get_default(:email) == template do
      {:error, "The series you're aiming to delete is a default template,  \
      either for printing or emails. Change the default template first with \
      change_default/2 function."}
    else
      Repo.delete(template)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change(template)
      %Ecto.Changeset{data: %Template{}}

  """
  @spec change(%Template{}, map) :: %Ecto.Changeset{}
  def change(%Template{} = template, attrs \\ %{}) do
    Template.changeset(template, attrs)
  end

  @spec insert_new(map()) :: {:ok, %Template{}} | {:error, %Ecto.Changeset{}}
  defp insert_new(attrs) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @spec check_if_its_the_first(%Template{}) :: {:ok, %Template{}} | {:yes, %Template{}}
  def check_if_its_the_first(template) do
    if length(list()) == 1, do: {:yes, template}, else: {:ok, template}
  end

  @spec update_by(%Template{}, String.t() | atom(), any()) ::
          {:ok, %Template{}} | {:error, %Ecto.Changeset{}}
  defp update_by(template, key, value) do
    template
    |> Template.changeset(%{key => value})
    |> Repo.update()
  end
end
