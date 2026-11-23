defmodule PlantAidWeb.UserConfirmationInstructionsLive do
  use PlantAidWeb, :live_view

  alias PlantAid.Accounts
  alias PlantAid.Turnstile

  def render(assigns) do
    ~H"""
    <.header>Resend confirmation instructions</.header>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={@form[:email]} type="email" label="Email" required />
      <.turnstile />
      <:actions>
        <.button phx-disable-with="Sending...">Resend confirmation instructions</.button>
      </:actions>
    </.simple_form>

    <p>
      <.register_or_login />
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}} = params, socket) do
    case Turnstile.verify(params) do
      :ok ->
        send_instructions(email, socket)

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Please complete the verification check and try again.")
         |> push_event("turnstile:reset", %{})}
    end
  end

  defp send_instructions(email, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
