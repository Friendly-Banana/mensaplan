defmodule MensaplanWeb.DishLive.DishesComponent do
  alias Mensaplan.Mensa.Dish
  use MensaplanWeb, :live_component
  alias Mensaplan.Mensa
  import MensaplanWeb.Components.Tooltip

  @impl true
  def render(assigns) do
    ~H"""
    <div id="dish-parent" phx-update="stream" class="flex justify-center">
      <.table id="dishes" rows={@dishes}>
        <:col :let={{_id, dish}} label={gettext("Dish")}>
          <.link navigate={~p"/dishes/#{dish.id}"}>
            <p><%= Dish.get_locale_name(dish) %></p>
            <p class="text-sm text-gray-500">
              <%= Gettext.dgettext(MensaplanWeb.Gettext, "dishes", dish.category) %>
            </p>
          </.link>
        </:col>
        <:col :let={{_id, dish}} label={gettext("Price for students")}><%= dish.price %></:col>
        <:col :let={{_id, dish}} :if={!@user} label={gettext("Dishlikes")}><%= dish.likes %></:col>

        <:action :let={{_id, dish}} :if={@user}>
          <%= if dish.user_likes > 0 do %>
            <.link phx-click={JS.push("dish_unlike", value: %{id: dish.id}, target: @myself)}>
              <.icon name="hero-hand-thumb-up-solid" />
            </.link>
          <% else %>
            <.link phx-click={
              JS.push("dish_like", value: %{id: dish.id, like: true}, target: @myself)
            }>
              <.icon name="hero-hand-thumb-up" />
            </.link>
          <% end %>
        </:action>
        <:action :let={{_id, dish}} :if={@user}>
          <.tooltip content="Dishlikes"><%= dish.likes %></.tooltip>
        </:action>
        <:action :let={{_id, dish}} :if={@user}>
          <%= if dish.user_likes < 0 do %>
            <.link phx-click={JS.push("dish_unlike", value: %{id: dish.id}, target: @myself)}>
              <.icon name="hero-hand-thumb-down-solid" />
            </.link>
          <% else %>
            <.link phx-click={
              JS.push("dish_like", value: %{id: dish.id, like: false}, target: @myself)
            }>
              <.icon name="hero-hand-thumb-down" />
            </.link>
          <% end %>
        </:action>
      </.table>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    Phoenix.PubSub.subscribe(Mensaplan.PubSub, "update_dish")
    {:ok, socket}
  end

  @impl true
  def handle_event("dish_like", %{"id" => dish_id, "like" => like}, socket) do
    Mensa.like_dish(socket.assigns.user.id, dish_id, like)
    Phoenix.PubSub.broadcast(Mensaplan.PubSub, "update_dish", {:update_dish, dish_id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("dish_unlike", %{"id" => dish_id}, socket) do
    Mensa.unlike_dish(socket.assigns.user.id, dish_id)
    Phoenix.PubSub.broadcast(Mensaplan.PubSub, "update_dish", {:update_dish, dish_id})
    {:noreply, socket}
  end
end
