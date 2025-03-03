defmodule Aoc2020.Problem21 do
  # ================= Start Prelude ==================
  def parse_puzzle(path), do: File.stream!(path) |> Enum.map(&String.trim/1)

  defmodule Food do
    defstruct ingredients: MapSet.new(), allergens: MapSet.new()
  end

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================

  defp parse(food) do
    to_set = &MapSet.new(String.split(&1, &2))
    [_, ingredients, allergens] = Regex.run(~r/^(.*) \(contains (.*)\)$/, food)

    %Food{ingredients: to_set.(ingredients, " "), allergens: to_set.(allergens, ", ")}
  end

  defp process(input) do
    all_food = Enum.map(input, &parse/1)

    # Map associating each allergen with the ingredients
    # in which it MAY be present.
    by_allergen =
      Map.new(
        # Gets all the allergens present in all foods but without any repetition
        Enum.reduce(all_food, MapSet.new(), &MapSet.union(&1.allergens, &2)),
        fn allergen ->
          case Enum.filter(all_food, &(allergen in &1.allergens)) do
            # the allergen in question is not present in any food.
            [] ->
              {allergen, []}

            # List containing the food in which the allergen
            # in question is present
            x ->
              {allergen,
               Enum.reduce(tl(x), hd(x).ingredients, &MapSet.intersection(&1.ingredients, &2))}
          end
        end
      )

    {all_food, by_allergen}
  end

  def part1(input) do
    {all_food, by_allergen} = process(input)
    bad = MapSet.new(Enum.flat_map(by_allergen, &elem(&1, 1)))
    # ↑↑↑ MapSet of ingredients containing allergens ↑↑↑
    # MapSet.new(["mxmxvkd", "sqjhc", "fvjkl"])

    Enum.sum(
      Enum.map(all_food, fn food -> Enum.count(Enum.filter(food.ingredients, &(!(&1 in bad)))) end)
    )
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  def part2(input) do
    {_, by_allergen} = process(input)

    Enum.reduce(
      # We create a list of tuples ordered by size of their MapSets
      # of ingredients that have the corresponding allergen.
      Enum.sort_by(by_allergen, &Enum.count(elem(&1, 1))),
      Map.new(),
      fn {allergen, ingredients}, acc ->
        # In some cases, subtracting the list of keys from the accumulator
        # map's ingredient list can result in an empty list and thus the `hd()`
        # function will throw an error; reversing the ingredient
        # list fixes that problem.
        Map.put(acc, hd(Enum.reverse(MapSet.to_list(ingredients)) -- Map.keys(acc)), allergen)

        # "Each allergen is found in exactly one ingredient.
        # Each ingredient contains zero or one allergen."
        # For this reason we sort the MapSet `by_allergen`
        # as a list of tuples with the ingredient lists sorted
        # from smallest to largest:
        # ["mxmxvkd"] -- [] ==> {"mxmxvkd" => "dairy"}
        # ["sqjhc", "mxmxvkd"] -- ["mxmxvkd"] ==> {"sqjhc" => "fish}
        # ["sqjhc", "fvjkl"] -- ["mxmxvkd", "sqjhc"] ==> {"fvjkl" => "soy"}
      end
    )
    # Sort alphabetically by allergen type
    |> Enum.sort_by(&elem(&1, 1))
    # Create a list of allergenic ingredients
    |> Enum.map(&elem(&1, 0))
    # join them into a comma-separated string of names
    |> Enum.join(",")
  end

  # ================== End Part 2 ====================
end

sample = """
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
"""

# Part #1
sample
|> String.split("\n", trim: true)
|> Aoc2020.Problem21.part1()
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem21.parse_puzzle("inputs/21.input")
|> Aoc2020.Problem21.part1()
|> IO.inspect(label: "part1/puzzle")

# Part #2
sample
|> String.split("\n", trim: true)
|> Aoc2020.Problem21.part2()
|> IO.inspect(label: "part2/sample")

Aoc2020.Problem21.parse_puzzle("inputs/21.input")
|> Aoc2020.Problem21.part2()
|> IO.inspect(label: "part2/puzzle")

# Part #1
# part1/sample: 5
# part1/puzzle: 2556

# Part #2
# part2/sample: "mxmxvkd,sqjhc,fvjkl"
# part2/puzzle: "vcckp,hjz,nhvprqb,jhtfzk,mgkhhc,qbgbmc,bzcrknb,zmh"

# REFERENCES:
# all_food = [
#   %Aoc2020.Problem21.Food{
#     ingredients: MapSet.new(["kfcds", "mxmxvkd", "nhms", "sqjhc"]),
#     allergens: MapSet.new(["dairy", "fish"])
#   },
#   %Aoc2020.Problem21.Food{
#     ingredients: MapSet.new(["fvjkl", "mxmxvkd", "sbzzf", "trh"]),
#     allergens: MapSet.new(["dairy"])
#   },
#   %Aoc2020.Problem21.Food{
#     ingredients: MapSet.new(["fvjkl", "sqjhc"]),
#     allergens: MapSet.new(["soy"])
#   },
#   %Aoc2020.Problem21.Food{
#     ingredients: MapSet.new(["mxmxvkd", "sbzzf", "sqjhc"]),
#     allergens: MapSet.new(["fish"])
#   }
# ]

# Gets all the allergens present in all foods but without any repetition
# Enum.reduce(all_food, MapSet.new(), &MapSet.union(&1.allergens, &2)) ==>
# MapSet.new(["dairy", "fish", "soy"])

# Map associating each allergen with the ingredients in which it MAY be present:
# by_allergen = %{
#   "dairy" => MapSet.new(["mxmxvkd"]),
#   "fish" => MapSet.new(["mxmxvkd", "sqjhc"]),
#   "soy" => MapSet.new(["fvjkl", "sqjhc"])
# }

# part2/puzzle:
# [
#   {"nuts", MapSet.new(["jhtfzk"])},
#   {"dairy", MapSet.new(["jhtfzk", "vcckp"])},
#   {"sesame", MapSet.new(["bzcrknb", "qbgbmc"])},
#   {"shellfish", MapSet.new(["bzcrknb", "jhtfzk"])},
#   {"eggs", MapSet.new(["hjz", "jhtfzk", "vcckp"])},
#   {"fish", MapSet.new(["jhtfzk", "nhvprqb", "vcckp"])},
#   {"peanuts", MapSet.new(["bzcrknb", "jhtfzk", "mgkhhc", "qbgbmc"])},
#   {"wheat", MapSet.new(["bzcrknb", "jhtfzk", "vcckp", "zmh"])}
# ]
# ["jhtfzk"] --
# [] ==> ["jhtfzk"]
# ["vcckp", "jhtfzk"] --
# ["jhtfzk"] ==> ["jhtfzk", "vcckp"]
# ["qbgbmc", "bzcrknb"] --
# ["jhtfzk", "vcckp"] ==> ["jhtfzk", "qbgbmc", "vcckp"]
# ["jhtfzk", "bzcrknb"] --
# ["jhtfzk", "qbgbmc", "vcckp"] ==> ["bzcrknb", "jhtfzk", "qbgbmc", "vcckp"]
# ["vcckp", "jhtfzk", "hjz"] --
# ["bzcrknb", "jhtfzk", "qbgbmc", "vcckp"] ==> ["bzcrknb", "hjz", "jhtfzk", "qbgbmc", "vcckp"]
# ["vcckp", "nhvprqb", "jhtfzk"] --
# ["bzcrknb", "hjz", "jhtfzk", "qbgbmc", "vcckp"] ==> ["bzcrknb", "hjz", "jhtfzk", "nhvprqb", "qbgbmc", "vcckp"]
# ["qbgbmc", "mgkhhc", "jhtfzk", "bzcrknb"] --
# ["bzcrknb", "hjz", "jhtfzk", "nhvprqb", "qbgbmc", "vcckp"] ==> ["bzcrknb", "hjz", "jhtfzk", "mgkhhc", "nhvprqb", "qbgbmc", "vcckp"]
# ["zmh", "vcckp", "jhtfzk", "bzcrknb"] --
# ["bzcrknb", "hjz", "jhtfzk", "mgkhhc", "nhvprqb", "qbgbmc", "vcckp"] ==> ["bzcrknb", "hjz", "jhtfzk", "mgkhhc", "nhvprqb", "qbgbmc", "vcckp"]

# https://elixirforum.com/t/advent-of-code-2020-day-21/36359/4
# https://github.com/h-j-k/advent20/blob/master/lib/advent_of_code/day21.ex
