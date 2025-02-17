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
