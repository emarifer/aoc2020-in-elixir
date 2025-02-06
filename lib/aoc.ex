defmodule Aoc do
  @moduledoc """
  Library functions for performing AOC2020 exercises.
  """

  @doc """
  AOC.

  Function that reads input files with lists of numeric data.

  Returns: `{:ok, [String.t()]}`

  ## Examples

      iex> Aoc.read_lines("test/lines.txt")
      {:ok, ["789793", "8080", "25344"]}

  """
  def read_lines(path), do: File.read(path) |> fmap(&String.split/1)

  @doc """
  AOC.

  Function that reads input files with character maps.

  Returns: `{:ok, charlist()}`

  ## Examples

      iex> Aoc.read_map("test/map.txt")
      {:ok,
        [
          [".", ".", "."],
          ["#", ".", "."],
          [".", "#", "#"]
        ]
      }

  """
  def read_map(path),
    do:
      File.read(path)
      |> fmap(&String.split/1)
      |> fmap(fn i -> Enum.map(i, &String.codepoints/1) end)

  @doc """
  AOC.

  Function that, given a list of character lists and some coordinates (pair of indices), finds the requested character.

  Returns: `char()`

  ## Examples

      iex> {:ok, map} = Aoc.read_map("test/map.txt")
      {:ok, [[".", ".", "."], ["#", ".", "."], [".", "#", "#"]]}
      iex> Aoc.at_map(map, 2, 2)
      "#"

  """
  def at_map(map, x, y), do: map |> Enum.at(y) |> Enum.at(x)

  def fmap({:ok, x}, f), do: {:ok, f.(x)}

  @doc """
  AOC.

  ## Helper function that applies the given function to the successful value of a tuple. In case of a failed value, the function is not applied and the given tuple is returned without transformation.

  """
  def fmap(whatever, _), do: whatever

  @doc """
  AOC.

  ## Helper function that maps a given function to a list of inputs, outputting to standard output the result of applying the given function to each of the inputs in the list.

  """
  def runner(inputs, f), do: Enum.map(inputs, fn i -> IO.inspect(f.(i)) end)
end

# def validate_str_as_int(str) do
#   try do
#     String.to_integer(str)
#   rescue
#     ArgumentError -> 0
#   end
# end

# defp validate_result(list) do
#   if list
#      |> Enum.find(fn item -> to_match(item) end) do
#     {:error, "error parsing integer"}
#   else
#     {:ok, list |> Enum.map(fn {_, n} -> n end)}
#   end
# end

# defp to_match(item) do
#   case item do
#     {:error, _} -> true
#     _ -> false
#   end
# end

# Mi implementación personal:
# def read_lines(path_file) do
#   with {:ok, file_content} <- File.read(path_file),
#        data <- String.split(file_content),
#        tuple_list <- Enum.map(data, fn str -> validate_integer(str) end),
#        {:ok, result} <- tuple_list |> validate_result do
#     result
#   else
#     {_, :enoent} -> "error opening file"
#     {_, msg} -> msg
#   end
# end

# defp validate_integer(str) do
#   try do
#     value = String.to_integer(str)
#     {:ok, value}
#   rescue
#     ArgumentError -> {:error, "error parsing integer"}
#   end
# end

# defp validate_result(list) do
#   if list
#      |> Enum.find(fn item -> to_match(item) end) do
#     {:error, "error parsing integer"}
#   else
#     {:ok, list |> Enum.map(fn {_, n} -> n end)}
#   end
# end

# defp to_match(item) do
#   case item do
#     {:error, _} -> true
#     _ -> false
#   end
# end
