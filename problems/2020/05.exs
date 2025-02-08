defmodule Aoc2020.Problem05 do
  # ================== Start Part 1 ==================
  defp convert_string(boarding_pass) do
    boarding_pass
    |> String.replace(["F", "L"], "0")
    |> String.replace(["B", "R"], "1")
  end

  defp seat_id(boarding_pass) do
    str = boarding_pass |> convert_string()

    row =
      str
      |> String.slice(0, 7)
      |> Integer.parse(2)
      |> elem(0)

    column =
      str
      |> String.slice(7, 9)
      |> Integer.parse(2)
      |> elem(0)

    row * 8 + column
  end

  def problem1(list) do
    list
    |> Stream.map(&seat_id/1)
    |> Enum.max()
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp find_middle_seat([prev, next | _]) when next - prev == 2, do: next - 1

  defp find_middle_seat([_ | next]), do: find_middle_seat(next)

  def problem2(list) do
    list
    |> Stream.map(&seat_id/1)
    |> Enum.sort()
    |> find_middle_seat()
  end

  # ================== End Part 2 ====================
end

cases = [
  "FBFBBFFRLR",
  "BFFFBBFRRR",
  "FFFBBBFRRR",
  "BBFFBBFRLL"
]

{:ok, lines} = Aoc.read_lines("inputs/05.input", "\n")

# Part #1
[cases, lines]
|> Aoc.runner(&Aoc2020.Problem05.problem1/1)

# Part #2
[lines]
|> Aoc.runner(&Aoc2020.Problem05.problem2/1)

# Part #1
# 820 <- Proposed example
# 813 <- Result

# Part #2
# 612 <- Result

# REFERENCES:
# How to convert a binary to a base10 (decimal) integer in elixir
# https://stackoverflow.com/questions/54441543/how-to-convert-a-binary-to-a-base10-decimal-integer-in-elixir
