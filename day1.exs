File.cwd!()
|> Path.join("day1.txt")
|> File.read!()
|> String.split(~r{\n\n})
|> Enum.map(fn elves ->
  elves
  |> String.split()
  |> Enum.map(&elem(Integer.parse(&1), 0))
  |> Enum.sum()
end)
|> Enum.max_by(& &1)
|> IO.inspect(label: "Here")
