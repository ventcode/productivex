defmodule Productive do
  @moduledoc """
  Productive REST API client.
  """

  alias Productive.Impl.{Companies, Invoices, LineItems, Projects, Services, Tasks, TimeEntries}
  alias Productive.{Client, Error}

  @type result :: {:ok, map()} | {:error, Error.t()}

  @spec create_time_entry(Client.t(), TimeEntries.time_entry()) :: result()
  def create_time_entry(client, time_entry), do: TimeEntries.create(client, time_entry)

  @spec create_time_entry!(Client.t(), TimeEntries.time_entry()) :: map()
  def create_time_entry!(client, time_entry), do: unwrap!(create_time_entry(client, time_entry))

  @spec delete_time_entry(Client.t(), TimeEntries.id()) :: :ok | {:error, Error.t()}
  def delete_time_entry(client, id), do: TimeEntries.delete(client, id)

  @spec delete_time_entry!(Client.t(), TimeEntries.id()) :: :ok
  def delete_time_entry!(client, id) do
    case delete_time_entry(client, id) do
      :ok -> :ok
      {:error, %Error{} = error} -> raise error
    end
  end

  @spec get_time_entries(Client.t(), TimeEntries.list_filters()) :: result()
  def get_time_entries(client, filters), do: TimeEntries.get_list(client, filters)

  @spec get_time_entries!(Client.t(), TimeEntries.list_filters()) :: map()
  def get_time_entries!(client, filters), do: unwrap!(get_time_entries(client, filters))

  @spec get_projects(Client.t(), pos_integer()) :: result()
  def get_projects(client, page), do: Projects.get_list(client, page)

  @spec get_projects!(Client.t(), pos_integer()) :: map()
  def get_projects!(client, page), do: unwrap!(get_projects(client, page))

  @doc """
  Returns budgeted services for a project.
  """
  @spec get_services(Client.t(), String.t() | integer(), pos_integer()) :: result()
  def get_services(client, project_id, page), do: Services.get_list(client, project_id, page)

  @spec get_services!(Client.t(), String.t() | integer(), pos_integer()) :: map()
  def get_services!(client, project_id, page), do: unwrap!(get_services(client, project_id, page))

  @spec get_invoices(Client.t(), Invoices.list_filters()) :: result()
  def get_invoices(client, filters), do: Invoices.get_list(client, filters)

  @spec get_invoices!(Client.t(), Invoices.list_filters()) :: map()
  def get_invoices!(client, filters), do: unwrap!(get_invoices(client, filters))

  @spec get_invoice(Client.t(), Invoices.id(), Invoices.get_opts()) :: result()
  def get_invoice(client, id, opts \\ []), do: Invoices.get(client, id, opts)

  @spec get_invoice!(Client.t(), Invoices.id(), Invoices.get_opts()) :: map()
  def get_invoice!(client, id, opts \\ []), do: unwrap!(get_invoice(client, id, opts))

  @spec get_companies(Client.t(), Companies.list_filters()) :: result()
  def get_companies(client, filters), do: Companies.get_list(client, filters)

  @spec get_companies!(Client.t(), Companies.list_filters()) :: map()
  def get_companies!(client, filters), do: unwrap!(get_companies(client, filters))

  @spec get_line_items(Client.t(), LineItems.list_filters()) :: result()
  def get_line_items(client, filters), do: LineItems.get_list(client, filters)

  @spec get_line_items!(Client.t(), LineItems.list_filters()) :: map()
  def get_line_items!(client, filters), do: unwrap!(get_line_items(client, filters))

  @doc """
  Searches tasks. `req_options` are forwarded to `Req` (e.g. `receive_timeout`,
  `retry`).
  """
  @spec get_tasks(Client.t(), Tasks.list_filters(), keyword()) :: result()
  def get_tasks(client, filters, req_options \\ []),
    do: Tasks.get_list(client, filters, req_options)

  @spec get_tasks!(Client.t(), Tasks.list_filters(), keyword()) :: map()
  def get_tasks!(client, filters, req_options \\ []),
    do: unwrap!(get_tasks(client, filters, req_options))

  @spec get_company(Client.t(), Companies.id()) :: result()
  def get_company(client, id), do: Companies.get(client, id)

  @spec get_company!(Client.t(), Companies.id()) :: map()
  def get_company!(client, id), do: unwrap!(get_company(client, id))

  defp unwrap!({:ok, body}), do: body
  defp unwrap!({:error, %Error{} = error}), do: raise(error)
end
