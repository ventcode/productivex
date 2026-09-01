defmodule Productive.Impl.LineItemsTest do
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

  test "get_line_items/2 hits /line_items with paging", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      assert String.ends_with?(conn.request_path, "/line_items")
      decoded = URI.decode_query(conn.query_string)
      assert decoded["page"] == "1"
      assert decoded["per_page"] == "200"
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, _} = Productive.get_line_items(client, %{page: 1})
  end

  test "get_line_items/2 encodes a single filter[invoice_id]", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      assert URI.decode_query(conn.query_string)["filter[invoice_id]"] == "772929"
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, _} = Productive.get_line_items(client, %{invoice_id: "772929", page: 1})
  end

  test "get_line_items/2 comma-joins a list of invoice ids", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      assert URI.decode_query(conn.query_string)["filter[invoice_id]"] == "772929,772913,759439"
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, _} =
             Productive.get_line_items(client, %{
               invoice_id: ["772929", "772913", "759439"],
               page: 1
             })
  end

  test "get_line_items/2 forwards include", %{client: client} do
    Req.Test.stub(Productive.Client, fn conn ->
      assert URI.decode_query(conn.query_string)["include"] == "invoice"
      Req.Test.json(conn, %{"data" => []})
    end)

    assert {:ok, _} =
             Productive.get_line_items(client, %{invoice_id: "1", include: "invoice", page: 1})
  end

  test "get_line_items/2 rejects a bad page", %{client: client} do
    assert {:error, %Productive.Error{kind: :validation_error}} =
             Productive.get_line_items(client, %{page: 0})
  end

  test "get_line_items/2 rejects a non-map filter", %{client: client} do
    assert {:error, %Productive.Error{kind: :validation_error}} =
             Productive.get_line_items(client, [])
  end
end
