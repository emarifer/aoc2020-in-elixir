defmodule Aoc2020.Problem06 do
  # ================== Start Part 1 ==================
  def response_counter1(data) do
    data
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp parse_group(group) do
    group
    |> Enum.map(&MapSet.new(String.graphemes(&1)))
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.count()
  end

  def response_counter2(data) do
    data
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.filter(&(&1 != [""]))
    |> Enum.map(&parse_group/1)
    |> Enum.sum()
  end

  # ================== End Part 2 ====================
end

{:ok, sample1} = Aoc.read_lines("inputs/sample.customs", "\n\n")
{:ok, lines1} = Aoc.read_lines("inputs/06.input", "\n\n")

{:ok, sample2} = Aoc.read_lines("inputs/sample.customs", "\n")
{:ok, lines2} = Aoc.read_lines("inputs/06.input", "\n")

# Part #1
[sample1, lines1]
|> Aoc.runner(&Aoc2020.Problem06.response_counter1/1)

# Part #2
[sample2, lines2]
|> Aoc.runner(&Aoc2020.Problem06.response_counter2/1)

# Part #1
# 11 <- Proposed example
# 7120 <- Result

# Part #2
# 6 <- Proposed example
# 3570 <- Result

# REFERENCES:
# sample2 |> IO.inspect()
# ["abc", "", "a", "b", "c", "", "ab", "ac", "", "a", "a", "a", "a", "", "b"]

# sample2 |> Enum.chunk_by(&(&1 == "")) |> IO.inspect()
# [
#   ["abc"],
#   [""],
#   ["a", "b", "c"],
#   [""],
#   ["ab", "ac"],
#   [""],
#   ["a", "a", "a", "a"],
#   [""],
#   ["b"]
# ]

# sample2
# |> Enum.chunk_by(&(&1 == ""))
# |> Enum.filter(&(&1 != [""]))
# |> IO.inspect()

# list of groups:
# [["abc"], ["a", "b", "c"], ["ab", "ac"], ["a", "a", "a", "a"], ["b"]]
# Examples by groups:
# ["abc"] |> Enum.map(&MapSet.new(String.graphemes(&1))) |> IO.inspect()
# ["a", "b", "c"] |> Enum.map(&MapSet.new(String.graphemes(&1))) |> IO.inspect()
# ["ab", "ac"] |> Enum.map(&MapSet.new(String.graphemes(&1))) |> IO.inspect()
# [MapSet.new(["a", "b", "c"])]
# [MapSet.new(["a"]), MapSet.new(["b"]), MapSet.new(["c"])]
# [MapSet.new(["a", "b"]), MapSet.new(["a", "c"])]

# [MapSet.new(["a", "b"]), MapSet.new(["a", "c"])]
# MapSet.intersection(MapSet.new(["a", "b"]), MapSet.new(["a", "c"]))
# |> IO.inspect()

# Examples of performing intersection within a group:
# [MapSet.new(["a", "b"]), MapSet.new(["a", "c"])]
# |> Enum.reduce(fn ms, acc -> MapSet.intersection(ms, acc) end)
# |> IO.inspect()
# |> Enum.count()
# |> IO.inspect()

# [MapSet.new(["a", "b", "c"])]
# |> Enum.reduce(fn ms, acc -> MapSet.intersection(ms, acc) end)
# |> IO.inspect()
# |> Enum.count()
# |> IO.inspect()

# [MapSet.new(["a"]), MapSet.new(["b"]), MapSet.new(["c"])]
# |> Enum.reduce(fn ms, acc -> MapSet.intersection(ms, acc) end)
# |> IO.inspect()
# |> Enum.count()
# |> IO.inspect()

# Results:
# MapSet.new(["a"]) => 1
# MapSet.new(["a", "b", "c"]) => 3
# MapSet.new([])=> 0
