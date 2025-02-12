defmodule Aoc2020.Problem09 do
  # ================== Start Part 1 ==================
  def combine(l) do
    for a <- l, b <- l, a != b, do: [a, b] |> Enum.sort() |> List.to_tuple()
  end

  def valid?(window, value) do
    window
    |> combine()
    |> Enum.any?(fn {a, b} -> a + b == value end)
  end

  defp first_invalid(window, input) do
    window..length(input)
    |> Enum.find(fn i ->
      # sliding window:
      slice = Enum.slice(input, i - window, window)
      !valid?(slice, Enum.at(input, i))
    end)
  end

  def run1({window, input}) do
    Enum.at(input, first_invalid(window, input))
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================

  defp find_sequence(v, _, acc, sum_acc) when sum_acc == v,
    do: Enum.max(acc) + Enum.min(acc)

  defp find_sequence(v, t, acc, sum_acc) when sum_acc > v,
    do: find_sequence(v, t, acc |> tl(), sum_acc - List.first(acc))

  defp find_sequence(v, [h | t], acc, sum_acc),
    do: find_sequence(v, t, acc ++ [h], sum_acc + h)

  def run2({window, input}),
    do:
      {window, input}
      |> run1()
      |> find_sequence(input, [], 0)

  # ================== End Part 2 ====================
end

sample = [
  35,
  20,
  15,
  25,
  47,
  40,
  62,
  55,
  65,
  95,
  102,
  117,
  150,
  182,
  127,
  219,
  299,
  277,
  309,
  576
]

{:ok, lines} =
  Aoc.read_lines("inputs/09.input", "\n")
  |> Aoc.fmap(fn item -> Enum.map(item, &String.to_integer/1) end)

set = [{5, sample}, {25, lines}]

# Part #1
set |> Aoc.runner(&Aoc2020.Problem09.run1/1)

# Part #1
set |> Aoc.runner(&Aoc2020.Problem09.run2/1)

# Part #1
# 127 <- Proposed example
# 10884537 <- Result

# Part #2
# 62 <- Proposed example
# 1261309 <- Result

# REFERENCES
# Interesting and idiomatic solution:
# https://elixirforum.com/t/advent-of-code-2020-day-9/36087/11

# Dynamics of the `find_sequence` function with the successive input parameters:
# 35 => 127 [35 | t] [] 0 < 127
# 20 => 127 [20 | t] [35] 35 < 127
# 15 => 127 [15 | t] [35, 20] 55 < 127
# 25 => 127 [25 | t] [35, 20, 15] 70 < 127
# 47 => 127 [47 | t] [35, 20, 15, 25] 105 < 127
# 40 => 127 [40 | t] [35, 20, 15, 25, 47] 142 > 127
# 62 => 127 [62 | t] [20, 15, 25, 47] 107 < 127
# 55 => 127 [62 | t] [20, 15, 25, 47, 40] 147 > 127
# 65 => 127 [62 | t] [15, 25, 47, 40] 127 == 127 ==> 15 (min) + 47 (max) = 62
# 95
# 102
# 117
# 150
# 182
# 127
# 219
# 299
# 277
# 309
# 576
