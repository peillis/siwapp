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
    Repo.all(Series)
  end

  @doc """
  Gets a single series.

  Raises `Ecto.NoResultsError` if the Series does not exist.

  ## Examples

      iex> get_series!(2)
      %Series{}

      iex> get_series!(5)
      ** (Ecto.NoResultsError)

  """
  @spec get_series!(non_neg_integer) :: %Series{}
  def get_series!(id), do: Repo.get!(Series, id)

  @doc """
  Creates a series.

  ## Examples

      iex> create_series(%{name: "A-Series", value: "hsu384h"})
      {:ok, %Series{}}

      iex> create_series(%{name: "A-Series"})
      {:error, %Ecto.Changeset{}}
        # because value field is required

  """
  @spec create_series(%{optional(atom()) => any()}) ::
          {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  def create_series(attrs \\ %{}) do
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

  """
  @spec update_series(%Series{}, %{optional(atom()) => any()}) ::
          {:ok, %Series{}} | {:error, %Ecto.Changeset{}}
  def update_series(%Series{} = series, attrs) do
    series
    |> Series.changeset(attrs)
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
  @spec change_series(%Series{}, %{optional(atom()) => any()}) :: %Ecto.Changeset{}
  def change_series(%Series{} = series, attrs \\ %{}) do
    Series.changeset(series, attrs)
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
  @spec create_tax(%{optional(atom()) => any()}) :: {:ok, %Tax{}} | {:error, %Ecto.Changeset{}}
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
  @spec update_tax(%Tax{}, %{optional(atom()) => any()}) ::
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
  @spec change_tax(%Tax{}, %{optional(atom()) => any()}) :: %Ecto.Changeset{}
  def change_tax(%Tax{} = tax, attrs \\ %{}) do
    Tax.changeset(tax, attrs)
  end
end
