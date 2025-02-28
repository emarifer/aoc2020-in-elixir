defmodule Aoc2020.Problem20 do
  # ================= Start Prelude ==================
  def parse_puzzle(path),
    do:
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_by(&(&1 == ""))
      |> Stream.filter(&(&1 != [""]))
      |> Enum.to_list()

  defmodule Tile do
    defstruct id: nil, area: [], sides: []

    def new(id, area) do
      sides = [
        hd(area),
        Enum.join(Enum.map(area, &String.first/1)),
        Enum.join(Enum.map(area, &String.last/1)),
        Enum.at(area, -1)
      ]

      %Tile{id: id, area: area, sides: Enum.flat_map(sides, &[&1, String.reverse(&1)])}
    end

    def align?(tile, other),
      do: tile.id != other.id && Enum.any?(tile.sides, &(&1 in other.sides))
  end

  # Tile struct:
  # area = tile |> tl [list minus header (eg: "Tile 2311:")]
  # Sides:
  # top_side = area |> hd
  # left_side = Enum.join(Enum.map(area, &String.first/1))
  # right_side = Enum.join(Enum.map(area, &String.last/1))
  # bottom_side = Enum.at(area, -1)
  # Enum.flat_map(sides, &[&1, String.reverse(&1)]), generates
  # 8 permutations (each of the 4 sides and its inverse)
  # grouped into a single list.

  # `align?` function: Given a tile and any other tile passed to it,
  # it will return `true` if at least one of the sides
  # (and their permutations) of the given tile is present in sides
  # (and their permutations) of the other tile, on the understanding
  # that the pair of tiles we pass are not the same, that is,
  # they have the same `id`.

  # ================= End Prelude ====================

  # ================== Start Part 1 ==================

  defp parse_tile(tile),
    do:
      (fn [_, id] -> Tile.new(String.to_integer(id), tl(tile)) end).(
        Regex.run(~r/^Tile (\d+):$/, hd(tile))
      )

  # ↑↑↑ The input to this anonymous function [_, id] is the result ↑↑↑
  # of running the regex at the head of the list that constitutes
  # a raw tile. E.g. ["Tile 2311:", "..##.#..#.", "##..#.....", …]
  # produces ["Tile 2311:", "2311"] (the first element is discarded).

  defp process_tiles(input) do
    tiles = Enum.map(input, &parse_tile/1)
    Map.new(tiles, fn tile -> {tile, MapSet.new(Enum.filter(tiles, &Tile.align?(tile, &1)))} end)
  end

  # ↑↑↑ `process_tiles` function: Processes the list of lists generated ↑↑↑
  # from the input file. This list of raw data is parsed by `parse_tile`
  # generating a list of structs of type `Tile`. Next, a `Map` is created
  # by associating each tile in the list with a `MapSet`. The `MapSet`
  # is created from the filtered list of all tiles that have returned `true`
  # for the `align?` function, i.e. that share at least one side with the tile
  # with which the `MapSet` is associated. Given its condition,
  # the `MapSet` has no duplicate element

  def part1(input),
    do:
      process_tiles(input)
      |> Enum.filter(fn {_, matches} -> Enum.count(matches) == 2 end)
      |> Enum.reduce(1, &(elem(&1, 0).id * &2))

  # ↑↑↑ `part1` function: obtains the result of part 1 easily; ↑↑↑
  # it processes the input file converting it into a map
  # that has each of the `Tile` structs associated with
  # other `Tile` structs (within a `MapSet`) that share
  # at least one side with it. Those tiles that have `Mapsets`
  # of length equal to 2, that is, that only have 2 neighbors
  # with which they share sides are the corners of the image.
  # To obtain them we generate a list by filtering the `MapSets`
  # of length 2 (there will only be 4). Finally, using a `reduce`
  # we calculate the product of the 4 ids, which is
  # the result we are looking for.

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================

  defp to_row(tile, row, size, has_side?, tiles, last_row),
    do:
      Enum.reduce(
        1..(size - 1),
        [tile],
        fn col, [last | rest] ->
          next =
            cond do
              has_side?.(last, 2) ->
                Enum.find(tiles[last], &(row == 0 || &1 != Enum.at(last_row, 0)))

              has_side?.(last, 3) ->
                if row == 0 || row == size - 1,
                  do: Enum.find(tiles[last], &(&1 != hd(rest) && !has_side?.(&1, 4))),
                  else: Enum.find(tiles[last], &has_side?.(&1, 4))

              has_side?.(last, 4) ->
                Enum.find(
                  MapSet.intersection(tiles[last], tiles[Enum.at(last_row, col)]),
                  &(&1 != Enum.at(last_row, col - 1))
                )
            end

          [next, last | rest]
        end
      )

  defp to_grid(input) do
    tiles = process_tiles(input)
    size = floor(:math.sqrt(Enum.count(tiles)))

    by_links =
      Map.new(
        Enum.group_by(tiles, fn {_, matches} -> Enum.count(matches) end),
        fn {n, v} -> {n, Enum.map(v, &elem(&1, 0))} end
      )

    has_side? = fn t, n -> Enum.any?(by_links[n], &(&1 == t)) end

    Enum.reduce(
      1..(size - 1),
      [Enum.reverse(to_row(hd(by_links[2]), 0, size, has_side?, tiles, []))],
      fn row, [last_row | rest] ->
        others = if row == 1, do: [], else: [Enum.at(hd(rest), 0)]
        tile = Enum.find(tiles[hd(last_row)], &(!(&1 in [Enum.at(last_row, 1) | others])))
        [Enum.reverse(to_row(tile, row, size, has_side?, tiles, last_row)), last_row | rest]
      end
    )
  end

  defp options(tile) when is_struct(tile) do
    flip_ew = fn area -> Enum.map(area, &String.reverse/1) end
    flip_ns = fn area -> Enum.reverse(area) end

    rotate = fn area ->
      size = length(area) - 1

      Enum.map(0..size, fn x ->
        Enum.join(Enum.map(size..0//-1, &String.at(Enum.at(area, &1), x)))
      end)
    end

    area = tile.area

    [
      area,
      flip_ew.(area),
      flip_ns.(area),
      rotate.(area),
      flip_ew.(rotate.(area)),
      flip_ns.(rotate.(area)),
      rotate.(rotate.(area)),
      rotate.(rotate.(rotate.(area)))
    ]
  end

  defp options(area) when is_list(area), do: [area, Enum.reverse(area)]

  defp match({first, map_first}, {second, map_second}),
    do:
      Enum.find_value(
        first,
        fn a ->
          Enum.find_value(second, fn b ->
            if map_first.(a) == map_second.(b), do: {a, b}, else: nil
          end)
        end
      )

  defp match_tile(second, first) do
    right = fn area -> Enum.join(Enum.map(area, &String.last/1)) end
    left = fn area -> Enum.join(Enum.map(area, &String.first/1)) end
    {a, b} = match({first, right}, {second, left})

    [
      Enum.map(Enum.zip(a, b), fn {x, y} ->
        String.slice(x, 0..-2//1) <> String.slice(y, 1..-1//1)
      end)
    ]
  end

  defp match_row(second, first) do
    {a, b} = match({first, &Enum.at(&1, -1)}, {second, &hd(&1)})
    [Enum.concat(Enum.drop(a, -1), tl(b))]
  end

  defp combine(list, mapper, combiner) do
    [a, b | rest] = Enum.map(list, &options(mapper.(&1)))
    hd(Enum.reduce(rest, combiner.(b, a), combiner))
  end

  defp to_sea(input),
    do:
      combine(to_grid(input), fn row -> combine(row, & &1, &match_tile/2) end, &match_row/2)
      |> Enum.slice(1..-2//1)
      |> Enum.map(&String.slice(&1, 1..-2//1))

  @shapes [~r/^..................#.$/, ~r/^#....##....##....###$/, ~r/^.#..#..#..#..#..#...$/]

  defp count_monsters_in(lines),
    do:
      Enum.reduce(
        0..(String.length(hd(lines)) - 20),
        0,
        fn x, acc ->
          if Enum.all?(
               Enum.zip(@shapes, lines),
               &Regex.match?(elem(&1, 0), String.slice(elem(&1, 1), x, 20))
             ),
             do: acc + 1,
             else: acc
        end
      )

  def part2(input) do
    sea = to_sea(input)

    Enum.find_value(
      options(Tile.new(0, sea)),
      fn x ->
        case Enum.reduce(0..(length(x) - 3), 0, &(count_monsters_in(Enum.slice(x, &1, 3)) + &2)) do
          0 ->
            nil

          n ->
            Enum.reduce(sea, 0, &(Enum.count(String.graphemes(&1), fn x -> x == "#" end) + &2)) -
              n * 15
        end
      end
    )
  end

  # ================== End Part 2 ====================
end

# Part #1
Aoc2020.Problem20.parse_puzzle("inputs/sample.tiles")
|> Aoc2020.Problem20.part1()
|> IO.inspect(label: "part1/sample")

Aoc2020.Problem20.parse_puzzle("inputs/20.input")
|> Aoc2020.Problem20.part1()
|> IO.inspect(label: "part1/puzzle")

# Part #2
# Aoc2020.Problem20.parse_puzzle("inputs/sample.tiles")
# |> Aoc2020.Problem20.part2()
# |> IO.inspect(label: "part2/sample")

# Part #1
# part1/sample: 20899048083289
# part1/puzzle: 27798062994017

# Part #2
# part2/sample: 273

# REFERENCES:
# https://elixirforum.com/t/avent-of-code-2020-day-20/36342/13
# https://github.com/h-j-k/advent20/blob/master/README.md
# https://github.com/h-j-k/advent20/blob/master/lib/advent_of_code/day20.ex

# Reading the input file produces this raw data (list of lists):
# parsed_sample = [
# ["Tile 2311:", "..##.#..#.", "##..#.....", "#...##..#.", "####.#...#",
# "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.",
# "..###..###"],
#  ["Tile 1951:", "#.##...##.", "#.####...#", ".....#..##", "#...######",
# ".##.#....#", ".###.#####", "###.##.##.", ".###....#.", "..#.#..#.#",
# "#...##.#.."],
#  ["Tile 1171:", "####...##.", "#..##.#..#", "##.#..#.#.", ".###.####.",
# "..###.####", ".##....##.", ".#...####.", "#.##.####.", "####..#...",
# ".....##..."],
#  ["Tile 1427:", "###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#",
# "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#",
# "..##.#..#."],
#  ["Tile 1489:", "##.#.#....", "..##...#..", ".##..##...", "..#...#...",
# "#####...#.", "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##",
# "###.##.#.."],
#  ["Tile 2473:", "#....####.", "#..#.##...", "#.##..#...", "######.#.#",
# ".#...#.#.#", ".#########", ".###.#..#.", "########.#", "##...##.#.",
# "..###.#.#."],
#  ["Tile 2971:", "..#.#....#", "#...###...", "#.#.###...", "##.##..#..",
# ".#####..##", ".#..####.#", "#..#.#..#.", "..####.###", "..#.#.###.",
# "...#.#.#.#"],
#  ["Tile 2729:", "...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#",
# ".##..##.#.", ".#.####...", "####.#.#..", "##.####...", "##..#.##..",
# "#.##...##."],
#  ["Tile 3079:", "#.#.#####.", ".#..######", "..#.......", "######....",
# "####.#..#.", ".#...#.##.", "#.#####.##", "..#.###...", "..#.......",
# "..#.###..."]
# ]

# You can see that the center tile (id:1427) has 4 neighbors (4 Mapsets),
# the ones on the sides (e.g. id:2311) have 3, and one of the 4 corners
# (e.g. id:1951) has 2 (id:2311 and id:2729). Therefore,
# those tiles with only 2 neighbors are the 4 corners
# that we are interested in to solve the first part:

# processed_tiles = %{
#   %Aoc2020.Problem20.Tile{
#     id: 1171,
#     area: ["####...##.", "#..##.#..#", "##.#..#.#.", ".###.####.", "..###.####",
#      ".##....##.", ".#...####.", "#.##.####.", "####..#...", ".....##..."],
#     sides: ["####...##.", ".##...####", "###....##.", ".##....###",
#      ".#..#.....", ".....#..#.", ".....##...", "...##....."]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1489,
#       area: ["##.#.#....", "..##...#..", ".##..##...", "..#...#...",
#        "#####...#.", "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##",
#        "###.##.#.."],
#       sides: ["##.#.#....", "....#.#.##", "#...##.#.#", "#.#.##...#",
#        ".....#..#.", ".#..#.....", "###.##.#..", "..#.##.###"]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2473,
#       area: ["#....####.", "#..#.##...", "#.##..#...", "######.#.#",
#        ".#...#.#.#", ".#########", ".###.#..#.", "########.#", "##...##.#.",
#        "..###.#.#."],
#       sides: ["#....####.", ".####....#", "####...##.", ".##...####",
#        "...###.#..", "..#.###...", "..###.#.#.", ".#.#.###.."]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 1427,
#     area: ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#", "....#...##",
#      "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#", "..##.#..#."],
#     sides: ["###.##.#..", "..#.##.###", "#..#......", "......#..#",
#      "..###.#.#.", ".#.#.###..", "..##.#..#.", ".#..#.##.."]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1489,
#       area: ["##.#.#....", "..##...#..", ".##..##...", "..#...#...",
#        "#####...#.", "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##",
#        "###.##.#.."],
#       sides: ["##.#.#....", "....#.#.##", "#...##.#.#", "#.#.##...#",
#        ".....#..#.", ".#..#.....", "###.##.#..", "..#.##.###"]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2311,
#       area: ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#",
#        "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.",
#        "..###..###"],
#       sides: ["..##.#..#.", ".#..#.##..", ".#####..#.", ".#..#####.",
#        "...#.##..#", "#..##.#...", "..###..###", "###..###.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2473,
#       area: ["#....####.", "#..#.##...", "#.##..#...", "######.#.#",
#        ".#...#.#.#", ".#########", ".###.#..#.", "########.#", "##...##.#.",
#        "..###.#.#."],
#       sides: ["#....####.", ".####....#", "####...##.", ".##...####",
#        "...###.#..", "..#.###...", "..###.#.#.", ".#.#.###.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2729,
#       area: ["...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#",
#        ".##..##.#.", ".#.####...", "####.#.#..", "##.####...", "##..#.##..",
#        "#.##...##."],
#       sides: ["...#.#.#.#", "#.#.#.#...", ".#....####", "####....#.",
#        "#..#......", "......#..#", "#.##...##.", ".##...##.#"]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 1489,
#     area: ["##.#.#....", "..##...#..", ".##..##...", "..#...#...", "#####...#.",
#      "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##", "###.##.#.."],
#     sides: ["##.#.#....", "....#.#.##", "#...##.#.#", "#.#.##...#",
#      ".....#..#.", ".#..#.....", "###.##.#..", "..#.##.###"]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1171,
#       area: ["####...##.", "#..##.#..#", "##.#..#.#.", ".###.####.",
#        "..###.####", ".##....##.", ".#...####.", "#.##.####.", "####..#...",
#        ".....##..."],
#       sides: ["####...##.", ".##...####", "###....##.", ".##....###",
#        ".#..#.....", ".....#..#.", ".....##...", "...##....."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 1427,
#       area: ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#",
#        "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#",
#        "..##.#..#."],
#       sides: ["###.##.#..", "..#.##.###", "#..#......", "......#..#",
#        "..###.#.#.", ".#.#.###..", "..##.#..#.", ".#..#.##.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2971,
#       area: ["..#.#....#", "#...###...", "#.#.###...", "##.##..#..",
#        ".#####..##", ".#..####.#", "#..#.#..#.", "..####.###", "..#.#.###.",
#        "...#.#.#.#"],
#       sides: ["..#.#....#", "#....#.#..", ".###..#...", "...#..###.",
#        "#...##.#.#", "#.#.##...#", "...#.#.#.#", "#.#.#.#..."]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 1951,
#     area: ["#.##...##.", "#.####...#", ".....#..##", "#...######", ".##.#....#",
#      ".###.#####", "###.##.##.", ".###....#.", "..#.#..#.#", "#...##.#.."],
#     sides: ["#.##...##.", ".##...##.#", "##.#..#..#", "#..#..#.##",
#      ".#####..#.", ".#..#####.", "#...##.#..", "..#.##...#"]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 2311,
#       area: ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#",
#        "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.",
#        "..###..###"],
#       sides: ["..##.#..#.", ".#..#.##..", ".#####..#.", ".#..#####.",
#        "...#.##..#", "#..##.#...", "..###..###", "###..###.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2729,
#       area: ["...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#",
#        ".##..##.#.", ".#.####...", "####.#.#..", "##.####...", "##..#.##..",
#        "#.##...##."],
#       sides: ["...#.#.#.#", "#.#.#.#...", ".#....####", "####....#.",
#        "#..#......", "......#..#", "#.##...##.", ".##...##.#"]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 2311,
#     area: ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#", "##.##.###.",
#      "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.", "..###..###"],
#     sides: ["..##.#..#.", ".#..#.##..", ".#####..#.", ".#..#####.",
#      "...#.##..#", "#..##.#...", "..###..###", "###..###.."]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1427,
#       area: ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#",
#        "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#",
#        "..##.#..#."],
#       sides: ["###.##.#..", "..#.##.###", "#..#......", "......#..#",
#        "..###.#.#.", ".#.#.###..", "..##.#..#.", ".#..#.##.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 1951,
#       area: ["#.##...##.", "#.####...#", ".....#..##", "#...######",
#        ".##.#....#", ".###.#####", "###.##.##.", ".###....#.", "..#.#..#.#",
#        "#...##.#.."],
#       sides: ["#.##...##.", ".##...##.#", "##.#..#..#", "#..#..#.##",
#        ".#####..#.", ".#..#####.", "#...##.#..", "..#.##...#"]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 3079,
#       area: ["#.#.#####.", ".#..######", "..#.......", "######....",
#        "####.#..#.", ".#...#.##.", "#.#####.##", "..#.###...", "..#.......",
#        "..#.###..."],
#       sides: ["#.#.#####.", ".#####.#.#", "#..##.#...", "...#.##..#",
#        ".#....#...", "...#....#.", "..#.###...", "...###.#.."]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 2473,
#     area: ["#....####.", "#..#.##...", "#.##..#...", "######.#.#", ".#...#.#.#",
#      ".#########", ".###.#..#.", "########.#", "##...##.#.", "..###.#.#."],
#     sides: ["#....####.", ".####....#", "####...##.", ".##...####",
#      "...###.#..", "..#.###...", "..###.#.#.", ".#.#.###.."]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1171,
#       area: ["####...##.", "#..##.#..#", "##.#..#.#.", ".###.####.",
#        "..###.####", ".##....##.", ".#...####.", "#.##.####.", "####..#...",
#        ".....##..."],
#       sides: ["####...##.", ".##...####", "###....##.", ".##....###",
#        ".#..#.....", ".....#..#.", ".....##...", "...##....."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 1427,
#       area: ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#",
#        "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#",
#        "..##.#..#."],
#       sides: ["###.##.#..", "..#.##.###", "#..#......", "......#..#",
#        "..###.#.#.", ".#.#.###..", "..##.#..#.", ".#..#.##.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 3079,
#       area: ["#.#.#####.", ".#..######", "..#.......", "######....",
#        "####.#..#.", ".#...#.##.", "#.#####.##", "..#.###...", "..#.......",
#        "..#.###..."],
#       sides: ["#.#.#####.", ".#####.#.#", "#..##.#...", "...#.##..#",
#        ".#....#...", "...#....#.", "..#.###...", "...###.#.."]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 2729,
#     area: ["...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#", ".##..##.#.",
#      ".#.####...", "####.#.#..", "##.####...", "##..#.##..", "#.##...##."],
#     sides: ["...#.#.#.#", "#.#.#.#...", ".#....####", "####....#.",
#      "#..#......", "......#..#", "#.##...##.", ".##...##.#"]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1427,
#       area: ["###.##.#..", ".#..#.##..", ".#.##.#..#", "#.#.#.##.#",
#        "....#...##", "...##..##.", "...#.#####", ".#.####.#.", "..#..###.#",
#        "..##.#..#."],
#       sides: ["###.##.#..", "..#.##.###", "#..#......", "......#..#",
#        "..###.#.#.", ".#.#.###..", "..##.#..#.", ".#..#.##.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 1951,
#       area: ["#.##...##.", "#.####...#", ".....#..##", "#...######",
#        ".##.#....#", ".###.#####", "###.##.##.", ".###....#.", "..#.#..#.#",
#        "#...##.#.."],
#       sides: ["#.##...##.", ".##...##.#", "##.#..#..#", "#..#..#.##",
#        ".#####..#.", ".#..#####.", "#...##.#..", "..#.##...#"]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2971,
#       area: ["..#.#....#", "#...###...", "#.#.###...", "##.##..#..",
#        ".#####..##", ".#..####.#", "#..#.#..#.", "..####.###", "..#.#.###.",
#        "...#.#.#.#"],
#       sides: ["..#.#....#", "#....#.#..", ".###..#...", "...#..###.",
#        "#...##.#.#", "#.#.##...#", "...#.#.#.#", "#.#.#.#..."]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 2971,
#     area: ["..#.#....#", "#...###...", "#.#.###...", "##.##..#..", ".#####..##",
#      ".#..####.#", "#..#.#..#.", "..####.###", "..#.#.###.", "...#.#.#.#"],
#     sides: ["..#.#....#", "#....#.#..", ".###..#...", "...#..###.",
#      "#...##.#.#", "#.#.##...#", "...#.#.#.#", "#.#.#.#..."]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 1489,
#       area: ["##.#.#....", "..##...#..", ".##..##...", "..#...#...",
#        "#####...#.", "#..#.#.#.#", "...#.#.#..", "##.#...##.", "..##.##.##",
#        "###.##.#.."],
#       sides: ["##.#.#....", "....#.#.##", "#...##.#.#", "#.#.##...#",
#        ".....#..#.", ".#..#.....", "###.##.#..", "..#.##.###"]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2729,
#       area: ["...#.#.#.#", "####.#....", "..#.#.....", "....#..#.#",
#        ".##..##.#.", ".#.####...", "####.#.#..", "##.####...", "##..#.##..",
#        "#.##...##."],
#       sides: ["...#.#.#.#", "#.#.#.#...", ".#....####", "####....#.",
#        "#..#......", "......#..#", "#.##...##.", ".##...##.#"]
#     }
#   ]),
#   %Aoc2020.Problem20.Tile{
#     id: 3079,
#     area: ["#.#.#####.", ".#..######", "..#.......", "######....", "####.#..#.",
#      ".#...#.##.", "#.#####.##", "..#.###...", "..#.......", "..#.###..."],
#     sides: ["#.#.#####.", ".#####.#.#", "#..##.#...", "...#.##..#",
#      ".#....#...", "...#....#.", "..#.###...", "...###.#.."]
#   } => MapSet.new([
#     %Aoc2020.Problem20.Tile{
#       id: 2311,
#       area: ["..##.#..#.", "##..#.....", "#...##..#.", "####.#...#",
#        "##.##.###.", "##...#.###", ".#.#.#..##", "..#....#..", "###...#.#.",
#        "..###..###"],
#       sides: ["..##.#..#.", ".#..#.##..", ".#####..#.", ".#..#####.",
#        "...#.##..#", "#..##.#...", "..###..###", "###..###.."]
#     },
#     %Aoc2020.Problem20.Tile{
#       id: 2473,
#       area: ["#....####.", "#..#.##...", "#.##..#...", "######.#.#",
#        ".#...#.#.#", ".#########", ".###.#..#.", "########.#", "##...##.#.",
#        "..###.#.#."],
#       sides: ["#....####.", ".####....#", "####...##.", ".##...####",
#        "...###.#..", "..#.###...", "..###.#.#.", ".#.#.###.."]
#     }
#   ])
# }
