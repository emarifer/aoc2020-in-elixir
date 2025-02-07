defmodule Aoc2020.Problem03 do
  defp coordinates(n, dx, dy) do
    0..trunc((n - 1) / dy) |> Enum.map(&{dx * &1, dy * &1})
  end

  # If we pass the function a `map` with the distribution of trees
  # (list of list of characters `.`[empty space] or `#`[tree]),
  # it calls the function recursively, but this time passing it
  # the movement rules (tuple {3, 1}), that is,
  # 3 steps to the right and 1 down.
  def count(map), do: count(map, {3, 1})

  def count(map, {dx, dy}) do
    # We calculate the width of our `map`, which, since it repeats
    # `indefinitely` to the right, will be used to calculate
    # the remainder of a division (modulo). We calculate it
    # by counting the length of, e.g., the first row.
    width = map |> Enum.at(0) |> Enum.count()
    # The height is simply the length of the list.
    height = map |> Enum.count()

    # We calculate all pairs of coordinates, which depend
    # on the height and displacement rules ({3, 1}).
    # For such positions, we filter our `map` for those
    # coordinates where there is a `tree` (character `#`)
    # and count the length of the resulting list.
    # We perform the filter with the help of the `AOC.at_map` function,
    # which returns a character given its coordinates.
    # The `y` coordinate is the second component of the coordinate tuple.
    # But the `x` is calculated as a modulus of the width [rem(x, width)],
    # since our `map` is repeated indefinitely to the right
    # (in the direction of the X axis).
    coordinates(height, dx, dy)
    |> Enum.filter(fn {x, y} -> Aoc.at_map(map, rem(x, width), y) == "#" end)
    |> Enum.count()
  end

  def slopes(map, list_slopes) do
    list_slopes
    |> Enum.map(fn s -> count(map, s) end)
    |> Enum.reduce(&(&1 * &2))
  end
end

# TEST:
# 11 rows (coordinates from 0 to 10)
# height = sample |> Enum.count() |> IO.inspect()

# The coordinates of the trajectory
# [{0, 0}, {3, 1}, {6, 2}, {9, 3}, {12, 4}, {15, 5}, {18, 6}, {21, 7}, {24, 8}, {27, 9}, {30, 10}]
# Aoc2020.Problem03.coordinates(height, 3, 1) |> IO.inspect()

{:ok, sample} = Aoc.read_map("inputs/sample.map")
{:ok, lines} = Aoc.read_map("inputs/03.input")
list_slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

# Part #1
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem03.count/1)

# Part #2
map_slopes = &Aoc2020.Problem03.slopes(&1, list_slopes)

[sample, lines]
|> Aoc.runner(fn item -> map_slopes.(item) end)

# Part #1
# 7 <- Proposed example
# 148 <- Result

# Part #2
# 336 <- Proposed example
# 727923200 <- Result
