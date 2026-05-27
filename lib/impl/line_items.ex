defmodule Productive.Impl.LineItems do
  @moduledoc false

  alias Productive.{Client, Error, Transport}

  @per_page 200

  @type id :: String.t() | integer()
  @type include :: String.t() | [String.t()]
  @type list_filters :: %{
          optional(:invoice_id) => id() | [id()],
          optional(:include) => include(),
          optional(:page) => pos_integer()
        }

  @spec get_list(Client.t(), list_filters()) :: {:ok, map()} | {:error, Error.t()}
  def get_list(client, filters) when is_map(filters) do
    with :ok <- validate_filters(filters) do
      Transport.request(client, :get, "/line_items", params: build_params(filters))
    end
  end

  def get_list(_client, _filters),
    do: {:error, Error.validation_error("line item filters", %{filters: "must be a map"})}

  defp build_params(filters) do
    page = Map.get(filters, :page, 1)

    %{page: page, per_page: @per_page}
    |> maybe_put_invoice_id(filters)
    |> maybe_put_include(filters)
  end

  defp maybe_put_invoice_id(params, %{invoice_id: ids}) when is_list(ids) and ids != [],
    do: Map.put(params, :"filter[invoice_id]", Enum.map_join(ids, ",", &to_string/1))

  defp maybe_put_invoice_id(params, %{invoice_id: id}) when is_binary(id) or is_integer(id),
    do: Map.put(params, :"filter[invoice_id]", to_string(id))

  defp maybe_put_invoice_id(params, _), do: params

  defp maybe_put_include(params, %{include: include}) when is_binary(include) and include != "",
    do: Map.put(params, :include, include)

  defp maybe_put_include(params, %{include: include}) when is_list(include) and include != [],
    do: Map.put(params, :include, Enum.join(include, ","))

  defp maybe_put_include(params, _), do: params

  defp validate_filters(filters) do
    errors =
      %{}
      |> validate_page(filters)
      |> validate_invoice_id(filters)
      |> validate_include(filters)

    if map_size(errors) == 0,
      do: :ok,
      else: {:error, Error.validation_error("line item filters", errors)}
  end

  defp validate_page(errors, %{page: page}) when is_integer(page) and page > 0, do: errors
  defp validate_page(errors, %{page: _}), do: Map.put(errors, :page, "must be a positive integer")
  defp validate_page(errors, _), do: errors

  defp validate_invoice_id(errors, %{invoice_id: ids}) when is_list(ids) do
    if ids != [] and Enum.all?(ids, &(is_binary(&1) or is_integer(&1))),
      do: errors,
      else: Map.put(errors, :invoice_id, "must be a non-empty list of ids")
  end

  defp validate_invoice_id(errors, %{invoice_id: id}) when is_binary(id) and id != "", do: errors
  defp validate_invoice_id(errors, %{invoice_id: id}) when is_integer(id), do: errors

  defp validate_invoice_id(errors, %{invoice_id: _}),
    do: Map.put(errors, :invoice_id, "must be an id or list of ids")

  defp validate_invoice_id(errors, _), do: errors

  defp validate_include(errors, %{include: i}) when is_binary(i) and i != "", do: errors
  defp validate_include(errors, %{include: i}) when is_list(i), do: errors

  defp validate_include(errors, %{include: _}),
    do: Map.put(errors, :include, "must be a string or list of strings")

  defp validate_include(errors, _), do: errors
end
