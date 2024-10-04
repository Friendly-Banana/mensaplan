defmodule MensaplanWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use MensaplanWeb, :html
  import Mensaplan.Helpers

  embed_templates "page_html/*"
end
