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

  def line(_, max, idx) when max == idx do
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

  def unoccupied?(board, row_num, col_num) do
    Enum.at(board, row_num) |> Enum.at(col_num) == nil
  end

  def full?(board) do
    Enum.all?(board, fn(row) -> 
     Enum.all?(row, fn(cell) -> 
      cell != nil 
     end)
    end)
  end
end


defmodule Winner do
  alias Winner

  def winner?(board, piece) do
    (
      forwardslash_diagonal_winner(board, piece) ||
      backslash_diagonal_winner(board, piece) ||
      horizontal_winner(board, piece) ||
      vertical_winner(board, piece)
    )
  end
  
  def vertical_winner(board, piece) do # shape |
    Enum.any?([0,1,2], fn(y) -> 
     Enum.all?(board, fn(x) -> 
      Enum.at(x, y) == piece
     end) 
    end)
  end

  def horizontal_winner(board, piece) do # shape -
    Enum.any?(board, fn(x) -> 
     Enum.all?(x, fn(y) -> 
      y == piece
     end)
    end) 
  end

  def backslash_diagonal_winner(board, piece) do # shape \
    Enum.all?([0, 1, 2], fn(x) -> 
     Enum.at(Enum.at(board, x), x) == piece
    end)
  end

  def forwardslash_diagonal_winner(board, piece) do # shape /
    Enum.all?([0, 1, 2], fn(x) -> 
     Enum.at(Enum.at(board, x), 2 - x) == piece
    end)
  end

end


defmodule Game do

  def place_piece(piece \\ :x) do
    IO.gets "\nWhere do you want to place your piece (#{piece})? \n> "
  end

  def play(board \\ Board.mapping, piece \\ :x) do
    
    Print.board(board)

    placement = place_piece(piece)

    # Input validation and translation
    col_let = String.at(placement, 0) |> String.upcase |> String.replace_trailing("\n", "")
    col_num = Enum.zip(["A", "B", "C"], [0, 1, 2]) |> Map.new |> Map.get(col_let)
    row_num = String.at(placement, 1) |> Integer.parse

    row_num = case row_num do
      :error ->
        IO.puts "Please enter a valid row 1, 2, 3 (like 'A1', 'B3', etc)"
        play(board, piece)
      _ ->
        {row_num, _} = row_num
        row_num - 1
    end
   
    unless Enum.member?(["A", "B", "C"], col_let) do
      IO.puts "Please select columns A, B, or C (like 'A2', 'B3', etc)"
      play(board, piece)
    end

    unless Enum.member?([0, 1, 2], row_num) do
      IO.puts "Please select row 1, 2 or 3 (like 'A1', 'B3', etc)"
      play(board, piece)
    end

    unless Board.unoccupied?(board, row_num, col_num) do
      IO.puts "Space is already occupied"
      play(board, piece)
    end

    # Update board
    board = List.update_at(board, row_num, fn(x) -> 
      List.update_at(x, col_num, fn(_) -> 
       piece 
      end)
    end)

    if Winner.winner?(board, piece) do
      Game.victory(board, piece)
    else
      if Board.full?(board) do
        Game.stalemate
      else
        piece = if piece == :x, do: :o, else: :x
        play(board, piece)
      end
    end
  end

  def victory(board, piece) do
    Print.board(board)
    IO.puts "\nPlayer piece #{piece} wins!\n"
    Game.play
  end

  def stalemate do
    IO.puts "\n Nobody wins! Starting new game...\n"
    Game.play
  end
end
