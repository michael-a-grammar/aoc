defmodule AOC.Day2.Macros do
  defmacro __using__(_opts) do
    [rock: :scissors, paper: :rock, scissors: :paper]
    |> Enum.map(fn {action_1, action_2} ->
      [
        generate_calculate_round_score({action_1, action_2}, {6, 0}),
        generate_calculate_round_score({action_2, action_1}, {0, 6}),
        generate_calculate_round_score({action_1, action_1}, {3, 3})
      ]
    end)
  end

  defp generate_calculate_round_score(action, round_score) do
    quote do
      def calculate_round_score({unquote(action), {move_score_1, move_score_2}}) do
        {round_score_1, round_score_2} = unquote(round_score)

        {move_score_1 + round_score_1, move_score_2 + round_score_2}
      end
    end
  end
end

defmodule AOC.Day2 do
  use AOC.Day2.Macros

  @type strategy_item :: String.t()
  @type strategy :: {strategy_item(), strategy_item()}
  @type action :: :rock | :paper | :scissors
  @type move :: {action(), action()}
  @type score :: Integer.t()
  @type round_score :: {score(), score()}
  @type move_score :: {move(), round_score()}
  @type total_score :: {score(), score()}
  @type result :: :player_win | :elf_win | :draw
  @type grand_result :: {result(), total_score()}

  @spec create_moves(list(strategy())) :: list(move())
  def create_moves(strategies), do: map_tuples(strategies, &create_move/1)

  @spec calculate_move_scores(list(move())) :: list(move_score)
  def calculate_move_scores(moves) do
    map_tuples(moves, &calculate_score/1, fn move, round_score ->
      {move, round_score}
    end)
  end

  @spec calculate_round_scores(list(move_score)) :: list(round_score)
  def calculate_round_scores(scores), do: Enum.map(scores, &calculate_round_score/1)

  @spec calculate_total_score(list(round_score)) :: total_score()
  def calculate_total_score(scores) do
    Enum.reduce(scores, fn {score_1, score_2}, {acc_score_1, acc_score_2} ->
      {score_1 + acc_score_1, score_2 + acc_score_2}
    end)
  end

  @spec calculate_grand_result(total_score()) :: grand_result()
  def calculate_grand_result({score_1, score_2} = score) when score_1 > score_2 do
    {:elf_win, score}
  end

  def calculate_grand_result({score_1, score_2} = score) when score_1 == score_2 do
    {:draw, score}
  end

  def calculate_grand_result({score_1, score_2} = score) when score_1 < score_2 do
    {:player_win, score}
  end

  defp map_tuples(enumerable, map_fn, then_fn \\ nil) do
    enumerable
    |> Enum.map(fn item ->
      item
      |> Tuple.to_list()
      |> Enum.map(map_fn)
      |> List.to_tuple()
      |> then(fn tuple ->
        case then_fn do
          then_fn when is_function(then_fn, 2) ->
            then_fn.(item, tuple)

          nil ->
            tuple
        end
      end)
    end)
  end

  defguardp is_rock(strategy) when strategy in ~w(A X)
  defguardp is_paper(strategy) when strategy in ~w(B Y)
  defguardp is_scissors(strategy) when strategy in ~w(C Z)

  @spec create_move(strategy_item()) :: action()
  defp create_move(strategy) when is_rock(strategy), do: :rock
  defp create_move(strategy) when is_paper(strategy), do: :paper
  defp create_move(strategy) when is_scissors(strategy), do: :scissors

  @spec calculate_score(action()) :: score()
  defp calculate_score(:rock), do: 1
  defp calculate_score(:paper), do: 2
  defp calculate_score(:scissors), do: 3
end

ExUnit.start()
alias AOC.Day2

defmodule AOC.Day2.Test do
  use ExUnit.Case, async: true

  test "example input" do
    round_scores =
      [{"A", "Y"}, {"B", "X"}, {"C", "Z"}]
      |> Day2.create_moves()
      |> Day2.calculate_move_scores()
      |> Day2.calculate_round_scores()

    expected_round_scores = [{1, 8}, {8, 1}, {6, 6}]

    assert ^round_scores = expected_round_scores

    total_score = Day2.calculate_total_score(round_scores)

    expected_total_score = {15, 15}

    assert ^total_score = expected_total_score

    grand_result = Day2.calculate_grand_result(total_score)

    expected_grand_result = {:draw, total_score}

    assert ^grand_result = expected_grand_result
  end

  describe "create_moves/1" do
    test "moves are created from strategies correctly" do
      strategies =
        for strategy_1 <- ~w(A B C),
            strategy_2 <- ~w(X Y Z),
            do: {strategy_1, strategy_2}

      actions = [:rock, :paper, :scissors]

      moves = Day2.create_moves(strategies)

      expected =
        for action_1 <- actions,
            action_2 <- actions,
            do: {action_1, action_2}

      assert ^moves = expected
    end

    test "incorrect strategies raise an error" do
      strategies =
        for strategy_1 <- ~w(D E F),
            strategy_2 <- ~w(U V W),
            strategy_1 != strategy_2,
            do: {strategy_1, strategy_2}

      assert_raise FunctionClauseError, fn ->
        Day2.create_moves(strategies)
      end
    end
  end

  describe "calculate_move_scores/1" do
    test "move scores are calculated from moves correctly" do
      moves = [
        {:rock, :paper},
        {:scissors, :rock},
        {:paper, :scissors},
        {:paper, :rock},
        {:rock, :scissors},
        {:scissors, :paper}
      ]

      expected = [
        {{:rock, :paper}, {1, 2}},
        {{:scissors, :rock}, {3, 1}},
        {{:paper, :scissors}, {2, 3}},
        {{:paper, :rock}, {2, 1}},
        {{:rock, :scissors}, {1, 3}},
        {{:scissors, :paper}, {3, 2}}
      ]

      move_scores = Day2.calculate_move_scores(moves)

      assert ^move_scores = expected
    end
  end

  describe "calculate_round_scores/1" do
    test "round scores are calculated from move scores correctly" do
      move_scores = [
        {{:rock, :paper}, {1, 2}},
        {{:scissors, :rock}, {3, 1}},
        {{:paper, :scissors}, {2, 3}},
        {{:paper, :rock}, {2, 1}},
        {{:rock, :scissors}, {1, 3}},
        {{:scissors, :paper}, {3, 2}}
      ]

      round_scores = Day2.calculate_round_scores(move_scores)

      expected = [{1, 8}, {3, 7}, {2, 9}, {8, 1}, {7, 3}, {9, 2}]

      assert ^round_scores = expected
    end
  end
end

File.cwd!()
|> Path.join("day2.txt")
|> File.read!()
|> String.split()
|> Enum.chunk_every(2)
|> Enum.map(&List.to_tuple/1)
|> Day2.create_moves()
|> Day2.calculate_move_scores()
|> Day2.calculate_round_scores()
|> Day2.calculate_total_score()
|> Day2.calculate_grand_result()
|> IO.inspect()
