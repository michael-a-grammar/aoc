defmodule AOC.Day2 do
  @type strategy_item :: String.t()
  @type strategy :: {String.t(), String.t()}
  @type action :: :rock | :paper | :scissors
  @type move :: {action(), action()}
  @type score :: Integer.t()
  @type move_score :: {score(), score()}
  @type round_score :: {score(), score()}
  @type total_score :: {score(), score()}
  @type result :: {:player_win | :elf_win | :draw, total_score()}

  @spec create_moves(list(strategy())) :: list(move())
  def create_moves(strategies), do: map_tuples(strategies, &create_move/1)

  @spec calculate_move_scores(list(move())) :: list(move_score)
  def calculate_move_scores(moves), do: map_tuples(moves, &calculate_move_score/1)

  @spec calculate_round_scores(list(move_score)) :: list(round_score)
  def calculate_round_scores(scores), do: Enum.map(scores, &calculate_round_score/1)

  @spec calculate_total_score(list(round_score)) :: total_score()
  def calculate_total_score(scores) do
    Enum.reduce(scores, fn {score_1, score_2}, {acc_score_1, acc_score_2} ->
      {score_1 + acc_score_1, score_2 + acc_score_2}
    end)
  end

  @spec calculate_result(total_score()) :: result()
  def calculate_result({score_1, score_2} = score) when score_1 > score_2, do: {:elf_win, score}
  def calculate_result({score_1, score_2} = score) when score_1 == score_2, do: {:draw, score}

  def calculate_result({score_1, score_2} = score) when score_1 < score_2 do
    {:player_win, score}
  end

  defp map_tuples(enumerable, fun) do
    enumerable
    |> Enum.map(fn item ->
      item
      |> Tuple.to_list()
      |> Enum.map(fun)
      |> List.to_tuple()
    end)
  end

  defguardp is_rock(strategy) when strategy in ~w(A X)
  defguardp is_paper(strategy) when strategy in ~w(B Y)
  defguardp is_scissors(strategy) when strategy in ~w(C Z)

  @spec create_move(strategy_item()) :: action()
  defp create_move(strategy) when is_rock(strategy), do: :rock
  defp create_move(strategy) when is_paper(strategy), do: :paper
  defp create_move(strategy) when is_scissors(strategy), do: :scissors

  @spec calculate_move_score(action()) :: score()
  defp calculate_move_score(:rock), do: 1
  defp calculate_move_score(:paper), do: 2
  defp calculate_move_score(:scissors), do: 3

  @spec calculate_round_score(move_score() | move_score(), score(), score()) ::
          round_score()
  defp calculate_round_score({score_1, score_2} = score) when score_1 > score_2 do
    calculate_round_score(score, 6, 0)
  end

  defp calculate_round_score({score_1, score_2} = score) when score_1 == score_2 do
    calculate_round_score(score, 3, 3)
  end

  defp calculate_round_score({score_1, score_2} = score) when score_1 < score_2 do
    calculate_round_score(score, 0, 6)
  end

  defp calculate_round_score({score_1, score_2}, outcome_score_1, outcome_score_2) do
    {score_1 + outcome_score_1, score_2 + outcome_score_2}
  end
end

ExUnit.start()

defmodule AOC.Day2.Test do
  use ExUnit.Case, async: true
  alias AOC.Day2

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
      actions = [:rock, :paper, :scissors]

      moves =
        for action_1 <- actions,
            action_2 <- actions,
            do: {action_1, action_2}

      scores = [1, 2, 3]

      expected =
        for score_1 <- scores,
            score_2 <- scores,
            do: {score_1, score_2}

      move_scores = Day2.calculate_move_scores(moves)

      assert ^move_scores = expected
    end
  end

  describe "calculate_round_scores/1" do
    test "round scores are calculated from move scores correctly" do
      move_scores = [{1, 2}, {3, 1}, {2, 3}]

      round_scores = Day2.calculate_round_scores(move_scores)

      expected = [{1, 8}, {9, 1}, {2, 9}]

      assert ^round_scores = expected
    end
  end

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

    result = Day2.calculate_result(total_score)

    expected_result = {:draw, total_score}

    assert ^result = expected_result
  end
end

File.cwd!()
|> Path.join("day2.txt")
|> File.read!()
|> String.split()
|> Enum.chunk_every(2)
|> Enum.map(&List.to_tuple/1)
|> IO.inspect()
