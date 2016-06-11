defmodule Board do
  alias Board

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
  
  def print_line(board, max) do
    print_line(board, max, 0)
  end

  def print_line(board, max, idx) when max == idx do
    separator
  end

  def print_line(board, max, idx) when max > idx do
    current_row = Enum.at(board, idx)

    separator
    columns
    columns(current_row, idx + 1)
    columns
    print_line(board, max, idx + 1)
  end

end

defmodule GameLogic do

  def mapping do
    [[nil, nil, nil],
     [nil, nil, nil],
     [nil, nil, nil]]
  end

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

  def turns(board \\ nil, piece \\ 'x') do
    if board == nil do
      IO.puts "Setting up board... \n"
      board = mapping 
    end

    placement = place_piece

    col_let = String.at(placement, 0) |> String.upcase |> String.replace_trailing("\n", "")
    col_num = Enum.zip(["A", "B", "C"], [0, 1, 2]) |> Map.new |> Map.get(col_let)
    row_num = String.at(placement, 1) |> String.to_integer
    row_num = row_num - 1
    
    unless Enum.member?(["A", "B", "C"], col_let) do
      IO.puts "Please select columns A, B, or C (like 'A2', 'B3', etc)"
      turns(board)
    end

    unless Enum.member?([0, 1, 2], row_num) do
      IO.puts "Please select row 1, 2 or 3 (like 'A1', 'B3', etc)"
      turns(board)
    end

    current_char = Enum.at(board, row_num) |> Enum.at(col_num)
   
    unless current_char == nil do
      IO.puts "Space is already occupied"
      turns(board)
    end

    board = List.update_at(board, row_num, fn(x) -> List.update_at(x, col_num, fn(y) -> piece end ) end )
    if winner?(board, piece), do: IO.puts "\n#{piece} WINS!!\n"

    # Print Board
    Board.header
    Board.print_line(board, 3)
    
    if piece == 'x', do: piece = 'o', else: piece = 'x'
    turns(board, piece)
  end
  
end