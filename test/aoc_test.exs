defmodule AocTest do
  use ExUnit.Case

  doctest Aoc

  test "read_lines read lines" do
    assert Aoc.read_lines("test/lines.txt") == {:ok, ["789793", "8080", "25344"]}
    assert Aoc.read_lines("test/lines.fake") == {:error, :enoent}
  end

  test "read_map read maps" do
    assert Aoc.read_map("test/map.txt") ==
             {:ok,
              [
                [".", ".", "."],
                ["#", ".", "."],
                [".", "#", "#"]
              ]}

    assert Aoc.read_map("test/map.fake") == {:error, :enoent}
  end

  test "at_map gets coordinates" do
    {:ok, map} = Aoc.read_map("test/map.txt")
    assert Aoc.at_map(map, 0, 0) == "."
    assert Aoc.at_map(map, 0, 1) == "#"
    assert Aoc.at_map(map, 2, 2) == "#"
  end

  test "fmap aplies to :ok tuples" do
    # double = fn n -> n * 2 end
    # https://hexdocs.pm/elixir/Function.html#module-the-capture-operator
    double = &(&1 * 2)
    assert Aoc.fmap({:ok, 4}, double) == {:ok, 8}
    assert Aoc.fmap({:error, :enoent}, double) == {:error, :enoent}
  end
end
