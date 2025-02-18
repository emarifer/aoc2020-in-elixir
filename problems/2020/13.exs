defmodule Aoc2020.Problem13 do
  # ================== Start Part 1 ==================
  def part1(data) do
    [departure, busses] = data

    departure = String.to_integer(departure)

    id =
      busses
      |> String.split(",")
      |> Stream.reject(&(&1 == "x"))
      |> Stream.map(&String.to_integer/1)
      |> Enum.min_by(&(&1 - rem(departure, &1)))

    wait = id - rem(departure, id)

    id * wait
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================

  # Least Common Multiple
  defp lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  def part2(data) do
    [_, busses] = data

    busses
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.reject(fn {id, _} -> id == "x" end)
    |> Enum.reduce({0, 1}, fn {bus, index}, {t, step} ->
      bus = String.to_integer(bus)

      # t + index => gap induced jump (= "x")
      t =
        Stream.unfold(t, fn t -> {t, t + step} end)
        |> Stream.filter(fn t -> rem(t + index, bus) == 0 end)
        |> Enum.at(0)

      {t, lcm(step, bus)}
    end)
    |> elem(0)
  end

  # ================== End Part 2 ====================
end

sample = """
939
7,13,x,x,59,x,31,19
"""

sample =
  sample
  |> String.split("\n")
  |> Enum.reverse()
  |> tl()
  |> Enum.reverse()

{:ok, lines} =
  Aoc.read_lines("inputs/13.input", "\n")

# Part #1
[sample, lines] |> Aoc.runner(&Aoc2020.Problem13.part1/1)

# Part #2
[sample, lines] |> Aoc.runner(&Aoc2020.Problem13.part2/1)

# Part #1
# 295 <- Proposed example
# 3882 <- Result

# Part #2
# 1068781 <- Proposed example
# 867295486378319 <- Result

# REFERENCES:
# 7 - 939 mod 7 = 6
# 13 - 939 mod 13 = 10
# 59 - 939 mod 59 = 5
# 31 - 939 mod 31 = 22
# 19 - 939 mod 19 = 11

# iex(5)> Stream.unfold(0, fn t -> {t, t+3} end) |> Enum.at(5)
# 15
# iex(6)> Stream.unfold(0, fn t -> {t, t+3} end) |> Enum.take(5)
# [0, 3, 6, 9, 12]

# iex(3)> "7,13,x,x,59,x,31,19" |> String.split(",") |> Enum.with_index()
# [
#   {"7", 0},
#   {"13", 1},
#   {"x", 2},
#   {"x", 3},
#   {"59", 4},
#   {"x", 5},
#   {"31", 6},
#   {"19", 7}
# ]
# iex(4)> "7,13,x,x,59,x,31,19" |> String.split(",") |> Enum.with_index() |> Enum.reject(fn {id, _} -> id == "x" end)
# [{"7", 0}, {"13", 1}, {"59", 4}, {"31", 6}, {"19", 7}]

# iex(7)> Stream.unfold(0, fn t -> {t, t + 1} end) |> Stream.filter(fn t -> rem(t + 0, 7) == 0 end) |> Enum.at(0)
# 0
# iex(8)> Stream.unfold(0, fn t -> {t, t + 7} end) |> Stream.filter(fn t -> rem(t + 1, 13) == 0 end) |> Enum.at(0)
# {77, lcm(7, 13) == 91}

# Explanation:
# since 77 mod 13 == 12, if bus `13` leaves 1 minute later,
# i.e. at timestamp 78 (78 mod 13 == 0),
# it would be in accordance with the statement.
# The new step is calculated by the least common multiple
# 77 => 7
# 78 => 13

# iex(9)> Stream.unfold(77, fn t -> {t, t + 91} end) |> Stream.filter(fn t -> rem(t + 4, 59) == 0 end) |> Enum.at(0)
# 350 + 4 = 359 mod 50 == 0,
# That is to say, at this point the bus departure would be as follows:
# 350 => 7
# 351 => 13
# 352 => x
# 353 => x
# 354 => 59

# Another example: 17,x,13,19
# Stream.unfold(0, fn t -> {t, t + 1} end) |> Stream.filter(fn t -> rem(t + 0, 17) == 0 end) |> Enum.at(0)

# {0, lcm(1,17)=17}

# Stream.unfold(0, fn t -> {t, t + 17} end) |> Stream.filter(fn t -> rem(t + 2, 13) == 0 end) |> Enum.at(0)

# {102, lcm(17,13)=221}

# Stream.unfold(102, fn t -> {t, t + 221} end) |> Stream.filter(fn t -> rem(t + 3, 19) == 0 end) |> Enum.at(0)

# {3417, lcm(13,19)=247}
# 3417 => 17
# 3418 => x
# 3419 => 13
# 3420 => 19

# https://elixirforum.com/t/advent-of-code-2020-day-13/36180/11
# https://github.com/LostKobrakai/aoc2020/blob/master/lib/aoc2020/day13.ex

# https://en.wikipedia.org/wiki/Chinese_remainder_theorem
# https://en.wikipedia.org/wiki/Coprime_integers#Coprimality_in_sets
# https://rosettacode.org/wiki/Chinese_remainder_theorem#Elixir
# https://brilliant.org/wiki/chinese-remainder-theorem/
