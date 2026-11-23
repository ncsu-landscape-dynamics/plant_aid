defmodule PlantAid.Turnstile do
  @moduledoc """
  Cloudflare Turnstile bot check for public forms (registration, forgot password,
  resend confirmation).

  Enabled only when both `TURNSTILE_SITE_KEY` and `TURNSTILE_SECRET_KEY` are set
  (see `config/runtime.exs`). When disabled, `verify/1` always returns `:ok`, so the
  forms keep working without keys.
  """
  require Logger

  @verify_url "https://challenges.cloudflare.com/turnstile/v0/siteverify"

  def enabled?, do: present?(site_key()) and present?(secret_key())

  def site_key, do: config()[:site_key]

  defp secret_key, do: config()[:secret_key]

  defp config, do: Application.get_env(:plant_aid, __MODULE__, [])

  @doc """
  Verifies the token Turnstile adds to the form as `cf-turnstile-response`.
  Accepts the form params map or the token itself.
  """
  def verify(%{} = params), do: verify(Map.get(params, "cf-turnstile-response"))

  def verify(token) do
    cond do
      not enabled?() -> :ok
      not present?(token) -> {:error, :missing_token}
      true -> siteverify(token)
    end
  end

  defp siteverify(token) do
    body = URI.encode_query(%{"secret" => secret_key(), "response" => token})
    headers = [{"content-type", "application/x-www-form-urlencoded"}]
    request = Finch.build(:post, @verify_url, headers, body)

    case Finch.request(request, PlantAid.Finch, receive_timeout: 5_000) do
      {:ok, %Finch.Response{status: 200, body: response}} ->
        case Jason.decode(response) do
          {:ok, %{"success" => true}} ->
            :ok

          {:ok, result} ->
            Logger.info("Turnstile check failed: #{inspect(result["error-codes"])}")
            {:error, :failed}

          {:error, _} ->
            {:error, :failed}
        end

      other ->
        Logger.warning("Turnstile verification request failed: #{inspect(other)}")
        {:error, :unavailable}
    end
  end

  defp present?(value), do: is_binary(value) and value != ""
end
