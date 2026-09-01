defmodule Productive.Impl.Tasks do
  @moduledoc false

  alias Productive.{Client, Error, Transport}

  @type id :: String.t() | integer()
  @type list_filters :: %{
          optional(:query) => String.t(),
          optional(:project_id) => id(),
          optional(:page_size) => pos_integer()
        }

  @spec get_list(Client.t(), list_filters(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_list(client, filters, req_options \\ [])

  def get_list(client, filters, req_options) when is_map(filters) do
    with :ok <- validate_filters(filters) do
      Transport.request(client, :get, "/tasks", [params: build_params(filters)] ++ req_options)
    end
  end

  def get_list(_client, _filters, _req_options),
    do: {:error, Error.validation_error("task filters", %{filters: "must be a map"})}

  defp build_params(filters) do
    %{}
    |> maybe_put_query(filters)
    |> maybe_put_project_id(filters)
    |> maybe_put_page_size(filters)
  end

  defp maybe_put_query(params, %{query: query}),
    do: Map.put(params, :"filter[query]", query)

  defp maybe_put_query(params, _), do: params

  defp maybe_put_project_id(params, %{project_id: id}),
    do: Map.put(params, :"filter[project_id]", to_string(id))

  defp maybe_put_project_id(params, _), do: params

  defp maybe_put_page_size(params, %{page_size: size}),
    do: Map.put(params, :"page[size]", size)

  defp maybe_put_page_size(params, _), do: params

  defp validate_filters(filters) do
    errors =
      %{}
      |> validate_query(filters)
      |> validate_project_id(filters)
      |> validate_page_size(filters)

    if map_size(errors) == 0,
      do: :ok,
      else: {:error, Error.validation_error("task filters", errors)}
  end

  defp validate_query(errors, %{query: query}) when is_binary(query) and query != "", do: errors

  defp validate_query(errors, %{query: _}),
    do: Map.put(errors, :query, "must be a non-empty string")

  defp validate_query(errors, _), do: errors

  defp validate_project_id(errors, %{project_id: id}) when is_binary(id) and id != "", do: errors
  defp validate_project_id(errors, %{project_id: id}) when is_integer(id), do: errors

  defp validate_project_id(errors, %{project_id: _}),
    do: Map.put(errors, :project_id, "must be a non-empty string or integer")

  defp validate_project_id(errors, _), do: errors

  defp validate_page_size(errors, %{page_size: size}) when is_integer(size) and size > 0,
    do: errors

  defp validate_page_size(errors, %{page_size: _}),
    do: Map.put(errors, :page_size, "must be a positive integer")

  defp validate_page_size(errors, _), do: errors
end
