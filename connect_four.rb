class Game
  attr_accessor :gameboard, :player_one, :player_two

  def initialize(p1name, p2name)
    @gameboard = Board.new
    @player_one = Player.new(p1name, 'R')
    @player_two = Player.new(p2name, 'G')
    @active_player = @player_one
  end

  def game_loop
    loop do
      @gameboard.print_gameboard
      @gameboard.insert_coin(player_choice, @active_player.marker)
      if @gameboard.winner?(@gameboard.last_marker[0], @gameboard.last_marker[1], @active_player.marker)
        puts "Game over, #{@active_player.name} won."
        break
      else
        switch_player

      end
    end
  end

  def switch_player
    @active_player = if @active_player != @player_two
                       @player_two
                     else
                       @player_one
                     end
  end

  def player_choice
    loop do
      input = gets.chomp
      return input if valid_input?(input)

      puts 'Invalid input. Choose a column from 1-7 that has less than 5 tokens.'
    end
  end

  def valid_input?(input)
    @gameboard.boxes["#{input}1"] == ' ' && input.match?(/\A[1-7]\z/)
  end
end

class Board
  attr_accessor :boxes, :last_marker

  def initialize
    @last_marker = []
    @boxes = {}
    (1..7).each do |column|
      (1..5).each do |row|
        @boxes["#{column}#{row}"] = ' '
      end
    end
  end

  def winner?(col, row, marker)
    directions = [[1, 0], [0, 1], [1, 1], [1, -1]]

    directions.any? do |dr, dc|
      1 + explore_direction(col, row, dr, dc, marker) +
        explore_direction(col, row, -dc, -dr, marker) >= 4
    end
  end

  def explore_direction(c, r, dr, dc, marker)
    count = 0
    col = c + dc
    row = r + dr

    while col.between?(0, 7) && row.between?(0, 5) && @boxes["#{col}#{row}"] == marker
      col += dc
      row += dr
      count += 1
    end
    count
  end

  def print_gameboard
    puts '   A B C D E F G '
    puts '================'
    puts " | #{@boxes['11']} | #{@boxes['21']} | #{@boxes['31']} | #{@boxes['41']} | #{@boxes['51']} | #{@boxes['61']} | #{@boxes['71']} |"
    puts '================'
    puts " | #{@boxes['12']} | #{@boxes['22']} | #{@boxes['32']} | #{@boxes['42']} | #{@boxes['52']} | #{@boxes['62']} | #{@boxes['72']} |"
    puts '================'
    puts " | #{@boxes['13']} | #{@boxes['23']} | #{@boxes['33']} | #{@boxes['43']} | #{@boxes['53']} | #{@boxes['63']} | #{@boxes['73']} |"
    puts '================'
    puts " | #{@boxes['14']} | #{@boxes['24']} | #{@boxes['34']} | #{@boxes['44']} | #{@boxes['54']} | #{@boxes['64']} | #{@boxes['74']} |"
    puts '================'
    puts " | #{@boxes['15']} | #{@boxes['25']} | #{@boxes['35']} | #{@boxes['45']} | #{@boxes['55']} | #{@boxes['65']} | #{@boxes['75']} |"
    puts '================'
  end

  def insert_coin(player_move, marker)
    update_boxes(choose_column(player_move), player_move, marker)
  end

  def choose_column(player_move)
    @boxes.select { |key, value| key.start_with?(player_move) }
  end

  def update_boxes(chosen_column, player_move, marker)
    5.downto(1) do |index|
      position = chosen_column
      next unless position["#{player_move}#{index}"] == ' '

      @boxes["#{player_move}#{index}"] = marker
      @last_marker[0] = player_move.to_i
      @last_marker[1] = index
      break
    end
  end
end

class Player
  attr_accessor :marker, :name

  def initialize(name, marker)
    @name = name
    @marker = marker
  end
end
