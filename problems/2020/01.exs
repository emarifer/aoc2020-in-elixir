defmodule Aoc2020.Problem01 do
  def get_result1(input) do
    # Cartesian product of the same list made with comprehensions:
    # https://hexdocs.pm/elixir/comprehensions.html
    # Returns a list of 2 elements with the same result,
    # since we did the Cartesian product of the same set:
    # [a * b, b * a]. Therefore, we are left with only the first value
    # using the `hd` function (https://hexdocs.pm/elixir/Kernel.html#hd/1):

    for(i <- input, j <- input, i + j == 2020, do: i * j) |> hd
  end

  def get_result2(input) do
    for(i <- input, j <- input, k <- input, i + j + k == 2020, do: i * j * k)
    |> hd
  end
end

{:ok, lines} = Aoc.read_lines("inputs/01.input")

# Part #1
[[1721, 979, 366, 299, 675, 1456], lines |> Enum.map(&String.to_integer/1)]
|> Aoc.runner(&Aoc2020.Problem01.get_result1/1)

# Part #2
[[1721, 979, 366, 299, 675, 1456], lines |> Enum.map(&String.to_integer/1)]
|> Aoc.runner(&Aoc2020.Problem01.get_result2/1)

# Part #1
# 514579 <- Proposed example
# 567171 <- Result

# Part #2
# 241861950 <- Proposed example
# 212428694 <- Result
