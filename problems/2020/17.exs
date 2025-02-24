defmodule Aoc2020.Problem17 do
  # ================= Start Prelude ==================
  defp parse_data(path) do
    path
    |> File.stream!()
    # Add `y` coordinate
    |> Enum.with_index()
    |> Enum.flat_map(fn {data, y} ->
      String.codepoints(data)
      # Add `x` coordinate
      |> Enum.with_index()
      |> Enum.filter(fn {state, _} -> state == "#" end)
      |> Enum.map(fn {state, x} -> {{x, y, 0}, state} end)
    end)
    |> Map.new()
  end

  defp parse_data2(path) do
    path
    |> File.stream!()
    |> Enum.with_index()
    |> Enum.flat_map(fn {data, y} ->
      String.codepoints(data)
      |> Enum.with_index()
      |> Enum.filter(fn {state, _} -> state == "#" end)
      |> Enum.map(fn {state, x} -> {{x, y, 0, 0}, state} end)
    end)
    |> Map.new()
  end

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================
  defp simulation_space(pocket) do
    x_range = pocket |> Enum.map(fn {{x, _, _}, _} -> x end) |> Enum.min_max()

    y_range = pocket |> Enum.map(fn {{_, y, _}, _} -> y end) |> Enum.min_max()

    z_range = pocket |> Enum.map(fn {{_, _, z}, _} -> z end) |> Enum.min_max()

    # w_range = pocket |> Enum.map(fn {{_, _, _, w}, _} -> w end) |> Enum.min_max()

    # The simulation space must include its immediate neighbors,
    # that is, the range must be increased/decreased by +1/-1
    # for each coordinate.
    sim_range = fn {min, max} -> (min - 1)..(max + 1) end

    [x_range, y_range, z_range] |> Enum.map(sim_range)
  end

  defp get_active_neighbors(pocket, {x, y, z}) do
    # Neighboring space to a given coordinate
    check_range = fn n -> (n - 1)..(n + 1) end

    # neighboring coordinates of a coordinate
    for(
      xp <- check_range.(x),
      yp <- check_range.(y),
      zp <- check_range.(z),
      # wp <- check_range.(w),
      # the point itself is excluded
      {x, y, z} != {xp, yp, zp},
      do: Map.get(pocket, {xp, yp, zp}, ".")
    )
    |> Enum.filter(fn state -> state == "#" end)
    |> Enum.count()
  end

  # Conway's rules of the game of life applied to this case
  defp state("#", neighbors) when neighbors in 2..3, do: "#"
  defp state(".", 3), do: "#"
  defp state(_, _), do: "."

  defp new_state(pocket, coordinate) do
    # Concrete state of a coordinate.
    # (those coordinates that are not on the map are filled with ".")
    state = Map.get(pocket, coordinate, ".")
    active_neighbors = get_active_neighbors(pocket, coordinate)
    # Its status changes depending on the number of active neighbors.
    state(state, active_neighbors)
  end

  # Simulates a single iteration cycle.
  defp simulate_one(pocket) do
    [x_range, y_range, z_range] = simulation_space(pocket)

    for x <- x_range,
        y <- y_range,
        z <- z_range do
      coordinate = {x, y, z}
      # generates all possible permutations of the x, y, z coordinates
      # within the simulation space.
      # For the sample, (with a simulation space
      # equal to [-1..3, -1..3, -1..1]), it results
      # in 5x5x3 = 75 possible coordinates
      {coordinate, new_state(pocket, coordinate)}
    end
  end

  defp simulate(pocket, 0), do: pocket

  defp simulate(pocket, iterations) do
    new_pocket =
      pocket
      |> simulate_one()
      |> Enum.filter(fn {_, state} -> state == "#" end)
      |> Enum.into(%{})

    # We do a new iteration but with `iterations - 1`
    # until we reach iterations == 0, in which case we return the map
    simulate(new_pocket, iterations - 1)
  end

  def part1(puzzle) do
    puzzle
    |> parse_data()
    |> simulate(6)
    |> Kernel.map_size()
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================
  # Part 2 was simply extending part 1 with an extra dimension

  defp get_active_neighbors2(pocket, {x, y, z, w}) do
    check_range = fn n -> (n - 1)..(n + 1) end

    for(
      xp <- check_range.(x),
      yp <- check_range.(y),
      zp <- check_range.(z),
      wp <- check_range.(w),
      {x, y, z, w} != {xp, yp, zp, wp},
      do: Map.get(pocket, {xp, yp, zp, wp}, ".")
    )
    |> Enum.filter(fn state -> state == "#" end)
    |> Enum.count()
  end

  defp new_state2(pocket, coordinate) do
    state = Map.get(pocket, coordinate, ".")
    active_neighbors = get_active_neighbors2(pocket, coordinate)

    state(state, active_neighbors)
  end

  defp simulation_space2(pocket) do
    x_range = pocket |> Enum.map(fn {{x, _, _, _}, _} -> x end) |> Enum.min_max()
    y_range = pocket |> Enum.map(fn {{_, y, _, _}, _} -> y end) |> Enum.min_max()
    z_range = pocket |> Enum.map(fn {{_, _, z, _}, _} -> z end) |> Enum.min_max()
    w_range = pocket |> Enum.map(fn {{_, _, _, w}, _} -> w end) |> Enum.min_max()

    sim_range = fn {min, max} -> (min - 1)..(max + 1) end

    [x_range, y_range, z_range, w_range] |> Enum.map(sim_range)
  end

  defp simulate_one2(pocket) do
    [x_range, y_range, z_range, w_range] = simulation_space2(pocket)

    for x <- x_range,
        y <- y_range,
        z <- z_range,
        w <- w_range do
      coordinate = {x, y, z, w}

      {coordinate, new_state2(pocket, coordinate)}
    end
  end

  defp simulate2(pocket, 0), do: pocket

  defp simulate2(pocket, iterations) do
    new_pocket =
      pocket
      |> simulate_one2()
      |> Enum.filter(fn {_, state} -> state == "#" end)
      |> Enum.into(%{})

    simulate2(new_pocket, iterations - 1)
  end

  def part2(puzzle) do
    puzzle
    |> parse_data2()
    |> simulate2(6)
    |> Kernel.map_size()
  end

  # ================== End Part 2 ====================
end

Aoc2020.Problem17.part1("inputs/sample.conway_cubes")
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem17.part1("inputs/17.input")
|> IO.inspect(label: "part1/puzzle")

Aoc2020.Problem17.part2("inputs/sample.conway_cubes")
|> IO.inspect(label: "part2/sample")

Aoc2020.Problem17.part2("inputs/17.input")
|> IO.inspect(label: "part2/puzzle")

# Part #1
# part1/sample: 112
# part1/puzzle: 391

# Part #2
# part2/sample: 848
# part2/puzzle: 2264

# REFERENCES:
# https://elixirforum.com/t/advent-of-code-2020-day-17/36283/5
