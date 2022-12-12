alias AOC.Day2

defmodule AOC.Day2.Move do
  @enforce_keys [:name, :wins_against, :loses_against, :entry, :score]
  defstruct [:name, :wins_against, :loses_against, :entry, :score]
end

defmodule AOC.Day2.Moves do
  alias AOC.Day2.Move

  @moves [
    %Move{
      name: :rock,
      wins_against: :scissors,
      loses_against: :paper,
      entry: "A",
      score: 1
    },
    %Move{
      name: :paper,
      wins_against: :rock,
      loses_against: :scissors,
      entry: "B",
      score: 2
    },
    %Move{
      name: :scissors,
      wins_against: :paper,
      loses_against: :rock,
      entry: "C",
      score: 3
    }
  ]

  def get_moves(), do: @moves

  def find_move(move_name), do: Enum.find(@moves, fn move -> move.name == move_name end)
end

defmodule AOC.Day2.Result do
  @enforce_keys [:name, :entry]
  defstruct [:name, :entry]
end

defmodule AOC.Day2.Results do
  alias AOC.Day2.Result

  @results [
    %Result{
      name: :elf_win,
      entry: "X"
    },
    %Result{
      name: :draw,
      entry: "Y"
    },
    %Result{
      name: :player_win,
      entry: "Z"
    }
  ]

  def get_results(), do: @results
end

defmodule AOC.Day2.Macros do
  alias AOC.Day2.Moves
  alias AOC.Day2.Results

  defmacro __using__(_opts) do
    moves = Moves.get_moves()

    Enum.concat(
      for move <- moves,
          result <- Results.get_results() do
        [
          generate_map_entry_to_round(move, result),
          generate_map_round_result_to_move(move, result)
        ]
      end,
      for move <- moves do
        [
          generate_map_round_to_move_score(move),
          generate_map_move_score_to_round_score(move)
        ]
      end
    )
  end

  defp generate_map_entry_to_round(move, result) do
    quote do
      defp map_entry_to_round({unquote(move.entry), unquote(result.entry)}) do
        {unquote(move.name), unquote(result.name)}
      end
    end
  end

  defp generate_map_round_result_to_move(move, result) do
    mapped_move =
      case result.name do
        :elf_win ->
          move.wins_against

        :draw ->
          move.name

        :player_win ->
          move.loses_against
      end

    quote do
      defp map_round_result_to_move({unquote(move.name), unquote(result.name)}) do
        {unquote(move.name), unquote(mapped_move)}
      end
    end
  end

  defp generate_map_round_to_move_score(move) do
    move_wins_against = Moves.find_move(move.wins_against)
    move_loses_against = Moves.find_move(move.loses_against)

    generate = fn move_1, move_2 ->
      quote do
        defp map_round_to_move_score({unquote(move_1.name), unquote(move_2.name)}) do
          {
            {
              unquote(move_1.name),
              unquote(move_1.score)
            },
            {
              unquote(move_2.name),
              unquote(move_2.score)
            }
          }
        end
      end
    end

    [
      generate.(move, move_wins_against),
      generate.(move, move_loses_against),
      generate.(move, move)
    ]
  end

  defp generate_map_move_score_to_round_score(move) do
    move_wins_against = Moves.find_move(move.wins_against)
    move_loses_against = Moves.find_move(move.loses_against)

    generate = fn move_1, move_2, round_score_1, round_score_2 ->
      quote do
        defp map_move_score_to_round_score(
               {{unquote(move_1.name), move_score_1}, {unquote(move_2.name), move_score_2}}
             ) do
          {
            move_score_1 + unquote(round_score_1),
            move_score_2 + unquote(round_score_2)
          }
        end
      end
    end

    [
      generate.(move, move_wins_against, 6, 0),
      generate.(move, move_loses_against, 0, 6),
      generate.(move, move, 3, 3)
    ]
  end
end

defmodule AOC.Day2 do
  use AOC.Day2.Macros

  def map(entries) do
    entries
    |> map_entries_to_rounds()
    |> map_round_results_to_moves()
    |> map_rounds_to_move_scores()
    |> map_move_scores_to_round_scores()
    |> calculate_total_scores()
    |> calculate_grand_result()
  end

  defp map_entries_to_rounds(entries) do
    Enum.map(entries, &map_entry_to_round/1)
  end

  defp map_round_results_to_moves(rounds) do
    Enum.map(rounds, &map_round_result_to_move/1)
  end

  defp map_rounds_to_move_scores(rounds) do
    Enum.map(rounds, &map_round_to_move_score/1)
  end

  defp map_move_scores_to_round_scores(move_scores) do
    Enum.map(move_scores, &map_move_score_to_round_score/1)
  end

  defp calculate_total_scores(round_scores) do
    Enum.reduce(round_scores, fn {round_score_1, round_score_2},
                                 {acc_round_score_1, acc_round_score_2} ->
      {
        round_score_1 + acc_round_score_1,
        round_score_2 + acc_round_score_2
      }
    end)
  end

  defp calculate_grand_result({total_score_1, total_score_2} = total_scores)
       when total_score_1 > total_score_2 do
    {:elf_win, total_scores}
  end

  defp calculate_grand_result({total_score_1, total_score_2} = total_scores)
       when total_score_1 == total_score_2 do
    {:draw, total_scores}
  end

  defp calculate_grand_result({total_score_1, total_score_2} = total_scores)
       when total_score_1 < total_score_2 do
    {:player_win, total_scores}
  end
end

ExUnit.start()

defmodule AOC.Day2.Test do
  alias AOC.Day2
  use ExUnit.Case

  describe "map/1" do
    test "example input" do
      entries = [{"A", "Y"}, {"B", "X"}, {"C", "Z"}]

      expected = {:elf_win, {15, 12}}

      result = Day2.map(entries)

      assert ^result = expected
    end
  end
end

File.cwd!()
|> Path.join("day2.txt")
|> File.read!()
|> String.split()
|> Enum.chunk_every(2)
|> Enum.map(&List.to_tuple/1)
|> Day2.map()
|> IO.inspect()
