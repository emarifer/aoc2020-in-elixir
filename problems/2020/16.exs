defmodule Aoc2020.Problem16 do
  # ================= Start Prelude ==================
  import String, only: [to_integer: 1]

  defp parse_data(path) do
    clear = fn lines -> Enum.map(lines, &String.trim/1) end

    path
    |> File.stream!()
    |> Stream.chunk_by(&(&1 == "\n"))
    |> Stream.filter(&(&1 != ["\n"]))
    |> Enum.map(&clear.(&1))
  end

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================
  defp parse_rules(rules) do
    rules
    |> Enum.map(fn rule ->
      %{"name" => name, "i1" => i1, "i2" => i2, "i3" => i3, "i4" => i4} =
        Regex.named_captures(
          ~r/(?<name>[\w\s]+): (?<i1>\d+)-(?<i2>\d+) or (?<i3>\d+)-(?<i4>\d+)/,
          rule
        )

      {name, to_integer(i1)..to_integer(i2), to_integer(i3)..to_integer(i4)}
    end)
  end

  defp parse_ticket(t), do: t |> String.split(",") |> Enum.map(&to_integer/1)

  defp parse_tickets(tickets) do
    tickets
    |> Enum.drop(1)
    |> Enum.map(&parse_ticket/1)
  end

  defp valid_field?(field, {_, r1, r2}), do: field in r1 or field in r2

  defp valid_field?(field, rules),
    do: Enum.any?(rules, &valid_field?(field, &1))

  defp invalid_fields(tickets, rules) do
    Enum.flat_map(tickets, fn
      ticket ->
        Enum.reject(ticket, &valid_field?(&1, rules))
    end)
  end

  def part1(puzzle) do
    [rules, _ticket, nearby_tickets] = parse_data(puzzle)
    rules = parse_rules(rules)

    nearby_tickets
    |> parse_tickets()
    |> invalid_fields(rules)
    |> Enum.sum()
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp parse_your_ticket(t), do: t |> Enum.at(1) |> parse_ticket()

  defp valid_all_fields_ticket?(t, rules),
    do: Enum.all?(t, &valid_field?(&1, rules))

  defp valid_field_values?(field_values, rule) do
    field_values
    |> Tuple.to_list()
    |> Enum.all?(&valid_field?(&1, rule))
  end

  defp find_field_candidates(tickets, rules) do
    # `Enum.zip` does a matrix transposition
    tickets
    |> Enum.zip()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {field_values, index}, acc ->
      rules
      |> Enum.filter(&valid_field_values?(field_values, &1))
      |> Enum.reduce(acc, fn rule, acc ->
        Map.update(acc, index, [rule], &[rule | &1])
      end)
    end)
  end

  defp remove_from_candidates(candidates, rule) do
    candidates
    |> Enum.map(fn
      {index, [rule]} -> {index, [rule]}
      {index, rules} -> {index, Enum.reject(rules, &(&1 == rule))}
    end)
    |> Map.new()
  end

  defp reduce_candidates(candidates) do
    new =
      Enum.reduce(candidates, candidates, fn
        {_index, [rule]}, acc -> remove_from_candidates(acc, rule)
        _, acc -> acc
      end)

    if new == candidates, do: candidates, else: reduce_candidates(new)
  end

  defp field_values(ticket, indexes, prefix) do
    indexes
    |> Enum.filter(fn {_, [{name, _, _}]} -> String.starts_with?(name, prefix) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce([], fn index, acc -> [Enum.at(ticket, index) | acc] end)
  end

  def part2(puzzle) do
    [rules, your_ticket, nearby_tickets] = parse_data(puzzle)
    rules = parse_rules(rules)

    field_indexes =
      nearby_tickets
      |> parse_tickets()
      |> Enum.filter(&valid_all_fields_ticket?(&1, rules))
      |> find_field_candidates(rules)
      |> reduce_candidates()

    your_ticket
    |> parse_your_ticket()
    |> field_values(field_indexes, "departure")
    |> Enum.reduce(1, fn val, acc -> val * acc end)
  end

  # ================== End Part 2 ====================
end

# [rules, ticket, nearby_tickets] = Aoc2020.Problem16.parse_data("inputs/16.input")

# your_ticket = Aoc2020.Problem16.parse_your_ticket(ticket) |> IO.inspect()

# rules = Aoc2020.Problem16.parse_rules(rules)

# field_indexes =
#   nearby_tickets
#   |> Aoc2020.Problem16.parse_tickets()
#   |> Enum.filter(&Aoc2020.Problem16.valid_all_fields_ticket?(&1, rules))
#   |> Aoc2020.Problem16.find_field_candidates(rules)
#   |> Aoc2020.Problem16.reduce_candidates()
#   |> IO.inspect()

# your_ticket
# |> Aoc2020.Problem16.field_values(field_indexes, "departure")
# |> Enum.reduce(1, fn val, acc -> val * acc end)
# |> IO.inspect()

Aoc2020.Problem16.part1("inputs/sample.tickets")
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem16.part1("inputs/16.input")
|> IO.inspect(label: "part1/puzzle")

Aoc2020.Problem16.part2("inputs/16.input")
|> IO.inspect(label: "part2/puzzle")

# Part #1
# part1/sample: 71
# part1/puzzle: 19087

# Part #2
# part2/puzzle: 1382443095281

# REFERENCES:
# Indexing fields (details)
# defp find_field_candidates(tickets, rules) do
#   tickets
#   |> Enum.zip() => does a matrix transposition
#   |> Enum.with_index() => Each set of field values ​​(tuples) is indexed
#   |> Enum.reduce(%{}, fn {field_values, index}, acc ->
#     rules (a map is created by reduction)
#     those rules that satisfy each of the values ​​of a field are filtered
#     |> Enum.filter(&valid_field_values?(field_values, &1))
#     |> Enum.reduce(acc, fn rule, acc ->
#       The accumulator map is filled: if the key is not yet present,
#       a list with the current rule is added to it; if it is already present,
#       the current rule is added to the list.
#       Map.update(acc, index, [rule], &[rule | &1])
#     end)
#   end)
# end
# The result is a map with the keys (field indexes)
# and a list with the rules that satisfy each of them.

# defp reduce_candidates(candidates) do
#   new =
#     Enum.reduce(candidates, candidates, fn
#     (When we find a rule that is unique to a field (column),
#     we remove it from the rest of the columns: "The order is
#     consistent between all tickets", so each field only needs
#     to match one rule [single-item list].) ↓↓↓↓
#       {_index, [rule]}, acc -> remove_from_candidates(acc, rule)
#       _, acc -> acc
#     end)
#    (When what comes in (`candidates`) is equal to what comes out (`new`)
#    we end the recursion.)
#   if new == candidates, do: candidates, else: reduce_candidates(new)
# end
# ====>
# %{
# (field) => (rule/s)
#   0 => [{"row", 0..5, 8..19}],
#   1 => [{"row", 0..5, 8..19}, {"class", 0..1, 4..19}],
#   2 => [{"seat", 0..13, 16..19}, {"row", 0..5, 8..19}, {"class", 0..1, 4..19}]
# }
# false
# false
# true
# part2/puzzle: %{
#   0 => [{"row", 0..5, 8..19}],
#   1 => [{"class", 0..1, 4..19}],
#   2 => [{"seat", 0..13, 16..19}]
# }

# https://www.christianblavier.com/
# https://github.com/cblavier/advent/blob/master/lib/2020/day16/part2.ex
