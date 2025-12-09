require_relative "./lib/setup"
require_relative "./lib/chess"
require_relative "./lib/record_moves"
require 'colorize'

puts
puts "-----------------------------"
puts "***** Let's play Chess! *****"
puts "-----------------------------"
puts

player_white, player_black  = Chess::Setup.create_palyers
chess_board                 = Chess::Setup.create_chess_board
chess_pieces_white          = Chess::Setup.create_chess_pieces(colour: 'White')
chess_pieces_black          = Chess::Setup.create_chess_pieces(colour: 'Black')

Chess::Setup.arrange_chess_board(chess_board: chess_board,
                                 white: chess_pieces_white,
                                 black: chess_pieces_black)

chess_game = Chess::Game.new(chess_board: chess_board,
                             chess_moves: Chess::RecordMoves.new)

class ChessGameError < StandardError; end

all_moves = []
round = 1

loop do
  round_move = "#{round}. "

  [player_white, player_black].each do |player|
    chess_game.player = player

    break if chess_game.end_game?

    chess_game.display
    puts
    repeat_turn = true

    while repeat_turn
      begin
        puts "(Select start and end square seperated by comma, e.g. a2,a4) "
        print "Move piece: "
        from, to = gets.chomp.split(",")

        raise ChessGameError, "Missing source square" if from.nil? || from.empty?
        raise ChessGameError, "Missing target square" if to.nil? || to.empty?

        #puts chess_game.check_piece_next_moves(square: from)

        player_move = chess_game.play(from: from, to: to)
        round_move += player_move

        puts "NOTE: #{player_move}".colorize(color: :green)
        repeat_turn = false
      rescue ChessGameError => e
        puts "\nNOTE: #{e}".colorize(color: :red)
        puts
        puts "#{player.name} (#{player.colour}), TRY AGAIN!"
          .colorize(color: :black, background: :white)

        repeat_turn = true
      rescue StandardError => e
        puts "\nNOTE: #{e}".colorize(color: :red)
        #puts "\nNOTE: #{e.full_message}".colorize(color: :red)
        puts
        puts "#{player.name} (#{player.colour}), TRY AGAIN!"
          .colorize(color: :black, background: :white)

        repeat_turn = true
      end

      puts
    end

    round_move += " "
  end

  break if chess_game.end_game?

  round += 1
  all_moves << round_move

  puts "-----"
  print "Moves made: "
  puts all_moves.join(" ").colorize(color: :yellow)
  puts "-----"
end

chess_game.announce_winner
