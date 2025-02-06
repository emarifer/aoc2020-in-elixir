defmodule Aoc2020.Problem02 do
  # ================== Start Part 1 ==================
  defp parse_data(line) do
    [policy, char, pass] = line |> String.split()
    [min, max] = policy |> String.split("-") |> Enum.map(&String.to_integer/1)
    char = String.at(char, 0)

    count = pass |> String.graphemes() |> Enum.count(&(&1 == char))

    count >= min && count <= max
  end

  def pass_counter(pass_list) do
    pass_list |> Enum.filter(&parse_data/1) |> length
  end

  # ================== End Part 1 ==================

  # ================== Start Part 2 ==================
  defp parse_rule(line) do
    [p1p2, letter, pass] = line |> String.replace(":", "") |> String.split()
    [p1, p2] = p1p2 |> String.split("-")

    {String.to_integer(p1), String.to_integer(p2), letter, pass}
  end

  defp is_valid?({p1, p2, letter, pass}) do
    has1 = String.at(pass, p1 - 1) == letter
    has2 = String.at(pass, p2 - 1) == letter

    # XOR
    (has1 && !has2) || (has2 && !has1)
  end

  def count_valids(rules) do
    rules
    |> Enum.map(&parse_rule/1)
    |> Enum.filter(&is_valid?/1)
    |> Enum.count()
  end

  # ================== End Part 2 ==================

  # Alternative Part 1
  # defp parse_rule(line) do
  #   [minmax, letter, pass] = line |> String.replace(":", "") |> String.split()
  #   [min, max] = minmax |> String.split("-")

  #   {String.to_integer(min), String.to_integer(max), letter, pass}
  # end

  # defp is_valid?({min, max, letter, pass}) do
  #   freqs = pass |> String.codepoints() |> Enum.frequencies()

  #   case freqs[letter] do
  #     nil -> false
  #     n -> n >= min and n <= max
  #   end
  # end

  # def count_valids(rules) do
  #   rules
  #   |> Enum.map(&parse_rule/1)
  #   |> Enum.filter(&is_valid?/1)
  #   |> Enum.count()
  # end
  # def xor_with(binary, byte) when is_binary(binary) and byte in 0..255 do
  #   for <<b <- binary>>, into: <<>>, do: <<Bitwise.xor(b, byte)>>
  # end
end

{:ok, lines} = Aoc.read_lines("inputs/02.input", "\n")

# Part #1
[["1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc"], lines]
|> Aoc.runner(&Aoc2020.Problem02.pass_counter/1)

# Part #2
[["1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc"], lines]
|> Aoc.runner(&Aoc2020.Problem02.count_valids/1)

# Part #1
# 2 <- Proposed example
# 572 <- Result

# Part #2
# 1 <- Proposed example
# 306 <- Result

# REFERENCES:
# What's the shortest way to count substring occurrence in string?
# https://stackoverflow.com/questions/49535735/whats-the-shortest-way-to-count-substring-occurrence-in-string-elixir
# How to pass arguments to anonymous functions using pipe operator?
# https://stackoverflow.com/questions/37772464/how-to-pass-arguments-to-anonymous-functions-using-pipe-operator
