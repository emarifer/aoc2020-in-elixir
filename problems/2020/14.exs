defmodule Aoc2020.Problem14 do
  # ================= Start Prelude ==================
  import Bitwise
  import String, only: [replace: 3, to_integer: 1, to_integer: 2, trim_trailing: 1]

  defp parse_addr(<<"] = ", value::binary>>, acc),
    do: {:mem, to_integer(acc), to_integer(value)}

  defp parse_addr(<<d::binary-size(1), rest::binary>>, acc), do: parse_addr(rest, acc <> d)

  defp parse("mask = " <> mask), do: {:mask, mask}
  defp parse(<<"mem[", d::binary-size(1), rest::binary>>), do: parse_addr(rest, d)

  def input(path),
    do:
      path
      |> File.stream!()
      |> Stream.map(&parse(trim_trailing(&1)))

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================
  def part1(input) do
    for instruction <- Enum.to_list(input), reduce: {%{}, {0, 0}} do
      {mem, {m1, m2}} ->
        case instruction do
          {:mask, mask} ->
            {mem,
             {mask
              |> replace("1", "0")
              |> replace("X", "1")
              |> to_integer(2),
              mask
              |> replace("X", "0")
              |> to_integer(2)}}

          # |> IO.inspect()

          {:mem, addr, value} ->
            new_value = bxor(m1 &&& value, m2)
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

  # EXPLANATION:
  # 00000000000000000000000000000000X0XX <= mask
  # 000000000000000000000000000000000000 <= or_mask
  # 111111111111111111111111111111110100 <= and_mask
  # 000000000000000000000000000000011010 <= 26 original address
  # 000000000000000000000000000000000000 <= or_mask
  # 000000000000000000000000000000011010 <= result
  # 111111111111111111111111111111110100 <= and_mask
  # 000000000000000000000000000000010000 <= result = 16 "base value" on which
  # successive bitmasks are applied to obtain all memory addresses

  def or_mask(mask), do: replace(mask, "X", "0") |> to_integer(2)

  def and_mask(mask),
    do:
      replace(mask, "0", "1")
      |> replace("X", "0")
      |> to_integer(2)

  # Generates all permutations (2ⁿ, where `n` is the amount of "X" in the mask)
  # of the "floating" bits, placing a "1" where the "X" were and setting
  # the rest of the bits to "0".
  def bitmasks(mask) do
    to_charlist(mask)
    |> Enum.reverse()
    |> Enum.reduce({1, []}, fn
      ?X, {bitmask, masks} -> {bitmask <<< 1, [bitmask | masks]}
      _, {bitmask, masks} -> {bitmask <<< 1, masks}
    end)
    |> elem(1)
  end

  # |> IO.inspect()
  def recur_bitmasks(addr, [], mem, value), do: Map.put(mem, addr, value)

  def recur_bitmasks(addr, [bitmask | bitmasks], mem, value) do
    # `addr` is the "base value" of memory addresses
    # bitmasks |> IO.inspect() # ↓↓ <= this is the tail of [bitmasks] ↓↓
    mem = recur_bitmasks(addr, bitmasks, mem, value)
    # Now the operation is repeated for the other memory addresses
    # `addr ||| bitmask` apply each of the possible masks to the address
    recur_bitmasks(addr ||| bitmask, bitmasks, mem, value)
  end

  def process({:mask, mask}, state),
    do: %{state | mask: {or_mask(mask), and_mask(mask), bitmasks(mask)}}

  def process({:mem, addr, value}, %{mask: mask, mem: mem} = state) do
    # |> IO.inspect()
    {or_mask, and_mask, bitmasks} = mask
    # `addr` is the "base value" on which successive
    # bitmasks are applied to obtain all memory addresses
    # addr |> IO.inspect(label: "OR & AND")
    addr = (addr ||| or_mask) &&& and_mask
    # |> IO.inspect()
    %{state | mem: recur_bitmasks(addr, bitmasks, mem, value)}
  end

  def part2(input) do
    before_t = :os.system_time(:millisecond)

    %{mem: mem} =
      input
      |> Enum.reduce(%{mask: nil, mem: %{}}, &process/2)

    "#{Map.values(mem) |> Enum.sum()} in #{:os.system_time(:millisecond) - before_t} ms"
  end

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

# Aoc2020.Problem14.bitmasks("000000000000000000000000000000X1001X") |> IO.inspect()
# mem[42] = 100
# Aoc2020.Problem14.recur_bitmasks(42, [32, 1], %{}, 100) |> IO.inspect()

# mask = "00000000000000000000000000000000X0XX"

# Aoc2020.Problem14.process(
#   {:mem, 26, 1},
#   %{
#     mask:
#       {Aoc2020.Problem14.or_mask(mask), Aoc2020.Problem14.and_mask(mask),
#        Aoc2020.Problem14.bitmasks(mask)},
#     mem: %{}
#   }
# )
# =====>
# =====>
# {0, 68719476724, [8, 2, 1]} or, and, bitmasks
# 68719476724 applied OR & AND
# %{16 => 1}
# %{16 => 1, 17 => 1}
# %{16 => 1, 17 => 1, 18 => 1}
# %{16 => 1, 17 => 1, 18 => 1, 19 => 1}
# %{16 => 1, 17 => 1, 18 => 1, 19 => 1, 24 => 1}
# %{16 => 1, 17 => 1, 18 => 1, 19 => 1, 24 => 1, 25 => 1}
# %{16 => 1, 17 => 1, 18 => 1, 19 => 1, 24 => 1, 25 => 1, 26 => 1}
# %{
#   mask: {0, 68719476724, [8, 2, 1]},
#   mem: %{16 => 1, 17 => 1, 18 => 1, 19 => 1, 24 => 1, 25 => 1, 26 => 1, 27 => 1}
# }

Aoc2020.Problem14.input("inputs/sample.docking_data")
|> Aoc2020.Problem14.part1()
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem14.input("inputs/14.input")
|> Aoc2020.Problem14.part1()
|> IO.inspect(label: "part1/real")

# print = fn res -> IO.puts("part2/real: " <> res) end

Aoc2020.Problem14.input("inputs/sample.docking_data2")
|> Aoc2020.Problem14.part2()
|> (&IO.puts("part2/sample: " <> &1)).()

Aoc2020.Problem14.input("inputs/14.input")
|> Aoc2020.Problem14.part2()
|> (&IO.puts("part2/real: " <> &1)).()

# Part #1
# part1/sample: 165
# part1/real: 12408060320841

# Part #2
# part2/sample: 208 in 1 ms
# part2/real: 4466434626828 in 52 ms

# {:ok, lines} =
#   Aoc.read_lines("inputs/14.input", "\n")

# {:ok, sample} = Aoc.read_lines("inputs/sample.docking_data2", "\n")

# Part #2
# [sample] |> Aoc.runner(&Aoc2020.Problem14.p2/1, "part2/sample")
# [lines] |> Aoc.runner(&Aoc2020.Problem14.p2/1, "part2/real")

# REFERENCES:
# https://elixirforum.com/t/advent-of-code-2020-day-14/36199/6
# https://gist.github.com/akash-akya/df3159aa92c3d61ac5c2a56e23074173
# https://elixirforum.com/t/advent-of-code-2020-day-14/36199/9
# https://github.com/danirod-live/aoc20/blob/trunk/problems/2020/14.exs

# =============== Makigas resolution ===============

# defp addresses(address, mask) do
#   bitmask = mask |> String.codepoints()

#   addresses =
#     pad(address)
#     |> Enum.zip(bitmask)
#     |> Enum.map(fn
#       {b, "0"} -> b
#       {_, "1"} -> 1
#       {_, "X"} -> nil
#     end)

#   floating_bits =
#     addresses
#     |> Enum.with_index()
#     |> Enum.filter(fn
#       {nil, _i} -> true
#       _ -> false
#     end)
#     |> Enum.map(&elem(&1, 1))

#   Aoc.combinatory(floating_bits)
#   |> Enum.map(fn comb ->
#     Enum.reduce(comb, addresses, fn b, address -> List.replace_at(address, b, 1) end)
#     |> Enum.map(fn
#       nil -> 0
#       x -> x
#     end)
#   end)
#   |> Enum.map(&Integer.undigits(&1, 2))
# end

# defp process(program) do
#   Enum.reduce(program, {%{}, ""}, fn
#     {:mask, newmask}, {memory, _mask} ->
#       {memory, newmask}

#     {:mem, k, v}, {memory, mask} ->
#       newmem =
#         addresses(k, mask)
#         |> Enum.reduce(memory, fn addr, mem -> Map.put(mem, addr, v) end)

#       {newmem, mask}
#   end)
# end

# def p2(program),
#   do:
#     process(parse2(program))
#     |> elem(0)
#     |> Map.values()
#     |> Enum.sum()

# =============== kwando resolution ===============
# https://elixirforum.com/t/advent-of-code-2020-day-14/36199/9

# ================= Start Prelude ==================
# import Bitwise
# import String, only: [replace: 3, to_integer: 2]

# @length 36
# @max_addr round(:math.pow(2, @length) - 1)

# defp parse(line) do
#   line
#   |> String.trim()
#   |> String.split(" = ")
#   |> case do
#     ["mask", mask] ->
#       {:mask, mask}

#     ["mem[" <> pos, value] ->
#       {:mem, String.to_integer(String.slice(pos, 0..-2//1)), String.to_integer(value)}
#   end
# end

# def input(path) do
#   path
#   |> File.stream!()
#   |> Stream.map(&parse/1)
# end

# ================= End Prelude ====================

# defp write_mem(mem, _base_addr, _value, []), do: mem

#   defp write_mem(mem, base_addr, value, [mask | rest]) do
#     flipped_addr = bxor(base_addr, mask)

#     mem
#     |> Map.put(base_addr, value)
#     |> write_mem(base_addr, value, rest)
#     |> Map.put(flipped_addr, value)
#     |> write_mem(flipped_addr, value, rest)
#   end

#   defp flips(x_mask), do: flips(x_mask, 1)
#   defp flips(0, _), do: []

#   defp flips(x_mask, x) when (x_mask &&& 1) === 1 do
#     [x | flips(x_mask >>> 1, x <<< 1)]
#   end

#   defp flips(x_mask, x) do
#     flips(x_mask >>> 1, x <<< 1)
#   end

#   def part2(input) do
#     for instruction <- Enum.to_list(input), reduce: {%{}, {0, 0}} do
#       {mem, {x_mask, one_mask}} ->
#         case instruction do
#           {:mask, mask} ->
#             x_mask =
#               mask
#               |> replace("1", "0")
#               |> replace("X", "1")
#               |> to_integer(2)

#             one_mask =
#               mask
#               |> replace("X", "0")
#               |> to_integer(2)

#             {mem,
#              {
#                x_mask,
#                one_mask
#              }}

#           {:mem, addr, value} ->
#             base_addr = bxor(one_mask, bxor(@max_addr, one_mask ||| x_mask) &&& addr)
#             {write_mem(mem, base_addr, value, flips(x_mask)), {x_mask, one_mask}}
#         end
#     end
#     |> elem(0)
#     |> Map.values()
#     |> Enum.sum()
#   end
