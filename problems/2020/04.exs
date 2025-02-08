defmodule Aoc2020.Problem04 do
  # ================== Start Part 1 ==================
  defp clean_passport(passports) do
    passports |> Enum.map(&String.replace(&1, "\n", " "))
  end

  defp validate_passport1?(passport, fields) do
    fields
    |> Enum.filter(&String.contains?(passport, &1))
    |> Enum.count() == 7
  end

  # Alternative:
  # defp validate_passport1a?(passport) do
  #   tokens = String.split(passport, " ")
  #   Enum.count(tokens) == 8 || (Enum.count(tokens) == 7 && !String.contains?(passport, "cid"))
  # end

  def passports_counter1(passports) do
    required_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

    passports
    |> clean_passport
    |> Enum.filter(&validate_passport1?(&1, required_fields))
    # |> Enum.filter(&validate_passport1a?/1)
    |> Enum.count()
  end

  # ================== End Part 1 ==================

  # ================== Start Part 2 ================
  defp validate_data?(_, nil, _), do: false

  defp validate_data?(:range, value, {min, max}) do
    case Integer.parse(value) do
      :error -> false
      {x, ""} -> x >= min && x <= max
    end
  end

  defp validate_data?(:height, value, _) do
    case Integer.parse(value) do
      :error -> false
      {x, "cm"} -> x >= 150 && x <= 193
      {x, "in"} -> x >= 59 && x <= 76
      {_x, _} -> false
    end
  end

  defp validate_data?(:hair, value, _) do
    value =~ ~r/^#[[:xdigit:]]{6}$/
  end

  defp validate_data?(:eye, value, _) do
    valids = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    Enum.any?(valids, &(&1 == value))
  end

  defp validate_data?(:pass_id, value, _) do
    value =~ ~r/^[[:digit:]]{9}$/
  end

  defp validate_passport2?(line) do
    passport =
      line
      |> String.split()
      |> Enum.map(&String.split(&1, ":"))
      |> Enum.map(fn [k, v] -> {k, v} end)
      |> Map.new()

    validate_data?(:range, passport["byr"], {1920, 2002}) &&
      validate_data?(:range, passport["iyr"], {2010, 2020}) &&
      validate_data?(:range, passport["eyr"], {2020, 2030}) &&
      validate_data?(:height, passport["hgt"], {}) &&
      validate_data?(:hair, passport["hcl"], {}) &&
      validate_data?(:eye, passport["ecl"], {}) &&
      validate_data?(:pass_id, passport["pid"], {})
  end

  def passports_counter2(passports) do
    passports
    |> clean_passport
    |> Enum.filter(&validate_passport2?/1)
    |> Enum.count()
  end

  # ================== End Part 2 ==================
end

_sample_1 = """
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
"""

{:ok, sample} = Aoc.read_lines("inputs/sample.passport", "\n\n")
{:ok, lines} = Aoc.read_lines("inputs/04.input", "\n\n")

# Part #1
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem04.passports_counter1/1)

# Part #2
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem04.passports_counter2/1)

# Part #1
# 2 <- Proposed example (_sample_1, 8 in the second sample)
# 237 <- Result

# Part #2
# 4 <- Proposed example
# 172 <- Result
