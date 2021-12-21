defmodule Siwapp.Commons do
  @moduledoc """
  The Commons context. It handles Series and Taxes.
  """

  import Ecto.Query, warn: false
  alias Siwapp.Repo

  alias Siwapp.Commons.{Series, Tax}

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
  @spec create_series(map) ::
          {:ok, %Series{}} | {:error, any()}
  def create_series(attrs \\ %{})

  def create_series(%{default: _}) do
    {:error,
     "You cannot directly assign the default key. Use the change_default_series/1 function instead."}
  end

  def create_series(attrs) do
    result = insert_new_series(attrs)

    with {:ok, series} <- result do
      if length(list_series()) == 1, do: change_default_series(series)
    end

    result
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
  @spec update_series(%Series{}, map) ::
          {:ok, %Series{}} | {:error, any()}
  def update_series(_series, %{default: _}) do
    {:error,
     "You cannot directly assign the default key. Use the change_default_series/1 function instead."}
  end

  def update_series(%Series{} = series, attrs) do
    series
    |> Series.changeset(attrs)
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
  def change_default_series(series \\ nil)

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

  @spec insert_new_series(map()) :: {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  defp insert_new_series(attrs) do
    %Series{}
    |> Series.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_default_series(%Series{}, boolean()) ::
          {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  defp update_default_series(series, value) do
    series
    |> Series.changeset(%{default: value})
    |> Repo.update()
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
  @spec create_tax(map) :: {:ok, %Tax{}} | {:error, %Ecto.Changeset{}}
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
  @spec update_tax(%Tax{}, map) ::
          {:ok, %Tax{}} | {:error, %Ecto.Changeset{}}
  def update_tax(%Tax{} = tax, attrs) do
    tax
    |> Tax.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Change the default tax, setting the attribute 'default' of the taxes
  with the given 'tax_id' to true or false.

  ## Examples

      iex> set_default_tax(3)
      {:ok, %Series{}}

  """
  @spec set_default_tax(non_neg_integer) :: {:ok, %Tax{}}
  def set_default_tax(id) do
    tax = get_tax!(id)
    default = tax.default

    tax
    |> Tax.changeset(%{"default" => not default})
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
  @spec change_tax(%Tax{}, map) :: %Ecto.Changeset{}
  def change_tax(%Tax{} = tax, attrs \\ %{}) do
    Tax.changeset(tax, attrs)
  end
end
