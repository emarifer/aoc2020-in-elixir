fuel = fn mass -> trunc(mass / 3) - 2 end

calculate_fuel = fn masses -> masses |> Enum.map(fuel) |> Enum.sum() end

{:ok, lines} = Aoc.read_lines("problems/2019/01.input")

[[12], [14], [1969], [100_756], lines |> Enum.map(&String.to_integer/1)]
|> Aoc.runner(calculate_fuel)

# Part #1
# 2 <- Proposed example
# 2 <- Proposed example
# 654 <- Proposed example
# 33583 <- Proposed example
# 3372756 <- Result
