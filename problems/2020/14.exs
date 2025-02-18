defmodule Aoc2020.Problem14 do
  # ================= Start Prelude ==================
  import Bitwise
  import String, only: [replace: 3, to_integer: 2]

  @length 36
  @max_addr round(:math.pow(2, @length) - 1)

  defp parse(line) do
    line
    |> String.trim()
    |> String.split(" = ")
    |> case do
      ["mask", mask] ->
        {:mask, mask}

      ["mem[" <> pos, value] ->
        {:mem, String.to_integer(String.slice(pos, 0..-2//1)), String.to_integer(value)}
    end
  end

  def input(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse/1)
  end

  # =============== Makigas resolution ===============
  defp parse_op("mask = " <> mask), do: {:mask, mask}

  defp parse_op("mem[" <> mem) do
    [k, v] = mem |> String.split("] = ")
    {:mem, String.to_integer(k), String.to_integer(v)}
  end

  def parse2(program), do: program |> Enum.map(&parse_op/1)

  defp pad(val) do
    bits = val |> Integer.digits(2)
    zeropad = Stream.cycle([0]) |> Enum.take(36 - length(bits))
    zeropad ++ bits
  end

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================
  def part1(input) do
    for instruction <- Enum.to_list(input), reduce: {%{}, {0, 0}} do
      {mem, {m1, m2}} ->
        case instruction do
          {:mask, mask} ->
            {mem,
             {mask
              |> String.replace("1", "0")
              |> String.replace("X", "1")
              |> String.to_integer(2),
              mask
              |> String.replace("X", "0")
              |> String.to_integer(2)}}

          # |> IO.inspect()

          {:mem, addr, value} ->
            new_value = Bitwise.bxor(Bitwise.&&&(m1, value), m2)
            {Map.put(mem, addr, new_value), {m1, m2}}

            # |> IO.inspect()
        end
    end
    |> elem(0)
    |> Map.values()
    |> Enum.sum()

    # {%{7 => 101, 8 => 64}, {68719476669, 64}}
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp write_mem(mem, _base_addr, _value, []), do: mem

  defp write_mem(mem, base_addr, value, [mask | rest]) do
    flipped_addr = bxor(base_addr, mask)

    mem
    |> Map.put(base_addr, value)
    |> write_mem(base_addr, value, rest)
    |> Map.put(flipped_addr, value)
    |> write_mem(flipped_addr, value, rest)
  end

  defp flips(x_mask), do: flips(x_mask, 1)
  defp flips(0, _), do: []

  defp flips(x_mask, x) when (x_mask &&& 1) === 1 do
    [x | flips(x_mask >>> 1, x <<< 1)]
  end

  defp flips(x_mask, x) do
    flips(x_mask >>> 1, x <<< 1)
  end

  def part2(input) do
    for instruction <- Enum.to_list(input), reduce: {%{}, {0, 0}} do
      {mem, {x_mask, one_mask}} ->
        case instruction do
          {:mask, mask} ->
            x_mask =
              mask
              |> replace("1", "0")
              |> replace("X", "1")
              |> to_integer(2)

            one_mask =
              mask
              |> replace("X", "0")
              |> to_integer(2)

            {mem,
             {
               x_mask,
               one_mask
             }}

          {:mem, addr, value} ->
            base_addr = bxor(one_mask, bxor(@max_addr, one_mask ||| x_mask) &&& addr)
            {write_mem(mem, base_addr, value, flips(x_mask)), {x_mask, one_mask}}
        end
    end
    |> elem(0)
    |> Map.values()
    |> Enum.sum()
  end

  # =============== Makigas resolution ===============

  defp addresses(address, mask) do
    bitmask = mask |> String.codepoints()

    addresses =
      pad(address)
      |> Enum.zip(bitmask)
      |> Enum.map(fn
        {b, "0"} -> b
        {_, "1"} -> 1
        {_, "X"} -> nil
      end)

    floating_bits =
      addresses
      |> Enum.with_index()
      |> Enum.filter(fn
        {nil, _i} -> true
        _ -> false
      end)
      |> Enum.map(&elem(&1, 1))

    Aoc.combinatory(floating_bits)
    |> Enum.map(fn comb ->
      Enum.reduce(comb, addresses, fn b, address -> List.replace_at(address, b, 1) end)
      |> Enum.map(fn
        nil -> 0
        x -> x
      end)
    end)
    |> Enum.map(&Integer.undigits(&1, 2))
  end

  defp process(program) do
    Enum.reduce(program, {%{}, ""}, fn
      {:mask, newmask}, {memory, _mask} ->
        {memory, newmask}

      {:mem, k, v}, {memory, mask} ->
        newmem =
          addresses(k, mask)
          |> Enum.reduce(memory, fn addr, mem -> Map.put(mem, addr, v) end)

        {newmem, mask}
    end)
  end

  def p2(program),
    do:
      process(parse2(program))
      |> elem(0)
      |> Map.values()
      |> Enum.sum()

  # ================== End Part 2 ====================
end

# Aoc2020.Problem14.input("inputs/sample.docking_data")
# |> Enum.to_list()
# |> IO.inspect()
# =====>
# [
#   {:mask, "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"},
#   {:mem, 8, 11},
#   {:mem, 7, 101},
#   {:mem, 8, 0}
# ]

# "8]" |> String.slice(0..-2//1) => "8"
# "845]" |> String.slice(0..-2//1) => "845"

Aoc2020.Problem14.input("inputs/sample.docking_data")
|> Aoc2020.Problem14.part1()
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem14.input("inputs/14.input")
|> Aoc2020.Problem14.part1()
|> IO.inspect(label: "part1/real")

# Aoc2020.Problem14.input("inputs/sample.docking_data2")
# |> Aoc2020.Problem14.part2()
# |> IO.inspect(label: "part2/sample")

# Aoc2020.Problem14.input("inputs/14.input")
# |> Aoc2020.Problem14.part2()
# |> IO.inspect(label: "part2/real")

{:ok, lines} =
  Aoc.read_lines("inputs/14.input", "\n")

{:ok, sample} = Aoc.read_lines("inputs/sample.docking_data2", "\n")

# Part #2
[sample] |> Aoc.runner(&Aoc2020.Problem14.p2/1, "part2/sample")
[lines] |> Aoc.runner(&Aoc2020.Problem14.p2/1, "part2/real")

# Part #1
# part1/sample: 165
# part1/real: 12408060320841

# Part #2
# part2/sample: 208
# part2/real: 4466434626828

# REFERENCES:
# https://elixirforum.com/t/advent-of-code-2020-day-14/36199/9
# https://github.com/danirod-live/aoc20/blob/trunk/problems/2020/14.exs
