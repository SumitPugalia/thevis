defmodule Thevis.HTTP do
  @moduledoc """
  Shared HTTP client for external service calls.

  - Returns `{:ok, body}` on 2xx (response body only).
  - Returns `{:error, atom}` on failure; logs the error and normalizes to an atom.
  - Default `receive_timeout` is 30_000 ms.

  ## Options (for get/2, post/2, put/2)

  - `:headers` - list of `{name, value}` request headers
  - `:body` - raw request body (binary)
  - `:json` - request body as map (JSON-encoded automatically)
  - `:params` - keyword list for query string or form params
  - `:receive_timeout` - timeout in ms (default: 30_000)

  ## Error atoms

  - `:not_found` - 404
  - `:unauthorized` - 401
  - `:forbidden` - 403
  - `:redirect` - 3xx
  - `:server_error` - 5xx
  - `:api_error` - other 4xx
  - `:timeout` - request timeout
  - `:network_error` - connection/Req errors

  ## Examples

      case Thevis.HTTP.get("https://api.example.com/resource", headers: [{"Authorization", "Bearer token"}]) do
        {:ok, body} -> process(body)
        {:error, :not_found} -> ...
        {:error, :timeout} -> ...
      end

      case Thevis.HTTP.post(url, json: %{key: "value"}, headers: headers) do
        {:ok, body} -> ...
        {:error, reason} -> ...
      end
  """

  require Logger

  @default_receive_timeout 30_000

  @doc """
  Performs an HTTP GET request. Returns `{:ok, body}` or `{:error, atom}`.
  """
  def get(url, opts \\ []) do
    request(:get, url, opts)
  end

  @doc """
  Performs an HTTP POST request. Returns `{:ok, body}` or `{:error, atom}`.
  """
  def post(url, opts \\ []) do
    request(:post, url, opts)
  end

  @doc """
  Performs an HTTP PUT request. Returns `{:ok, body}` or `{:error, atom}`.
  """
  def put(url, opts \\ []) do
    request(:put, url, opts)
  end

  defp request(method, url, opts) do
    req_opts = build_req_opts(opts)

    result =
      case method do
        :get -> Req.get(url, req_opts)
        :post -> Req.post(url, req_opts)
        :put -> Req.put(url, req_opts)
      end

    normalize_response(url, method, result)
  end

  defp build_req_opts(opts) do
    opts
    |> maybe_add_timeout()
    |> Keyword.take([:headers, :body, :json, :params, :receive_timeout])
  end

  defp maybe_add_timeout(opts) do
    case Keyword.has_key?(opts, :receive_timeout) do
      true -> opts
      false -> Keyword.put(opts, :receive_timeout, @default_receive_timeout)
    end
  end

  defp normalize_response(_url, _method, {:ok, %{status: status, body: body}})
       when status >= 200 and status < 300 do
    {:ok, body}
  end

  defp normalize_response(url, method, {:ok, %{status: status, body: body}}) do
    error_atom = status_to_atom(status)

    Logger.warning(
      "[Thevis.HTTP] #{method} #{url} failed: status=#{status} error=#{error_atom} body=#{inspect_body(body)}"
    )

    {:error, error_atom}
  end

  defp normalize_response(url, method, {:error, reason}) do
    error_atom = reason_to_atom(reason)

    Logger.warning(
      "[Thevis.HTTP] #{method} #{url} failed: #{error_atom} reason=#{inspect(reason)}"
    )

    {:error, error_atom}
  end

  defp status_to_atom(401), do: :unauthorized
  defp status_to_atom(403), do: :forbidden
  defp status_to_atom(404), do: :not_found
  defp status_to_atom(status) when status >= 300 and status < 400, do: :redirect
  defp status_to_atom(status) when status >= 500 and status < 600, do: :server_error
  defp status_to_atom(_), do: :api_error

  defp reason_to_atom(%{reason: :timeout}), do: :timeout
  defp reason_to_atom(%{reason: reason}) when is_atom(reason), do: reason
  defp reason_to_atom(%{__struct__: _}), do: :network_error
  defp reason_to_atom(:timeout), do: :timeout
  defp reason_to_atom(_reason), do: :network_error

  defp inspect_body(body) when is_binary(body) do
    case String.length(body) do
      n when n > 500 -> "<<#{n} bytes>>"
      _ -> body
    end
  end

  defp inspect_body(body), do: inspect(body)
end
