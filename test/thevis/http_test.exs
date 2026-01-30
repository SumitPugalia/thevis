defmodule Thevis.HTTPTest do
  use ExUnit.Case, async: true

  alias Thevis.HTTP

  describe "get/2" do
    test "returns {:ok, body} on 2xx" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/ok", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
      end)

      assert {:ok, body} = HTTP.get("http://localhost:#{bypass.port}/ok")
      assert body["ok"] == true
    end

    test "returns {:error, :not_found} on 404" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/missing", fn conn ->
        Plug.Conn.resp(conn, 404, "Not Found")
      end)

      assert {:error, :not_found} = HTTP.get("http://localhost:#{bypass.port}/missing")
    end

    test "returns {:error, :server_error} on 500" do
      bypass = Bypass.open()
      # Req retries on 5xx, so allow multiple calls
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Error")
      end)

      assert {:error, :server_error} = HTTP.get("http://localhost:#{bypass.port}/error")
    end

    test "returns {:error, :unauthorized} on 401" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/auth", fn conn ->
        Plug.Conn.resp(conn, 401, "Unauthorized")
      end)

      assert {:error, :unauthorized} = HTTP.get("http://localhost:#{bypass.port}/auth")
    end

    test "passes headers and params" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/search", fn conn ->
        assert Plug.Conn.get_req_header(conn, "x-custom") == ["value"]
        assert conn.query_params["q"] == "search"
        Plug.Conn.resp(conn, 200, "ok")
      end)

      assert {:ok, "ok"} =
               HTTP.get("http://localhost:#{bypass.port}/search?q=search",
                 headers: [{"x-custom", "value"}]
               )
    end
  end

  describe "post/2" do
    test "returns {:ok, body} on 2xx with json" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "POST", "/items", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, Jason.encode!(%{"id" => "123"}))
      end)

      assert {:ok, body} =
               HTTP.post("http://localhost:#{bypass.port}/items",
                 json: %{name: "test"},
                 headers: [{"content-type", "application/json"}]
               )

      assert body["id"] == "123"
    end

    test "returns {:error, atom} on 4xx" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "POST", "/items", fn conn ->
        Plug.Conn.resp(conn, 422, Jason.encode!(%{"errors" => []}))
      end)

      assert {:error, :api_error} = HTTP.post("http://localhost:#{bypass.port}/items", json: %{})
    end
  end

  describe "put/2" do
    test "returns {:ok, body} on 200" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "PUT", "/items/1", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"updated" => true}))
      end)

      assert {:ok, body} =
               HTTP.put("http://localhost:#{bypass.port}/items/1", json: %{name: "updated"})

      assert body["updated"] == true
    end
  end

  describe "error atoms" do
    test "connection failure returns {:error, :network_error}" do
      assert {:error, :network_error} = HTTP.get("http://127.0.0.1:0/", receive_timeout: 100)
    end
  end
end
