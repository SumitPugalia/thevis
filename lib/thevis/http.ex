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

  @type error_atom ::
          :not_found
          | :unauthorized
          | :forbidden
          | :redirect
          | :server_error
          | :api_error
          | :timeout
          | :network_error

  @doc """
  Performs an HTTP GET request. Returns `{:ok, body}` or `{:error, atom}`.
  """
  @spec get(String.t(), keyword()) :: {:ok, term()} | {:error, error_atom()}
  def get(url, opts \\ []) do
    request(:get, url, opts)
  end

  @doc """
  Performs an HTTP POST request. Returns `{:ok, body}` or `{:error, atom}`.
  """
  @spec post(String.t(), keyword()) :: {:ok, term()} | {:error, error_atom()}
  def post(url, opts \\ []) do
    request(:post, url, opts)
  end

  @doc """
  Performs an HTTP PUT request. Returns `{:ok, body}` or `{:error, atom}`.
  """
  @spec put(String.t(), keyword()) :: {:ok, term()} | {:error, error_atom()}
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
    log_level = if status >= 500, do: :error, else: :warning

    Logger.log(
      log_level,
      "[Thevis.HTTP] #{method} #{sanitize_url(url)} failed: status=#{status} error=#{error_atom} body=#{inspect_body(body)}"
    )

    {:error, error_atom}
  end

  defp normalize_response(url, method, {:error, reason}) do
    error_atom = reason_to_atom(reason)
    # Connection/timeout failures are errors; log reason without full inspect for structs
    Logger.error(
      "[Thevis.HTTP] #{method} #{sanitize_url(url)} failed: #{error_atom} reason=#{inspect_reason(reason)}"
    )

    {:error, error_atom}
  end

  defp status_to_atom(401), do: :unauthorized
  defp status_to_atom(403), do: :forbidden
  defp status_to_atom(404), do: :not_found
  defp status_to_atom(status) when status >= 300 and status < 400, do: :redirect
  defp status_to_atom(status) when status >= 500 and status < 600, do: :server_error
  defp status_to_atom(_), do: :api_error

  # Req connection errors are structs; map reason to atoms
  defp reason_to_atom(%{reason: :timeout}), do: :timeout
  defp reason_to_atom(%{reason: :closed}), do: :network_error
  defp reason_to_atom(%{reason: :econnrefused}), do: :network_error
  defp reason_to_atom(%{reason: _reason}), do: :network_error
  defp reason_to_atom(%{__struct__: _}), do: :network_error

  defp inspect_body(body) when is_binary(body) do
    case String.length(body) do
      n when n > 500 -> "<<#{n} bytes>>"
      _ -> body
    end
  end

  defp inspect_body(body) when is_map(body) or is_list(body) do
    inspected = inspect(body)
    trimmed = String.slice(inspected, 0, 500)
    if String.length(trimmed) >= 500, do: trimmed <> "...", else: trimmed
  end

  defp inspect_body(body) do
    inspected = inspect(body)
    String.slice(inspected, 0, 500)
  end

  defp inspect_reason(%{__struct__: struct, reason: reason}),
    do: "#{struct} reason=#{inspect(reason)}"

  defp inspect_reason(reason), do: inspect(reason)

  @secret_params ~w(apiKey api_key token key secret)
  defp sanitize_url(url) when is_binary(url) do
    case URI.parse(url) do
      %{query: nil} ->
        url

      %{query: query} = uri ->
        sanitized =
          query
          |> URI.decode_query()
          |> Enum.reject(fn {k, _} ->
            k in @secret_params or String.downcase(k) in @secret_params
          end)
          |> URI.encode_query()

        URI.to_string(%{uri | query: sanitized})
    end
  end
end
