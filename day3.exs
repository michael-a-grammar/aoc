ExUnit.start()

defmodule AOC.Day3 do
  @priorities [{?a..?z, 1}, {?A..?Z, 27}]
              |> Enum.map(fn {range, offset} ->
                for {item, priority} <- Enum.with_index(range, offset) do
                  {String.to_atom(<<item::utf8>>), priority}
                end
              end)
              |> List.flatten()

  def get_rucksacks(entries) do
    String.split(entries, ~r{\n}, trim: true)
  end

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
    Enum.map(compartments, &intersect_compartment/1)
    |> List.flatten()
  end

  def prioritise_items(items) do
    Enum.map(items, &Keyword.get(@priorities, &1))
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

defmodule AOC.Day3.Test do
  use ExUnit.Case, async: true

  alias AOC.Day3

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

  test "get_rucksacks/1", %{input: input} do
    expected = ~w(
      vJrwpWtwJgWrhcsFMMfFFhFp
      jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      PmmdzqPrVvPwwTWBwg
      wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ttgJtRGJQctTZtZT
      CrZsJsPPZsGzwwsLwLmpwMDw)

    result = Day3.get_rucksacks(input)

    assert ^result = expected
  end

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
      |> Day3.get_rucksacks()
      |> Day3.compartmentalise_rucksacks()

    assert ^result = expected
  end

  test "intersect_compartments/1", %{input: input} do
    expected = [:p, :L, :P, :v, :t, :s]

    result =
      input
      |> Day3.get_rucksacks()
      |> Day3.compartmentalise_rucksacks()
      |> Day3.intersect_compartments()

    assert ^result = expected
  end

  test "prioritise_items/1", %{input: input} do
    expected = [16, 38, 42, 22, 20, 19]

    result =
      input
      |> Day3.get_rucksacks()
      |> Day3.compartmentalise_rucksacks()
      |> Day3.intersect_compartments()
      |> Day3.prioritise_items()

    assert ^result = expected
  end
end
