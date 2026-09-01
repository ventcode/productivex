# Productive

A small Elixir client for the Productive REST API used by `intranet`.

## Installation

Add `productive` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:productive, git: "https://github.com/<org>/productive.git", tag: "v0.1.0"}
  ]
end
```

## Usage

```elixir
client =
  Productive.Client.new!(%{
    auth_token: "...",
    person_id: "...",
    organization_id: "..."
  })

{:ok, %{"data" => projects}} = Productive.get_projects(client, 1)
{:ok, %{"data" => entries}} =
  Productive.get_time_entries(client, %{
    project_id: "project-1",
    from: ~D[2026-03-01],
    to: ~D[2026-03-09],
    page: 1
  })
```

Public functions return `{:ok, decoded_body}` or `{:error, %Productive.Error{}}`.
Bang variants such as `Productive.get_projects!/2` and `Productive.Client.new!/1`
raise `Productive.Error`.

`Productive.get_services/3` currently applies `filter[budget_status]=1` and returns
budgeted services for the given project.

`Productive.get_tasks/3` searches tasks (`filter[query]`, `filter[project_id]`,
`page[size]`). The optional third argument is forwarded to `Req`, e.g.
`receive_timeout: 10_000, retry: false`.

## Error handling

```elixir
case Productive.create_time_entry(client, %{date: Date.utc_today(), time: 60, note: "", service_id: "123"}) do
  {:ok, body} ->
    body

  {:error, %Productive.Error{kind: :http_error, status: 422, body: body}} ->
    body

  {:error, %Productive.Error{} = error} ->
    raise error
end
```

## Development

```bash
mix deps.get
mix test
```
