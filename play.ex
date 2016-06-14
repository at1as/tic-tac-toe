defmodule Print do
  alias Print

  def separator do
    IO.puts("#{padding}|-----|-----|-----|")
  end

  def columns(row, letter \\ " ") do
    [first, second, third] = Enum.map(row, fn(x) -> 
      if x == nil, do: " ", else: x 
    end)
    IO.puts("#{padding(letter)}|  #{first}  |  #{second}  |  #{third}  |")
  end

  def columns do
    IO.puts "#{padding}|     |     |     |"
  end

  def header do
    IO.write "#{padding} "
    Enum.each(['A', 'B', 'C'], fn x ->
      IO.write("  #{x}   ")
    end)
    IO.write("\n")
  end

  def padding(letter \\ " ") do
    " #{letter} "
  end
  
  def line(board, max) do
    line(board, max, 0)
  end

  def line(board, max, idx) when max == idx do
    separator
  end

  def line(board, max, idx) when max > idx do
    current_row = Enum.at(board, idx)

    separator
    columns
    columns(current_row, idx + 1)
    columns
    line(board, max, idx + 1)
  end

  def board(board) do
    row_count = 3
    header
    line(board, row_count)
  end
end


defmodule Board do
  def mapping do
    [[nil, nil, nil],
     [nil, nil, nil],
     [nil, nil, nil]]
  end
end


defmodule Game do

  def vertical_winner(board, piece) do
    Enum.any?([0,1,2], fn(y) -> 
     Enum.all?(board, fn(x) -> 
      Enum.at(x, y) == piece
     end) 
    end)
  end

  def horizontal_winner(board, piece) do
    Enum.any?(board, fn(x) -> 
     Enum.all?(x, fn(y) -> 
      y == piece
     end)
    end) 
  end

  def backslash_diagonal_winner(board, piece) do
    Enum.all?([0, 1, 2], fn(x) -> 
     Enum.at(Enum.at(board, x), x) == piece
    end)
  end

  def forwardslash_diagonal_winner(board, piece) do
    Enum.all?([0, 1, 2], fn(x) -> 
     Enum.at(Enum.at(board, x), 2 - x) == piece
    end)
  end

  def winner?(board, piece) do
    (
      forwardslash_diagonal_winner(board, piece) ||
      backslash_diagonal_winner(board, piece) ||
      horizontal_winner(board, piece) ||
      vertical_winner(board, piece)
    )
  end

  def place_piece do
    IO.gets "\nWhere do you want to place your piece? \n> "
  end

  def play(board \\ Board.mapping, piece \\ 'x') do
    
    Print.board(board)

    placement = place_piece

    # Input validation and translation
    # TODO: Catch invalid row
    col_let = String.at(placement, 0) |> String.upcase |> String.replace_trailing("\n", "")
    col_num = Enum.zip(["A", "B", "C"], [0, 1, 2]) |> Map.new |> Map.get(col_let)
    row_num = String.at(placement, 1) |> String.to_integer
    row_num = row_num - 1

    unless Enum.member?(["A", "B", "C"], col_let) do
      IO.puts "Please select columns A, B, or C (like 'A2', 'B3', etc)"
      play(board, piece)
    end

    unless Enum.member?([0, 1, 2], row_num) do
      IO.puts "Please select row 1, 2 or 3 (like 'A1', 'B3', etc)"
      play(board, piece)
    end

    current_char = Enum.at(board, row_num) |> Enum.at(col_num)
   
    unless current_char == nil do
      IO.puts "Space is already occupied"
      play(board, piece)
    end

    board = List.update_at(board, row_num, fn(x) -> List.update_at(x, col_num, fn(y) -> piece end ) end )
    if winner?(board, piece), do: IO.puts "\n#{piece} WINS!!\n"

    if piece == 'x', do: piece = 'o', else: piece = 'x'
    play(board, piece)
  end
  
end
