defmodule Aoc2020.Problem18 do
  # ================= Start Prelude ==================
  def parse_puzzle(path), do: path |> File.stream!() |> Enum.map(&String.trim/1)

  defp parse(data) do
    data
    |> Enum.map(fn line ->
      line
      |> String.replace("(", " ( ")
      |> String.replace(")", " ) ")
      |> String.split(" ", trim: true)
      # `acc` starts with `[]`
      |> parse_line([])
    end)
  end

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================

  # the array of operation lines is exhausted and then
  # the accumulator is reversed and returned.
  defp parse_line([], acc), do: Enum.reverse(acc)

  # a block denoted by `(` is started and acc is started
  # with `[]` for that block (until the block is closed).
  defp parse_line(["(" | rest], acc) do
    {block, rest} = parse_line(rest, [])
    parse_line(rest, [block | acc])
  end

  # the block is closed with `)`; the accumulator is reversed.
  defp parse_line([")" | rest], acc), do: {Enum.reverse(acc), rest}

  defp parse_line([other | rest], acc) do
    # It is called recursively, removing the first element,
    # to exhaust the contents of the line and refill the accumulator.
    parse_line(rest, [
      # the accumulator is being filled
      case Integer.parse(other) do
        :error -> other
        {int, ""} -> int
      end
      | acc
    ])
  end

  defp op1([a, "+", b | rest]), do: op1([op1(a) + op1(b) | rest])
  defp op1([a, "*", b | rest]), do: op1([op1(a) * op1(b) | rest])
  defp op1(x) when is_integer(x), do: x
  defp op1([x]) when is_integer(x), do: x

  def part1(data), do: parse(data) |> Enum.map(&op1/1) |> Enum.sum()

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp op2([a, "+", b | rest]), do: op2([op2(a) + op2(b) | rest])
  defp op2([a, "*", b | rest]), do: op2(a) * op2([op2(b) | rest])
  # ↑↑↑ Here, multiplication has lower precedence than addition, ↑↑↑
  # so we cannot operate in a "line" from left to right,
  # but we have to go all the way to the end in case
  # we find any addition operation (which, in this case,
  # has precedence over multiplication) and perform it first.
  defp op2(x) when is_integer(x), do: x
  defp op2([x]) when is_integer(x), do: x

  def part2(data), do: parse(data) |> Enum.map(&op2/1) |> Enum.sum()

  # ================== End Part 2 ====================
end

sample = """
1 + 2 * 3 + 4 * 5 + 6
1 + (2 * 3) + (4 * (5 + 6))
2 * 3 + (4 * 5)
5 + (8 * 3 + 9 + 3 * 4 * 3)
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
"""

sample
|> String.split("\n", trim: true)
|> Aoc2020.Problem18.part1()
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem18.parse_puzzle("inputs/18.input")
|> Aoc2020.Problem18.part1()
|> IO.inspect(label: "part1/puzzle")

sample
|> String.split("\n", trim: true)
|> Aoc2020.Problem18.part2()
|> IO.inspect(label: "part2/sample")

Aoc2020.Problem18.parse_puzzle("inputs/18.input")
|> Aoc2020.Problem18.part2()
|> IO.inspect(label: "part2/puzzle")

# Part #1
# part1/sample: 26457
# part1/puzzle: 12918250417632

# Part #1
# part2/sample: 694173
# part2/puzzle: 171259538712010

# REFERENCES:
# https://elixirforum.com/t/advent-of-code-2020-day-18/36300/6
