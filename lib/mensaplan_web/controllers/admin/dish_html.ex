defmodule MensaplanWeb.Admin.DishHTML do
  use MensaplanWeb, :html

  embed_templates "dish_html/*"

  @doc """
  Renders a dish form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def dish_form(assigns)
end
