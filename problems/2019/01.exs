fuel = fn mass -> trunc(mass / 3) - 2 end

calculate_fuel = fn masses -> masses |> Enum.map(fuel) |> Enum.sum() end

{:ok, lines} = Aoc.read_lines("01.input")

[[12], [14], [1969], [100_756], lines |> Enum.map(&String.to_integer/1)]
|> Aoc.runner(calculate_fuel)
