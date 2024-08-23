defmodule Cek do
  def cek(data) do
    a = data
    b = 2
    cond do
      a+b > 2 -> a+b
      a+b > 1 -> a-b
    end

  end
end

a = 10
b = a
|> Cek.cek()
|> Cek.cek()

d = %{adult: 1, infant: 2}
Enum.reduce(d, fn item ->
  IO.inspect(item)
  # {key, value} = item
  # %{
  #    key=> value
  # }
end)
|> IO.inspect()
cond do
  7 + 1 == 0 -> "Incorrect"
  true -> "Catch all"
end

IO.puts b
