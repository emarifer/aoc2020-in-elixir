defmodule Aoc2020.Problem10 do
  # ================== Start Part 1 ==================
  def run1(adapters) do
    sorted = [0] ++ Enum.sort(adapters)
    members = MapSet.new(sorted)

    {t1, _, t3} =
      Enum.reduce(sorted, {0, 0, 0}, fn next, {j1, j2, j3} ->
        cond do
          MapSet.member?(members, next + 1) -> {j1 + 1, j2, j3}
          MapSet.member?(members, next + 2) -> {j1, j2 + 1, j3}
          MapSet.member?(members, next + 3) -> {j1, j2, j3 + 1}
          next == Enum.max(sorted) -> {j1, j2, j3 + 1}
        end
      end)

    t1 * t3
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  # defp update(acc, v, delta) do
  #   case acc[v + delta] do
  #     nil -> acc
  #     delta_v -> Map.update(acc, v, 1, fn x -> x + delta_v end)
  #   end
  # end

  # defp print(m, n), do: m[n]

  # defp execute(lst) do
  #   # (lst ++ [List.last(lst) + 3])
  #   # |> Enum.reduce(%{0 => 1}, fn o, acc ->
  #   #   acc |> Map.put(o, 0) |> update(o, -3) |> update(o, -2) |> update(o, -1)
  #   # end)
  #   # |> print(List.last(lst) + 3)

  #   lst
  #   |> Enum.reduce(%{0 => 1}, fn o, acc ->
  #     acc |> Map.put(o, 0) |> update(o, -3) |> update(o, -2) |> update(o, -1)
  #   end)
  #   |> print(List.last(lst))
  # end

  def run2(adapters) do
    # Enum.sort(adapters)
    # |> execute()
    data = Enum.sort([0 | adapters], :desc)

    Enum.reduce(data, %{(hd(data) + 3) => 1}, fn i, memo ->
      Map.put(memo, i, Enum.sum(Enum.map(1..3, &Map.get(memo, i + &1, 0))))
    end)[0]
  end

  # ================== End Part 2 ====================
end

sample1 = [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4]

{:ok, sample2} =
  Aoc.read_lines("inputs/sample2.adapters", "\n")
  |> Aoc.fmap(fn item -> Enum.map(item, &String.to_integer/1) end)

{:ok, lines} =
  Aoc.read_lines("inputs/10.input", "\n")
  |> Aoc.fmap(fn item -> Enum.map(item, &String.to_integer/1) end)

# Part #1
[sample1, sample2, lines] |> Aoc.runner(&Aoc2020.Problem10.run1/1)

# Part #2
[sample1, sample2, lines] |> Aoc.runner(&Aoc2020.Problem10.run2/1)

# Part #1
# 35 <- Proposed example1
# 220 <- Proposed example2
# 2030 <- Result

# Part #2
# 8 <- Proposed example1
# 19208 <- Proposed example2
# 42313823813632 <- Result

# REFERENCES:
# https://elixirforum.com/t/advent-of-code-2020-day-10/36119/23
# https://elixirforum.com/t/advent-of-code-2020-day-10/36119/24
# https://elixirforum.com/t/advent-of-code-2020-day-10/36119/12
