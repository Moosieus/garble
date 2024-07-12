defmodule GarbleTest do
  use ExUnit.Case
  doctest Garble

  test "greets the world" do
    assert Garble.hello() == :world
  end
end
