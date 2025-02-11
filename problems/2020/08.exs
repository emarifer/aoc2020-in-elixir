defmodule Aoc2020.Problem08 do
  # ================== Start Part 1 ==================

  defp parse_instr1(data) do
    data
    |> Enum.map(fn row ->
      [op, num] = String.split(row)
      op = String.to_atom(op)
      num = String.to_integer(num)
      {op, num}
    end)
  end

  defp run_program(program), do: run_program(program, 0, 0)

  defp run_program(program, pointer, acc, history \\ []) do
    if pointer in history do
      {:started_loop, acc}
    else
      case Enum.at(program, pointer) do
        {:nop, _} ->
          run_program(program, pointer + 1, acc, [pointer | history])

        {:acc, arg} ->
          run_program(program, pointer + 1, acc + arg, [pointer | history])

        {:jmp, arg} ->
          run_program(program, pointer + arg, acc, [pointer | history])

        nil ->
          {:program_exited, acc}
      end
    end
  end

  def problem1(data) do
    {:started_loop, res} =
      data
      |> parse_instr1()
      |> run_program()

    res
  end

  # ================== End Part 1 ====================

  # ================== Start Part 2 ==================

  defp parse_instr2(data) do
    # add = &Map.put(&1, map_size(&1), :fin)

    data
    |> Enum.with_index()
    |> Enum.map(fn {row, idx} ->
      [op, num] = String.split(row)
      op = String.to_atom(op)
      num = String.to_integer(num)
      {idx, {op, num}}
    end)
    |> Map.new()
    |> (&Map.put(&1, map_size(&1), :fin)).()
  end

  defp reduce(instr, ptr \\ 0, acc \\ 0, changed \\ false) do
    case Map.pop(instr, ptr) do
      {{:nop, n}, instr} ->
        reduce(instr, ptr + 1, acc, changed) ||
          unless changed, do: reduce(instr, ptr + n, acc, true)

      {{:jmp, n}, instr} ->
        reduce(instr, ptr + n, acc, changed) ||
          unless changed, do: reduce(instr, ptr + 1, acc, true)

      {{:acc, n}, instr} ->
        reduce(instr, ptr + 1, acc + n, changed)

      {nil, _instr} ->
        false

      {:fin, _instr} ->
        acc
    end
  end

  def problem2(data) do
    data
    |> parse_instr2()
    |> reduce()
  end

  # ================== End Part 2 ====================
end

{:ok, sample} = Aoc.read_lines("inputs/sample.program", "\n")
{:ok, lines} = Aoc.read_lines("inputs/08.input", "\n")

# Part #1
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem08.problem1/1)

# Part #2
[sample, lines]
|> Aoc.runner(&Aoc2020.Problem08.problem2/1)

# Part #1
# 5 <- Proposed example
# 1489 <- Result

# Part #2
# 8 <- Proposed example
# 1539 <- Result

# REFERENCES:
# instr =
#   sample
#   |> Enum.with_index()
#   |> Enum.map(fn {row, idx} ->
#     [op, num] = String.split(row)
#     op = String.to_atom(op)
#     num = String.to_integer(num)
#     {idx, {op, num}}
#   end)
#   |> Map.new()
#   |> IO.inspect()

# instr =
#   Map.put(instr, map_size(instr), :fin)
#   |> IO.inspect()

# instr |> Aoc2020.Problem08.run_program(0, 0) |> IO.inspect()
# instr |> Enum.at(5) |> IO.inspect()

# sample |> Aoc2020.Problem08.problem2() |> IO.inspect()

# IMPORTANTE!! SOBRE LA FUNCIÓN `reduce`:
# `reduce` toma como valores iniciales el mapa de instrucciones, p.ej:
# %{
#   0 => {:nop, 0},
#   1 => {:acc, 1},
#   2 => {:jmp, 4},
#   3 => {:acc, 3},
#   4 => {:jmp, -3},
#   5 => {:acc, -99},
#   6 => {:acc, 1},
#   7 => {:jmp, -4},
#   8 => {:acc, 6},
#   9 => :fin
# },
# el puntero de la instrucción (`key` del mapa), el acumulador,
# y un flag (`changed`) para simular el cambio de comportamiento que
# resultaría de cambiar un `:nop` por un `:jmp` o viceversa. En el primer caso,
# `{:nop, n} => ptr + n`, y en segundo caso `{:jmp, n} => ptr + 1`.
# Si `changed` es true y el resultado de `reduce` en la segunda
# llamada recursiva sigue siendo false, dado que el flag `changed` está a true
# no se volverá a intentar una nueva llamada recursiva. Realmente `changed`
# sólo se pone a true una única vez, es decir, que aseguramos que la
# sustitución de `:nop` a `:jmp` o viceversa sólo se hará una vez.
# Dado que `Map.pop` va quitando la instrucción apuntada por el puntero
# se evita que la función `reduce` vuelva a llamar
# a la misma instrucción por segunda vez y entre en un bucle infinito.
# Esto hará que estemos en el case `{nil, _instr}` y `reduce` devuelva false.
# La consecuencia de ello será que en los casos de `{:nop, n}` y `{:jmp, n}`
# se intentará el cambio de comportamiento anteriormente dicho.
# Finalmente, si se alcanza la instrucción `:fin` se devolverá el valor
# del acumulador, lo cual es `truthy`,
# [ver: https://hexdocs.pm/elixir/Kernel.html#module-truthy-and-falsy-values]
# por lo que en `cortocircuito` || no se volverá a llamar el `unless`
# y ese será el resultado final que devolverá la función.
