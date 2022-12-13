ExUnit.start()

alias AOC.Day3.Part1, as: Day3
alias AOC.Day3.Part2, as: Part2
alias AOC.Day3.Shared

defmodule AOC.Day3.Shared do
  @priorities [{?a..?z, 1}, {?A..?Z, 27}]
              |> Enum.map(fn {range, offset} ->
                for {item, priority} <- Enum.with_index(range, offset) do
                  {String.to_atom(<<item::utf8>>), priority}
                end
              end)
              |> List.flatten()

  def get_rucksacks(entries), do: String.split(entries, ~r{\n}, trim: true)

  def prioritise_items(items), do: Enum.map(items, &Keyword.get(@priorities, &1))

  def sum_priorities(priorities), do: Enum.sum(priorities)
end

defmodule AOC.Day3.Part1 do
  def compartmentalise_rucksacks(rucksacks) do
    rucksacks
    |> Enum.map(fn rucksack ->
      rucksack
      |> String.split_at(
        rucksack
        |> String.length()
        |> div(2)
      )
      |> Tuple.to_list()
    end)
  end

  def intersect_compartments(compartments) do
    compartments
    |> Enum.map(&intersect_compartment/1)
    |> List.flatten()
  end

  defp intersect_compartment(compartment) do
    compartment
    |> Enum.map(fn compartment ->
      compartment
      |> String.graphemes()
      |> MapSet.new()
    end)
    |> then(fn [item_1, item_2] ->
      MapSet.intersection(item_1, item_2)
      |> Enum.map(&String.to_atom/1)
    end)
  end
end

defmodule AOC.Day3.Part2 do
  import AOC.Day3.Shared, only: [prioritise_items: 1]

  def group_rucksacks(rucksacks), do: Enum.chunk_every(rucksacks, 3)

  def priortise_badges(rucksacks) do
    rucksacks
    |> Enum.map(fn rucksack ->
      rucksack
      |> List.flatten()
      |> Enum.map(fn rucksack ->
        rucksack
        |> String.graphemes()
        |> Enum.uniq()
      end)
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.filter(fn {_, frequency} ->
        frequency == 3
      end)
      |> Enum.at(0)
      |> elem(0)
    end)
    |> Enum.map(&String.to_atom/1)
    |> prioritise_items()
  end
end

defmodule AOC.Day3.Test do
  use ExUnit.Case, async: true

  alias AOC.Day3.Part1, as: Day3
  alias AOC.Day3.Part2
  alias AOC.Day3.Shared

  setup_all do
    %{
      input: """
      vJrwpWtwJgWrhcsFMMfFFhFp
      jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      PmmdzqPrVvPwwTWBwg
      wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ttgJtRGJQctTZtZT
      CrZsJsPPZsGzwwsLwLmpwMDw
      """
    }
  end

  describe "AOC.Day3.Shared" do
    test "get_rucksacks/1", %{input: input} do
      expected = ~w(
      vJrwpWtwJgWrhcsFMMfFFhFp
      jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      PmmdzqPrVvPwwTWBwg
      wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ttgJtRGJQctTZtZT
      CrZsJsPPZsGzwwsLwLmpwMDw)

      result = Shared.get_rucksacks(input)

      assert ^result = expected
    end
  end

  describe "AOC.Day3.Part1" do
    test "compartmentalise_rucksacks/1", %{input: input} do
      expected = [
        ["vJrwpWtwJgWr", "hcsFMMfFFhFp"],
        ["jqHRNqRjqzjGDLGL", "rsFMfFZSrLrFZsSL"],
        ["PmmdzqPrV", "vPwwTWBwg"],
        ["wMqvLMZHhHMvwLH", "jbvcjnnSBnvTQFn"],
        ["ttgJtRGJ", "QctTZtZT"],
        ["CrZsJsPPZsGz", "wwsLwLmpwMDw"]
      ]

      result =
        input
        |> Shared.get_rucksacks()
        |> Day3.compartmentalise_rucksacks()

      assert ^result = expected
    end

    test "intersect_compartments/1", %{input: input} do
      expected = [:p, :L, :P, :v, :t, :s]

      result =
        input
        |> Shared.get_rucksacks()
        |> Day3.compartmentalise_rucksacks()
        |> Day3.intersect_compartments()

      assert ^result = expected
    end

    test "prioritise_items/1", %{input: input} do
      expected = [16, 38, 42, 22, 20, 19]

      result =
        input
        |> Shared.get_rucksacks()
        |> Day3.compartmentalise_rucksacks()
        |> Day3.intersect_compartments()
        |> Shared.prioritise_items()

      assert ^result = expected
    end

    test "sum_priorities/1", %{input: input} do
      expected = 157

      result =
        input
        |> Shared.get_rucksacks()
        |> Day3.compartmentalise_rucksacks()
        |> Day3.intersect_compartments()
        |> Shared.prioritise_items()
        |> Shared.sum_priorities()

      assert ^result = expected
    end
  end

  describe "AOC.Day3.Part2" do
    test "group_rucksacks/1", %{input: input} do
      expected = [
        ["vJrwpWtwJgWrhcsFMMfFFhFp", "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL", "PmmdzqPrVvPwwTWBwg"],
        ["wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn", "ttgJtRGJQctTZtZT", "CrZsJsPPZsGzwwsLwLmpwMDw"]
      ]

      result =
        input
        |> Shared.get_rucksacks()
        |> Part2.group_rucksacks()

      assert ^result = expected
    end

    test "priortise_badges/1", %{input: input} do
      expected = [18, 52]

      result =
        Shared.get_rucksacks(input)
        |> Part2.group_rucksacks()
        |> Part2.priortise_badges()

      assert ^result = expected
    end
  end
end

File.cwd!()
|> Path.join("day3.txt")
|> File.read!()
|> Shared.get_rucksacks()
|> Day3.compartmentalise_rucksacks()
|> Day3.intersect_compartments()
|> Shared.prioritise_items()
|> Shared.sum_priorities()
|> IO.inspect()

File.cwd!()
|> Path.join("day3.txt")
|> File.read!()
|> Shared.get_rucksacks()
|> Part2.group_rucksacks()
|> Part2.priortise_badges()
|> Shared.sum_priorities()
|> IO.inspect()
