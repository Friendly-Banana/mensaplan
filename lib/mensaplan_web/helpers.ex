defmodule Mensaplan.Helpers do
  def local_now do
    DateTime.now!("Europe/Berlin")
  end

  def change_locale(conn, old, new_locale) do
    current_path = Phoenix.Controller.current_path(conn)
    String.replace_prefix(current_path, "/#{old}", "/#{new_locale}")
  end

  def locale_patch(url) do
    Phoenix.LiveView.JS.patch("/" <> Gettext.get_locale() <> url)
  end

  @doc """
  Generates src, srcset and sizes attributes for an image tag.
  Images can be done with the following command:

  `export S=1000 && convert -resize $S people-eating.jpg sized/people-eating-$S.avif`
  """
  defmacro image_sizes(name, sizes \\ [600, 1000, 2000]) do
    fallback = "/images/sized/#{name}-#{List.first(sizes)}.avif"

    srcset =
      Enum.map(sizes, fn size ->
        "/images/sized/#{name}-#{size}.avif #{size}w"
      end)

    sizes =
      Enum.map(Enum.drop(sizes, -1), fn size ->
        "(max-width: #{size}px) #{size}w"
      end) ++ [Integer.to_string(List.last(sizes)) <> "w"]

    quote do
      %{
        src: unquote(fallback),
        srcset: unquote(Enum.join(srcset, ", ")),
        sizes: unquote(Enum.join(sizes, ", "))
      }
    end
  end
end
