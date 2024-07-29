defmodule TimeUtils do
  def local_now do
    DateTime.now!("Europe/Berlin")
  end
end
