defmodule Aoc2020.Problem11 do
  # ================== Start Part 1 ==================
  defp make_grid(input) do
    for {row, row_index} <- input |> String.split("\n") |> Enum.with_index(),
        {col, col_index} <- row |> String.codepoints() |> Enum.with_index(),
        into: %{},
        do: {{col_index, row_index}, col}
  end

  defp seat_status(grid, x, y) do
    Map.get(grid, {x, y})
  end

  defp count_occupied_seats(grid) do
    grid
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end

  defp next(grid, switch_fn) do
    new_grid =
      grid
      |> Enum.filter(fn {_k, v} -> v != "." end)
      |> Enum.map(&switch_fn.(grid, &1))
      |> Enum.into(grid)

    if new_grid == grid, do: count_occupied_seats(grid), else: next(new_grid, switch_fn)
  end

  defp switch_status(grid, {{x, y}, status}) do
    adjacent =
      for other_x <- (x - 1)..(x + 1),
          other_y <- (y - 1)..(y + 1),
          {other_x, other_y} != {x, y},
          seat_status(grid, other_x, other_y) == "#" do
        true
      end
      |> length()

    cond do
      status == "#" and adjacent >= 4 -> {{x, y}, "L"}
      status == "L" and adjacent == 0 -> {{x, y}, "#"}
      true -> {{x, y}, status}
    end
  end

  def part1(input) do
    input
    |> make_grid()
    |> next(&switch_status/2)
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp switch_status_2(grid, {pos, status}) do
    in_sight =
      [{-1, -1}, {-1, 0}, {-1, +1}, {0, -1}, {0, +1}, {1, -1}, {1, 0}, {1, 1}]
      |> Enum.map(&in_line_of_sight(grid, pos, &1))
      |> Enum.count(& &1)

    cond do
      status == "#" and in_sight >= 5 -> {pos, "L"}
      status == "L" and in_sight == 0 -> {pos, "#"}
      true -> {pos, status}
    end
  end

  defp in_line_of_sight(grid, {x, y}, dir = {dir_x, dir_y}) do
    {new_x, new_y} = {x + dir_x, y + dir_y}

    case seat_status(grid, new_x, new_y) do
      "#" -> true
      "L" -> false
      nil -> false
      _ -> in_line_of_sight(grid, {new_x, new_y}, dir)
    end
  end

  def part2(input) do
    input
    |> make_grid()
    |> next(&switch_status_2/2)
  end

  # ================== End Part 2 ====================

  # for debugging
  # def visualize_grid(grid) do
  #   max_x = grid |> Enum.map(fn {{x, _y}, _} -> x end) |> Enum.max()
  #   max_y = grid |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.max()

  #   for y <- 0..max_y do
  #     for x <- 0..max_x do
  #       Map.get(grid, {x, y})
  #     end
  #     |> Enum.join()
  #   end
  #   |> Enum.join("\n")
  #   |> IO.puts()
  # end
end

{:ok, sample} = File.read("inputs/sample.seating")
{:ok, real} = File.read("inputs/11.input")

[sample, real]
|> Enum.map(&Aoc2020.Problem11.part1/1)
|> Enum.each(&IO.inspect/1)

[sample, real]
|> Enum.map(&Aoc2020.Problem11.part2/1)
|> Enum.each(&IO.inspect/1)

# Part #1
# 37 <- Proposed example
# 2222 <- real

# Part #2
# 26 <- Proposed example
# 2032 <- real

# sample |> Aoc2020.Problem11.make_grid() |> IO.inspect()

# REFERENCES:
# https://elixirforum.com/t/advent-of-code-2020-day-11/36143/7
