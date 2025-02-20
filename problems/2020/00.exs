defmodule Aoc2020.VanEckSequence do
  def go do
    solve([0])
  end

  defp solve(already_spoken) do
    start = Enum.count(already_spoken) + 1
    stop = 25

    # We make a memory provision with an array equal to
    # the length of terms we want to obtain.
    spoken = :atomics.new(stop, [])
    # Fill already spoken, n is stored with index n + 1 (atomics mem starts at 1).
    Enum.each(Enum.with_index(already_spoken, 1), fn {n, turn} ->
      :atomics.put(spoken, n + 1, turn)
    end)

    # THE KEY IS THE TERM AND THE VALUE IS THE TURN.
    # Indexes into atomic arrays are one-based.
    # The positions of the array that are still empty are filled with zeros.
    # Enum.each(4..6, fn k ->
    #   :atomics.get(spoken, k + 1) |> (&IO.write("#{&1}, ")).()
    # end)

    run(start, stop, Enum.at(already_spoken, -1), start - 1, spoken)
  end

  defp run(turn, stop, last, before, spoken) when turn <= stop do
    # IO.inspect(:atomics.get(spoken, 0 + 1), label: "Position 1")
    last |> (&IO.write("#{&1}, ")).()

    # :atomics.get(spoken, before) |> IO.inspect(label: "spoken")

    if before == turn - 1 do
      # IO.inspect("before_b: #{:atomics.get(spoken, 0 + 1)}")
      # https://www.erlang.org/doc/apps/erts/atomics.html#exchange/3
      before = :atomics.exchange(spoken, 0 + 1, turn)
      # IO.inspect("before_a: #{:atomics.get(spoken, 0 + 1)} - turn: #{turn}")
      # ↓↓ if `before` == 0 then `turn`, else `before` ↓↓
      run(turn + 1, stop, 0, (before == 0 && turn) || before, spoken)
    else
      n = turn - 1 - before
      before = :atomics.exchange(spoken, n + 1, turn)
      run(turn + 1, stop, n, (before == 0 && turn) || before, spoken)
    end
  end

  defp run(turn, stop, last, _before, _spoken) when turn > stop do
    last |> (&IO.write("#{&1}")).()
    last
  end
end

IO.puts("First 25 terms of the Van Eck’s Sequence:\n")
Aoc2020.VanEckSequence.go() |> IO.inspect(label: "\n\n25th term")

# First 25 terms of the Van Eck’s Sequence:

# 0, 0, 1, 0, 2, 0, 2, 2, 1, 6, 0, 5, 0, 2, 6, 5, 4, 0, 5, 3, 0, 3, 2, 9, 0

# 25th term: 0

# REFERENCES:
# https://oeis.org/A181391
# https://metatutor.co.uk/van-ecks-sequence/
# https://ibmathsresources.com/2019/06/12/the-van-eck-sequence/
# https://www.erlang.org/doc/apps/erts/atomics.html#content
# https://gist.github.com/bossek/ec02ce15faf5aa11628e849830010c64
