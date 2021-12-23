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

      iex> create_series(%{print_default: true})
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
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
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
  @spec update_series(%Template{}, map) ::
          {:ok, %Template{}} | {:error, any()}
  def update(_template, attrs) when is_map_key(attrs, :print_default) or is_map_key(attrs, :email_default) do
    {:error,
      "You cannot directly assign a default key. Use the change_default/2 function instead."}
  end

  def update_series(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Choose a new series for being the default one. You can call this function without
  parameters, so the default series will be the first one in the list of Series; or with
  a 'series' given, so that series will be the default.

  ## Examples

      iex> change_default_series(series)
      {:ok, %Series{}}
        # That series now has the default attribute as true, and the others as false

      iex> change_default_series(series)
      {:error, %Ecto.Changeset{}}
        # That series doesn't exist

      iex> change_default_series(series)
      {:ok, %Series{}}
        # The first series in the list now has its default attribute as true

  """
  @spec change_default_series(%Series{} | nil) :: {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  def change_default(series \\ nil)

  def change_default_series(nil) do
    list_series()
    |> List.first()
    |> update_default_series(true)
  end

  def change_default_series(default_series) do
    for series <- list_series() do
      series
      |> update_default_series(false)
    end

    default_series
    |> update_default_series(true)
  end

  @doc """
  Deletes a series.

  ## Examples

      iex> delete_series(series)
      {:ok, %Series{}}

      iex> delete_series(series)
      {:error, %Ecto.Changeset{}}
        # because that series doesn't exist

  """
  @spec delete_series(%Series{}) :: {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  def delete_series(%Series{} = series) do
    result = Repo.delete(series)

    with {:ok, _} <- result do
      if length(list_series()) != 0, do: change_default_series()
    end

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking series changes.

  ## Examples

      iex> change_series(series)
      %Ecto.Changeset{data: %Series{}}

  """
  @spec change_series(%Series{}, map) :: %Ecto.Changeset{}
  def change_series(%Series{} = series, attrs \\ %{}) do
    Series.changeset(series, attrs)
  end

  @spec update_default_series(%Series{}, boolean()) ::
          {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  defp update_default_series(series, value) do
    series
    |> Series.changeset(%{default: value})
    |> Repo.update()
  end

end
