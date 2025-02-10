defmodule Aoc2020.Problem07 do
  # ================== Start Part 1 ==================
  defp can_contain?("shiny gold", _), do: true

  defp can_contain?(color, rules_tree) do
    children = rules_tree[color]

    case children do
      [] ->
        false

      _ ->
        Enum.any?(children, fn {child, _} ->
          can_contain?(child, rules_tree)
        end)
    end
  end

  defp parse(rules) do
    rule_generator = fn rule ->
      [color, content] =
        rule
        |> String.replace(".", "")
        |> String.replace(" bags", "")
        |> String.replace(" bag", "")
        |> String.split(" contain ")

      bag_list =
        case content do
          "no other" ->
            []

          _ ->
            content
            |> String.split(", ")
            |> Enum.map(fn bag -> String.split(bag, " ", parts: 2) end)
            |> Enum.map(fn [count, color] -> {color, String.to_integer(count)} end)
            |> Map.new()
        end

      {color, bag_list}
    end

    rules
    |> Enum.map(rule_generator)
    |> Map.new()
  end

  def problem1(data) do
    rules_tree = data |> parse()

    candidates =
      rules_tree
      |> Enum.reduce(0, fn {color, _content}, prev ->
        if can_contain?(color, rules_tree), do: prev + 1, else: prev
      end)

    # The color itself (in this case “shiny gold”) must be ruled out,
    # so we subtract 1 from the number of candidates.
    candidates - 1
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  defp child_bags(color, rules_tree) do
    rules_tree[color]
    |> Enum.map(fn {child_color, child_count} ->
      child_count + child_count * child_bags(child_color, rules_tree)
    end)
    |> Enum.sum()
  end

  def problem2(data) do
    rules_tree = data |> parse()

    child_bags("shiny gold", rules_tree)
  end

  # ================== End Part 2 ====================
end

{:ok, sample} = Aoc.read_lines("inputs/sample.bag_rules", "\n")
{:ok, lines} = Aoc.read_lines("inputs/07.input", "\n")

# Part #1
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem07.problem1/1)

# Part #1
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem07.problem2/1)

# Part #1
# 4 <- Proposed example
# 172 <- Result

# Part #2
# 32 <- Proposed example
# 39645 <- Result

# REFERENCES:
# sample |> Aoc2020.Problem07.parse() |> IO.inspect()

# %{
#   "bright white" => %{"shiny gold" => 1},
#   "dark olive" => %{"dotted black" => 4, "faded blue" => 3},
#   "dark orange" => %{"bright white" => 3, "muted yellow" => 4},
#   "dotted black" => [],
#   "faded blue" => [],
#   "light red" => %{"bright white" => 1, "muted yellow" => 2},
#   "muted yellow" => %{"faded blue" => 9, "shiny gold" => 2},
#   "shiny gold" => %{"dark olive" => 1, "vibrant plum" => 2},
#   "vibrant plum" => %{"dotted black" => 6, "faded blue" => 5}
# }
# |> Enum.map(&({color, content} = &1))
# |> IO.inspect()

# "3 faded blue, 4 dotted black" |> Aoc2020.Problem07.get_content() |> IO.inspect()

# Example (Part #2):
# shiny gold bags contain 2 dark red bags.
# dark red bags contain 2 dark orange bags.
# dark orange bags contain 2 dark yellow bags.
# dark yellow bags contain 2 dark green bags.
# dark green bags contain 2 dark blue bags.
# dark blue bags contain 2 dark violet bags.
# dark violet bags contain no other bags.
# ===> 2+2*(2+2*(2+2*(2+2*(2+2*2)))) = 126
