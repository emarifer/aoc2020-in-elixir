defmodule Aoc2020.Problem15 do
  # ========= The quickest solution: bossek ==========
  def go do
    # 261_214 = solve([1, 2, 3])
    solve([2, 0, 1, 7, 4, 14, 18])
  end

  defp solve(already_spoken) do
    start = Enum.count(already_spoken) + 1
    stop = 30_000_000

    spoken = :atomics.new(stop, [])
    # Fill already spoken, n is stored with index n + 1 (atomics mem starts at 1).
    Enum.each(Enum.with_index(already_spoken, 1), fn {n, turn} ->
      :atomics.put(spoken, n + 1, turn)
    end)

    run(start, stop, Enum.at(already_spoken, -1), start - 1, spoken)
  end

  defp run(turn, stop, _last, before, spoken) when turn <= stop do
    # last |> (&IO.write("#{&1}, ")).()
    # Show Van Eck’s Sequence

    if before == turn - 1 do
      before = :atomics.exchange(spoken, 0 + 1, turn)
      run(turn + 1, stop, 0, (before == 0 && turn) || before, spoken)
    else
      n = turn - 1 - before
      before = :atomics.exchange(spoken, n + 1, turn)
      run(turn + 1, stop, n, (before == 0 && turn) || before, spoken)
    end
  end

  defp run(turn, stop, last, _before, _spoken) when turn > stop do
    # last |> (&IO.write("#{&1}, ")).()
    # Show Van Eck’s Sequence

    last
  end

  # def go do
  #   solve([2, 0, 1, 7, 4, 14, 18]) |> elem(0)
  # end

  # defp solve(already_spoken) do
  #   start = Enum.count(already_spoken) + 1
  #   stop = 30_000_000

  #   # Assumes last spoken was spoken for the first time.
  #   last = {Enum.at(already_spoken, -1), start - 1}

  #   spoken = :atomics.new(stop, [])
  #   # Fill already spoken, n is stored with index n + 1 (atomics mem starts at 1).
  #   Enum.each(Enum.with_index(already_spoken, 1), fn {n, turn} ->
  #     :atomics.put(spoken, n + 1, turn)
  #   end)

  #   Enum.reduce(start..stop, last, fn turn, {_last, before} ->
  #     if before == turn - 1 do
  #       before = :atomics.exchange(spoken, 0 + 1, turn)
  #       {0, (before == 0 && turn) || before}
  #     else
  #       n = turn - 1 - before
  #       before = :atomics.exchange(spoken, n + 1, turn)
  #       {n, (before == 0 && turn) || before}
  #     end
  #   end)
  # end

  # ==================== End =========================

  # =============== Damirados Solution ===============
  @test [0, 3, 6]
  @test2 [2, 1, 3]
  @puzzle [2, 0, 1, 7, 4, 14, 18]

  def run do
    IO.puts("Test part1: #{solve(@test, 2020)}")
    IO.puts("Test2 part1: #{solve(@test2, 2020)}")
    IO.puts("Puzzle part1: #{solve(@puzzle, 2020)}")

    before_t = :os.system_time(:millisecond)

    IO.puts(
      "part2/sample: #{solve(@test, 30_000_000)} in #{:os.system_time(:millisecond) - before_t} ms"
    )

    # before_t = :os.system_time(:millisecond)

    # IO.puts(
    #   "part2/real: #{solve(@puzzle, 30_000_000)} in #{:os.system_time(:millisecond) - before_t} ms"
    # )
  end

  defp solve(numbers, x) do
    map = numbers |> Enum.with_index(1) |> Enum.into(%{})
    find_xth(map, 0, map_size(map) + 1, x)
  end

  defp find_xth(_map, last, count, count), do: last

  defp find_xth(map, last, count, x) do
    case Map.get(map, last) do
      nil ->
        find_xth(Map.put(map, last, count), 0, count + 1, x)

      index ->
        find_xth(Map.put(map, last, count), count - index, count + 1, x)
    end
  end

  # ================== End ===========================

  # ============== akash-akya Solution ===============
  defp next_turn(_hist, last, max_turns, max_turns), do: last

  defp next_turn(hist, last, turn, max_turns) do
    case :ets.lookup(hist, last) do
      [] ->
        true = :ets.insert(hist, {last, turn})
        next_turn(hist, 0, turn + 1, max_turns)

      [{_, prev_turn}] ->
        true = :ets.insert(hist, {last, turn})
        next_turn(hist, turn - prev_turn, turn + 1, max_turns)
    end
  end

  def run2(input, max_turns) do
    hist = :ets.new(:hist, [])
    true = :ets.insert(hist, Enum.with_index(input, 1))
    next_turn(hist, List.last(input), length(input), max_turns)
  end

  # ==================== End ======================

  # ============== Makigas Solution ===============

  defp init(input) do
    memory =
      input
      |> Enum.with_index()
      |> Enum.map(fn {inp, turn} -> {inp, [turn + 1]} end)
      |> Map.new()

    last = input |> Enum.reverse() |> hd
    {length(input) + 1, memory, last}
  end

  defp last(memory, k, v) do
    case memory[k] do
      nil -> Map.put(memory, k, [v])
      [l | _] -> Map.put(memory, k, [v, l])
    end
  end

  defp turn({n, memory, last}) do
    if length(memory[last]) < 2 do
      new_memory = last(memory, 0, n)
      {n + 1, new_memory, 0}
    else
      [a, b | _] = memory[last]
      new_memory = last(memory, a - b, n)
      {n + 1, new_memory, a - b}
    end
  end

  def p1(input, t_end) do
    # input |> hd |> (&IO.write("#{&1}, ")).()
    # ↑↑ Show Van Eck’s Sequence ↑↑

    Stream.unfold(init(input), fn {n, memory, last} ->
      next_turn = turn({n, memory, last})
      # ↓↓ Show Van Eck’s Sequence ↓↓
      # next_turn |> elem(2) |> (&IO.write("#{&1}, ")).()
      {next_turn, next_turn}
    end)
    |> Enum.find(fn {t, _, _} -> t == t_end + 1 end)
    |> elem(2)
  end

  # ==================== End ======================
end

# Aoc2020.Problem15.run()

# sample1 = [0, 3, 6]
# sample2 = [2, 1, 3]
# input = [2, 0, 1, 7, 4, 14, 18]

before_t = :os.system_time(:millisecond)

# Aoc2020.Problem15.run2(sample1, 2020)
# |> (&IO.puts("part1/sample1: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Aoc2020.Problem15.run2(sample2, 2020)
# |> (&IO.puts("part1/sample2: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Aoc2020.Problem15.run2(input, 2020)
# |> (&IO.puts("part1/real: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Aoc2020.Problem15.run2(sample1, 30_000_000)
# |> (&IO.puts("part2/sample1: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Aoc2020.Problem15.run2(sample2, 30_000_000)
# |> (&IO.puts("part2/sample2: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Aoc2020.Problem15.run2(input, 30_000_000)
# |> (&IO.puts("part2/real: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# ============================= Solutions =============================
# bossek
Aoc2020.Problem15.go()
|> (&IO.puts("\n\npart2/real: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Makigas
# input
# |> Aoc2020.Problem15.p1(30_000_000)
# |> (&IO.puts("part2/real: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# Makigas
# Show Van Eck’s Sequence (First 25 terms)
# [0]
# |> Aoc2020.Problem15.p1(25)
# |> (&IO.puts("\n\npart2/real: #{&1} in #{:os.system_time(:millisecond) - before_t} ms")).()

# == The quickest solution (bossek) ==
# part2/real: 883 in 1346 ms
# ====================================

# ======== Makigas solution: =========
# part1/real: 496 in 1 ms
# part2/real: 883 in 53640 ms (slower)
# ====================================

# =====================================================================

# ======== Other solutions ===========
# Part #1
# part1/sample1: 436 in 0 ms
# part1/sample2: 10 in 0 ms
# part1/real: 496 in 0 ms

# Part #2
# part2/sample1: 175594 in 8256 ms
# part2/sample2: 3544142 in 8205 ms
# part2/real: 883 in 8148 ms
# ====================================

# Test part1: 436
# Test2 part1: 10
# Puzzle part1: 496
# part2/sample: 175594 in 48022 ms
# part2/real: 883 in 48523 ms

# REFERENCES:
# The quickest solution:
# https://elixirforum.com/t/advent-of-code-2020-day-15/36228/30
# https://gist.github.com/bossek/ec02ce15faf5aa11628e849830010c64
# https://gist.github.com/bossek/978d81ef9111629bfa3838e111e88ad8
# https://www.erlang.org/doc/apps/erts/atomics.html

# Other solutions:
# https://elixirforum.com/t/advent-of-code-2020-day-15/36228/23
# https://elixirforum.com/t/advent-of-code-2020-day-15/36228/7

# https://oeis.org/A181391
# https://metatutor.co.uk/van-ecks-sequence/
# Print to stdout without line break using IO.puts in elixir:
# https://stackoverflow.com/questions/57135025/print-to-stdout-without-line-break-using-io-puts-in-elixir
