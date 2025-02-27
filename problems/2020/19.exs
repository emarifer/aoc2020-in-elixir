defmodule Aoc2020.Problem19 do
  # ================= Start Prelude ==================

  alias Utility.Parser

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================

  defp validate([], [], _rules), do: true
  defp validate([], _rule, _rules), do: false
  defp validate(_str, [], _rules), do: false

  defp validate([first | unprocessed], [{:char, char} | rest], rules) do
    if first == char, do: validate(unprocessed, rest, rules), else: false
  end

  defp validate(str, [[a, b] | rest], rules) when is_list(a) and is_list(b) do
    [a, b] |> Enum.any?(fn branch -> validate(str, [branch | rest], rules) end)
  end

  defp validate(str, [next | rest], rules) when is_list(next) do
    validate(str, Enum.concat(next, rest), rules)
  end

  defp validate(str, [next | rest], rules) when is_binary(next) do
    rule = Map.get(rules, next)

    validate(str, [rule | rest], rules)
  end

  defp count_valid(%{messages: messages, rules: rules}) do
    # Full match with rule "0"
    zero = Map.get(rules, "0")

    # https://hexdocs.pm/elixir/Task.html#async_stream/3
    messages
    |> Task.async_stream(fn msg -> validate(msg, zero, rules) end)
    |> Stream.filter(fn {:ok, result} -> result end)
    |> Enum.count()
  end

  def part1(data) do
    data
    |> Parser.parse()
    |> count_valid()
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================

  def patch_rules(%{rules: rules, messages: messages}) do
    new_rules =
      rules
      |> Map.put("8", Parser.parse_rule("42 | 42 8"))
      |> Map.put("11", Parser.parse_rule("42 31 | 42 11 31"))

    %{rules: new_rules, messages: messages}
  end

  def part2(data) do
    data
    |> Parser.parse()
    |> patch_rules()
    |> count_valid()
  end

  # ================== End Part 2 ====================
end

defmodule Utility.Parser do
  defp parse_case(<<"\"", char::binary-size(1), "\"">>), do: {:char, char}
  defp parse_case(list), do: String.split(list, " ", trim: true)

  def parse_rule(rule) do
    rule
    |> String.split("|", trim: true)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_case/1)
    |> Enum.to_list()
  end

  defp parse_rule_line(rule) do
    [number, rule_line] = String.split(rule, ":", trim: true)
    rule = parse_rule(rule_line)

    {number, rule}
  end

  defp parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule_line/1)
    |> Map.new()
  end

  defp parse_messages(messages) do
    messages
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp parse_rules_and_messages([rules, messages]) do
    %{rules: parse_rules(rules), messages: parse_messages(messages)}
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> parse_rules_and_messages()
  end
end

{:ok, sample} = File.read("inputs/sample.messages")
{:ok, sample2} = File.read("inputs/sample.messages2")
{:ok, lines} = File.read("inputs/19.input")

# Part #1
sample
|> Aoc2020.Problem19.part1()
|> IO.inspect(label: "part1/sample1")

lines
|> Aoc2020.Problem19.part1()
|> IO.inspect(label: "part1/puzzle")

# Part #2
sample2
|> Aoc2020.Problem19.part2()
|> IO.inspect(label: "part2/sample2")

before_t = :os.system_time(:millisecond)

lines
|> Aoc2020.Problem19.part2()
|> IO.inspect(label: "part2/puzzle in #{:os.system_time(:millisecond) - before_t} ms")

# Part #1
# part1/sample: 2
# part1/puzzle: 124

# Part #2
# part2/sample2: 12
# part2/puzzle in 40 ms: 228

# ==============================================================

# REFERENCES:

# sample |> Utility.Parser.parse() |> IO.inspect() ==>
# %{
#   messages: [
#     ["a", "b", "a", "b", "b", "b"],
#     ["b", "a", "b", "a", "b", "a"],
#     ["a", "b", "b", "b", "a", "b"],
#     ["a", "a", "a", "b", "b", "b"],
#     ["a", "a", "a", "a", "b", "b", "b"]
#   ],
#   rules: %{
#     "0" => [["4", "1", "5"]],
#     "1" => [["2", "3"], ["3", "2"]],
#     "2" => [["4", "4"], ["5", "5"]],
#     "3" => [["4", "5"], ["5", "4"]],
#     "4" => [char: "a"],
#     "5" => [char: "b"]
#   }
# }
# https://elixirforum.com/t/avent-of-code-2020-day-19/36324/8

# How the `validate` function works:
# Let's imagine the message "ababbb" (["a", "b", "a", "b", "b", "b"])
# and rule "0" ("0" => [["4", "1", "5"]]).
# Initially the function takes these arguments:
# validate(["a", "b", "a", "b", "b", "b"], [["4", "1", "5"] | []], rules)
# (when is_list(["4", "1", "5"])).
# It is recursively invoked again with these other arguments:
# validate(["a", "b", "a", "b", "b", "b"], ["4" | ["1", "5"]], rules)
# (when is_binary("4").
# Which causes it to be called once more recursively but with these arguments:
# validate(["a", "b", "a", "b", "b", "b"], [[char: "a"] | ["1", "5"]], rules)
# (when is_list([char: "a"]).
# validate(["a" | ["b", "a", "b", "b", "b"]], [{:char, "a"} | ["1", "5"]], rules)
# Since `first` == `char` ("a" == "a"), the remaining messages
# and rules are recursively processed:
# validate(["b", "a", "b", "b", "b"], ["1" | "5"], rules) when is_binary("1")
# then, since Map.get(rules, "1") = [["2", "3"], ["3", "2"]]
# def validate(str, [[a, b] | rest], rules) when is_list(a) and is_list(b), i.e,
# validate(["b", "a", "b", "b", "b"], [[["2", "3"], ["3", "2"]] | ["5"]], rules)
# when is_list(["2", "3"]) and is_list(["2", "3"])
# Now we evaluate if any of the 2 rule branches are validated:
# Firt branch (["2", "3"]) being str = ["b", "a", "b", "b", "b"]:
# validate(str, [["2", "3"] | ["5"]], rules) when is_list(["2", "3"]) ==>
# validate(str, ["2" | ["3", "5"]], rules) when is_binary("2") ==>
# validate(str, [[["4", "4"], ["5", "5"]] | ["3", "5"]], rules) when is_list(a) and is_list(b)
# There are 2 branches again… let's focus on the first one, e.g.:
# validate(str, [["4", "4"] | ["3", "5"]], rules) when is_list(["4", "4"]) =>
# validate(str, ["4" | ["4", "3", "5"]], rules)  when is_binary("4") =>
# validate(["b" | ["a", "b", "b", "b"]], [{:char, "a"} | ["1", "5"]], rules) =>
# In this case ("b" != "a") the branch we are on is not true.
# ...
# ...
# The process ends when exploring all the branches of
# this "recursive tree" leads to one of the following situations:
# 1.- The first character of the message (or of what has not
# yet been processed) does not match the simple rule ({char: "a"} or
# {char: "b"}) that is currently being processed,
# in which case it is not validated (`false`).
# 2.- If when, in the previous case, the first character of
# what remains unprocessed in the message is equal to the character
# of the simple rule ({char: "a"} or {char: "b"}) and
# there are no more characters in the message or pending rules to check,
# in this case, this means that all the rules implied
# by rule "0" have been fulfilled for all characters
# in the message and therefore the message is validated ("true").
# 3.- If in the previous case, there is nothing left to process
# in the message but the "queue" of pending rules to be verified
# is not yet empty, the message is not validated (`false`).
# 4.- If in case 2, there were still characters in the message
# to be verified but the rule queue was already empty, this would mean
# that the message has additional characters that have not had
# the opportunity to match the set of rules implied by rule "0"
# and, consequently, the message is not validated (`false`).

# ==============================================================

# OTHER REFERENCES:
# %{
#   "0" => [["4", "1", "5"]],
#   "1" => [["2", "3"], ["3", "2"]],
#   "2" => [["4", "4"], ["5", "5"]],
#   "3" => [["4", "5"], ["5", "4"]],
#   "4" => [["a"]],
#   "5" => [["b"]]
# }

# defp parse_puzzle(path),
#   do:
#     File.stream!(path)
#     |> Enum.map(&String.trim/1)
#     |> Enum.chunk_by(&(&1 == ""))
#     |> List.delete([""])

# defp parse_rule(line) do
#   [rule_number, rule_data] = String.split(line, ": ")

#   rule_branches =
#     rule_data
#     |> String.replace("\"", "")
#     |> String.split(" | ")
#     |> Enum.map(&String.split/1)

#   {rule_number, rule_branches}
# end

# def parse_rules(rules), do: rules |> Enum.map(&parse_rule/1) |> Map.new()

# defp consume(_rules, "a" <> rest, "a"), do: rest
# defp consume(_rules, "b" <> rest, "b"), do: rest
# defp consume(_rules, _no_match, char) when char in ["a", "b"], do: nil

# # consume(map_of_rules, message, rule_number)
# defp consume(rules, line, rule) do
#   Enum.find_value(rules[rule], fn branch ->
#     Enum.reduce(branch, line, fn rule, line ->
#       # IO.inspect({line, rule})
#       # if line == nil then at least one rule of the branch
#       # is not satisfied so the "general" rule is not satisfied
#       line && consume(rules, line, rule)
#       # when this occurs `"b" && "" ==> ""` or `"a" && "" ==> ""`
#       # it means that the initial message (line) complies with the rule
#     end)
#   end)
# end

# def part1(puzzle) do
#   [rules, messages] = parse_puzzle(puzzle)

#   messages
#   |> Enum.filter(&(consume(parse_rules(rules), &1, "0") == ""))
#   |> length()
# end
