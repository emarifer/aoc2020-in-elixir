defmodule Aoc2020.Problem12 do
  # ================== Start Part 1 ==================
  defp parse_instruction(line) do
    {instruction, value} = String.split_at(line, 1)
    {instruction, String.to_integer(value)}
  end

  defp to_degree("N"), do: 0
  defp to_degree("E"), do: 90
  defp to_degree("S"), do: 180
  defp to_degree("W"), do: 270

  defp to_direction(i) when i < 0, do: to_direction(i + 360)
  defp to_direction(0), do: "N"
  defp to_direction(90), do: "E"
  defp to_direction(180), do: "S"
  defp to_direction(270), do: "W"

  defp move_ferry({"N", n}, {x, y, dir}), do: {x, y + n, dir}
  defp move_ferry({"S", n}, {x, y, dir}), do: {x, y - n, dir}
  defp move_ferry({"E", n}, {x, y, dir}), do: {x + n, y, dir}
  defp move_ferry({"W", n}, {x, y, dir}), do: {x - n, y, dir}
  defp move_ferry({"F", n}, {x, y, dir}), do: move_ferry({dir, n}, {x, y, dir})

  defp move_ferry({"R", n}, {x, y, dir}) do
    new_dir = dir |> to_degree() |> Kernel.+(n) |> rem(360) |> to_direction()
    {x, y, new_dir}
  end

  defp move_ferry({"L", n}, {x, y, dir}) do
    new_dir = dir |> to_degree() |> Kernel.-(n) |> rem(360) |> to_direction()
    {x, y, new_dir}
  end

  def part1(data) do
    {x, y, _} =
      data
      |> Stream.map(&parse_instruction/1)
      |> Enum.reduce({0, 0, "E"}, &move_ferry/2)

    # Manhattan distance: https://en.wikipedia.org/wiki/Taxicab_geometry
    abs(x) + abs(y)
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================

  defp move_ferry2({"N", n}, {x, y, wx, wy}), do: {x, y, wx, wy + n}
  defp move_ferry2({"S", n}, {x, y, wx, wy}), do: {x, y, wx, wy - n}
  defp move_ferry2({"E", n}, {x, y, wx, wy}), do: {x, y, wx + n, wy}
  defp move_ferry2({"W", n}, {x, y, wx, wy}), do: {x, y, wx - n, wy}
  defp move_ferry2({"R", 90}, {x, y, wx, wy}), do: {x, y, wy, -wx}
  defp move_ferry2({"R", 180}, {x, y, wx, wy}), do: {x, y, -wx, -wy}
  defp move_ferry2({"R", 270}, {x, y, wx, wy}), do: {x, y, -wy, wx}
  defp move_ferry2({"L", n}, acc), do: move_ferry2({"R", 360 - n}, acc)
  defp move_ferry2({"F", n}, {x, y, wx, wy}), do: {x + n * wx, y + n * wy, wx, wy}

  def part2(data) do
    {x, y, _, _} =
      data
      |> Stream.map(&parse_instruction/1)
      |> Enum.reduce({0, 0, 10, 1}, &move_ferry2/2)

    # Manhattan distance: https://en.wikipedia.org/wiki/Taxicab_geometry
    abs(x) + abs(y)
  end

  # ================== End Part 2 ====================
end

sample = """
F10
N3
F7
R90
F11
"""

sample =
  sample
  |> String.split("\n")
  |> Enum.reverse()
  |> tl()
  |> Enum.reverse()

{:ok, lines} =
  Aoc.read_lines("inputs/12.input", "\n")

# Part #1
[sample, lines] |> Aoc.runner(&Aoc2020.Problem12.part1/1)

# Part #2
[sample, lines] |> Aoc.runner(&Aoc2020.Problem12.part2/1)

# Part #1
# 25 <- Proposed example
# 364 <- Result

# Part #2
# 286 <- Proposed example
# 39518 <- Result
