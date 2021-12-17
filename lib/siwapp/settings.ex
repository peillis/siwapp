defmodule Siwapp.Settings do
  @moduledoc """
  The Settings context. It handles Series and Taxes.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo

  alias Siwapp.Schema.{Series, Tax}

  ### SERIES ###

  @doc """
  Returns the list of series.

  ## Examples

      iex> list_series()
      [%Series{}, ...]

  """
  @spec list_series :: [%Series{}]
  def list_series do
    Series
    |> order_by(asc: :id)
    |> Repo.all()
  end

  @doc """
  Gets a single series.

  ## Examples

      iex> get_series(2)
      %Series{}

      iex> get_series(5)
      nil
        # because that series doesn't exist

  """
  @spec get_series(non_neg_integer) :: %Series{} | nil
  def get_series(id), do: Repo.get(Series, id)

  @doc """
  Creates a series.

  ## Examples

      iex> create_series(%{name: "A-Series", value: "hsu384h"})
      {:ok, %Series{}}

      iex> create_series(%{name: "A-Series"})
      {:error, %Ecto.Changeset{}}
        # because value field is required

      iex> create_series(%{default: true})
      {:error, "You cannot directly assign..."}

  """
  @spec create_series(%{optional(any()) => any()}) ::
          {:ok, %Series{}} | {:error, any()}
  def create_series(attrs \\ %{})

  def create_series(attrs) when is_map_key(attrs, :default) do
    {:error,
     "You cannot directly assign the default key. Use the set_default_series/1 function instead."}
  end

  def create_series(attrs) do
    attrs = maybe_make_default_series(attrs)

    %Series{}
    |> Series.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a series.

  ## Examples

      iex> update_series(series, %{name: "hsu384h"})
      {:ok, %Series{}}

      iex> update_series(series, %{name: *very_very_long_new_name*})
      {:error, %Ecto.Changeset{}}

      iex> update_series(%{default: true})
      {:error, "You cannot directly assign..."}

  """
  @spec update_series(%Series{}, %{optional(any()) => any()}) ::
          {:ok, %Series{}} | {:error, any()}
  def update_series(_series, attrs) when is_map_key(attrs, :default) do
    {:error,
     "You cannot directly assign the default key. Use the set_default_series/1 function instead."}
  end

  def update_series(%Series{} = series, attrs) do
    attrs = maybe_make_default_series(attrs)

    series
    |> Series.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets the unique series that has the default attribute set to 'true'

  ## Examples

      iex> get_default_series
      %Series{}

      iex> get_default_series
      nil
        # there is no default series

  """
  @spec get_default_series :: %Series{} | nil
  def get_default_series do
    Repo.get_by(Series, default: true)
  end

  @doc """
  Change the default series, setting the attribute 'default' of the series
  with the given 'series_id' to true and the one of the current default series
  to false.

  ## Examples

      iex> set_default_series(3)
      {:ok, %Series{}}

  """
  @spec set_default_series(non_neg_integer) :: {:ok, %Series{}}
  def set_default_series(series_id) do
    get_default_series()
    |> Series.changeset(%{"default" => false})
    |> Repo.update()

    series_id
    |> get_series()
    |> Series.changeset(%{"default" => true})
    |> Repo.update()
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
    Repo.delete(series)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking series changes.

  ## Examples

      iex> change_series(series)
      %Ecto.Changeset{data: %Series{}}

  """
  @spec change_series(%Series{}, %{optional(any()) => any()}) :: %Ecto.Changeset{}
  def change_series(%Series{} = series, attrs \\ %{}) do
    Series.changeset(series, attrs)
  end

  @spec maybe_make_default_series(%{optional(any()) => any()}) :: %{optional(any()) => any()}
  defp maybe_make_default_series(attrs) do
    if get_default_series(), do: attrs, else: Map.put(attrs, "default", true)
  end

  ### TAXES ###

  @doc """
  Returns the list of taxes.

  ## Examples

      iex> list_taxes()
      [%Tax{}, ...]

  """
  @spec list_taxes :: [%Tax{}]
  def list_taxes do
    Repo.all(Tax)
  end

  @doc """
  Gets a single tax.

  Raises `Ecto.NoResultsError` if the Tax does not exist.

  ## Examples

      iex> get_tax!(2)
      %Tax{}

      iex> get_tax!(5)
      ** (Ecto.NoResultsError)

  """
  @spec get_tax!(non_neg_integer) :: %Tax{}
  def get_tax!(id), do: Repo.get!(Tax, id)

  @doc """
  Creates a tax.

  ## Examples

      iex> create_tax(%{name: "VAT", value: 21.0})
      {:ok, %Tax{}}

      iex> create_tax(%{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_tax(%{optional(any()) => any()}) :: {:ok, %Tax{}} | {:error, %Ecto.Changeset{}}
  def create_tax(attrs \\ %{}) do
    %Tax{}
    |> Tax.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tax.

  ## Examples

      iex> update_tax(tax, %{value: 18.0})
      {:ok, %Tax{}}

      iex> update_tax(tax, %{value: "not a number"})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_tax(%Tax{}, %{optional(any()) => any()}) ::
          {:ok, %Tax{}} | {:error, %Ecto.Changeset{}}
  def update_tax(%Tax{} = tax, attrs) do
    tax
    |> Tax.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tax.

  ## Examples

      iex> delete_tax(tax)
      {:ok, %Tax{}}

      iex> delete_tax(tax)
      {:error, %Ecto.Changeset{}}
        # because that tax doesn't exist

  """
  @spec delete_tax(%Tax{}) :: {:ok, %Tax{}} | {:error, %Ecto.Changeset{}}
  def delete_tax(%Tax{} = tax) do
    Repo.delete(tax)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tax changes.

  ## Examples

      iex> change_tax(tax)
      %Ecto.Changeset{data: %Tax{}}

  """
  @spec change_tax(%Tax{}, %{optional(any()) => any()}) :: %Ecto.Changeset{}
  def change_tax(%Tax{} = tax, attrs \\ %{}) do
    Tax.changeset(tax, attrs)
  end
end
