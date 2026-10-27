require_relative '../connect_four'
describe Board do
  describe '#print_gameboard' do
    subject(:gameboard) { described_class.new }

    before do
      allow(gameboard).to receive(:puts).exactly(12).times
    end

    it 'prints the gameboard via puts' do
      expect(gameboard).to receive(:puts).exactly(12).times
      gameboard.print_gameboard
    end
  end

  describe '#choose_column' do
    subject(:gameboard) { described_class.new }

    it 'returns the correct column based on player input' do
      result = gameboard.choose_column('1')
      expect(result).to eq({ '11' => ' ', '12' => ' ', '13' => ' ', '14' => ' ', '15' => ' ' })
    end
  end

  describe '#update_boxes' do
    subject(:gameboard) { described_class.new }

    it 'changes the value of the correct box based on player input' do
      gameboard.update_boxes(gameboard.choose_column('1'), '1', 'X')
      expect(gameboard.boxes['15']).to eql('X')
    end
  end

  describe '#insert_coin' do
    subject(:gameboard) { described_class.new }

    it 'changes the value of the correct box to match the player input' do
      gameboard.insert_coin('1', 'X')
      gameboard.insert_coin('1', 'X')
      expect(gameboard.boxes['14']).to eq('X')
    end
  end

  describe '#winner?' do
    subject(:gameboard) { described_class.new }

    context 'when a player reaches 4 coins vertically' do
      before do
        4.times do
          gameboard.insert_coin('1', 'X')
        end
      end

      it 'returns true' do
        expect(gameboard.winner?(1, 2, 'X')).to eq(true)
      end
    end

    context 'when a player reaches 4 coins horizontally' do
      before do
        gameboard.insert_coin('1', 'X')
        gameboard.insert_coin('2', 'X')
        gameboard.insert_coin('3', 'X')
        gameboard.insert_coin('4', 'X')
      end

      it 'returns true' do
        expect(gameboard.winner?(4, 5, 'X')).to be(true)
      end
    end

    context 'when a player reaches 4 coins diagonally northeast to southwest' do
      before do
        gameboard.boxes['15'] = 'X'
        gameboard.boxes['24'] = 'X'
        gameboard.boxes['33'] = 'X'
        gameboard.boxes['42'] = 'X'
      end

      it 'returns true' do
        expect(gameboard.winner?(4, 2, 'X')).to be(true)
      end
    end

    context 'when a player reaches 4 coins diagonally northwest to southeast' do
      before do
        gameboard.boxes['12'] = 'X'
        gameboard.boxes['23'] = 'X'
        gameboard.boxes['34'] = 'X'
        gameboard.boxes['45'] = 'X'
      end

      it 'returns true' do
        expect(gameboard.winner?(4, 5, 'X')).to be(true)
      end
    end
  end
end

describe Player do
  subject(:player1) { described_class.new('Daniel', 'X') }
end

describe Game do
  subject(:game) { described_class.new('Daniel', 'Sarah') }

  describe '#valid_input?' do
    context 'if the input is valid' do
      it 'returns true' do
        expect(game.valid_input?('1')).to be(true)
      end
    end
  end

  describe '#player_choice' do
    context 'if the input column is not full' do
      before do
        allow(game).to receive(:gets).and_return('1')
      end

      it 'returns a valid input' do
        result = game.player_choice
        expect(result).to eq('1')
      end
    end

    context 'if the input column is full' do
      before do
        allow(game).to receive(:gets).and_return('1', '2')
        allow(game).to receive(:puts)
      end

      it 'receives an error message' do
        game.gameboard.boxes['11'] = 'X'
        game.player_choice
        expect(game).to have_received(:puts).with('Invalid input. Choose a column from 1-7 that has less than 5 tokens.').once
      end
    end

    context 'if the input is not 1-7' do
      before do
        allow(game).to receive(:gets).and_return('!', '1')
        allow(game).to receive(:puts)
      end

      it 'receives an error message' do
        game.player_choice
        expect(game).to have_received(:puts).with('Invalid input. Choose a column from 1-7 that has less than 5 tokens.').once
      end
    end
  end

  describe '#game_loop' do
    subject(:game) { described_class.new('Daniel', 'Sarah') }

    let(:board)  { instance_double(Board, print_gameboard: nil, insert_coin: nil, last_marker: [5, 3]) }
    let(:player) { instance_double(Player, marker: 'X', name: 'Anna') }

    before do
      game.instance_variable_set(:@gameboard, board)
      game.instance_variable_set(:@active_player, player)
      allow(game).to receive(:player_choice).and_return(3)
      allow(game).to receive(:puts)
    end

    context 'when the first move wins' do
      before { allow(board).to receive(:winner?).and_return(true) }

      it 'ends after one iteration' do
        game.game_loop
        expect(board).to have_received(:insert_coin).once
      end

      it 'announces the winner' do
        game.game_loop
        expect(game).to have_received(:puts).with('Game over, Anna won.')
      end
    end

    context 'when the third move wins' do
      before { allow(board).to receive(:winner?).and_return(false, false, true) }

      it 'keeps playing until there is a winner' do
        game.game_loop
        expect(board).to have_received(:insert_coin).exactly(3).times
      end

      it 'prints the board each turn' do
        game.game_loop
        expect(board).to have_received(:print_gameboard).exactly(3).times
      end
    end
  end
end
