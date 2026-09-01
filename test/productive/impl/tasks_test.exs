defmodule Productive.Impl.TasksTest do
  use ExUnit.Case, async: false

  setup do
    Application.put_env(:productive, :req_options,
      plug: {Req.Test, Productive.Client},
      retry: false
    )

    on_exit(fn -> Application.delete_env(:productive, :req_options) end)

    client =
      Productive.Client.new!(%{
        auth_token: "productive-token",
        person_id: "person-1",
        organization_id: "org-1"
      })

    %{client: client}
  end

  test "get_tasks/2 hits /tasks with the query and page size", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      assert String.ends_with?(conn.request_path, "/tasks")
      decoded = URI.decode_query(conn.query_string)
      assert decoded["filter[query]"] == "PROJ-1"
      assert decoded["page[size]"] == "30"
      refute Map.has_key?(decoded, "filter[project_id]")
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, %{"data" => []}} =
             Productive.get_tasks(client, %{query: "PROJ-1", page_size: 30})
  end

  test "get_tasks/2 encodes filter[project_id]", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      assert URI.decode_query(conn.query_string)["filter[project_id]"] == "project-42"
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, _} =
             Productive.get_tasks(client, %{query: "PROJ-1", project_id: "project-42"})
  end

  test "get_tasks/3 forwards request options to Req", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, _} =
             Productive.get_tasks(client, %{query: "PROJ-1"},
               receive_timeout: 10_000,
               retry: false
             )
  end

  test "get_tasks/2 returns an http error on a non-2xx response", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/vnd.api+json")
      |> Plug.Conn.send_resp(503, Jason.encode!(%{"errors" => []}))
    end)

    assert {:error, %Productive.Error{kind: :http_error, status: 503}} =
             Productive.get_tasks(client, %{query: "PROJ-1"})
  end

  test "get_tasks/2 rejects an empty query", %{client: client} do
    assert {:error, %Productive.Error{kind: :validation_error}} =
             Productive.get_tasks(client, %{query: ""})
  end

  test "get_tasks/2 rejects a bad page size", %{client: client} do
    assert {:error, %Productive.Error{kind: :validation_error}} =
             Productive.get_tasks(client, %{query: "PROJ-1", page_size: 0})
  end

  test "get_tasks/2 rejects a bad project id", %{client: client} do
    assert {:error, %Productive.Error{kind: :validation_error}} =
             Productive.get_tasks(client, %{query: "PROJ-1", project_id: ""})
  end

  test "get_tasks/2 rejects a non-map filter", %{client: client} do
    assert {:error, %Productive.Error{kind: :validation_error}} =
             Productive.get_tasks(client, [])
  end
end
