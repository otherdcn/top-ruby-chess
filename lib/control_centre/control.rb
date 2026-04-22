require_relative "./setup"
require_relative "../chess"
require_relative "../record_moves"
require 'colorize'

module Chess
  class ChessGameError < StandardError; end

  class Control
    def start
      puts "Would you like to play:"
      puts "1. Start new game"
      puts "2. Load old game"
      print "Select number [1 or 2]: "

      game_option = gets.chomp.to_i

      if game_option == 1
        play(setup_new_game)
      elsif game_option == 2
        puts "** NOT YET AVAILABLE **"
        #play(setup_old_game)
      else
        puts "Unknown option #{game_option}!"
      end
    end

    private

    def save
      puts "** SAVING GAME **"
    end

    def setup_new_game
      puts "\nSetting New Game..."
      puts

      @player_white, @player_black  = Chess::Setup.create_palyers
      chess_board                 = Chess::Setup.create_chess_board
      chess_pieces_white          = Chess::Setup.create_chess_pieces(colour: 'White')
      chess_pieces_black          = Chess::Setup.create_chess_pieces(colour: 'Black')

      Chess::Setup.arrange_chess_board(chess_board: chess_board,
                                       white: chess_pieces_white,
                                       black: chess_pieces_black)

      Chess::Game.new(chess_board: chess_board,
                      chess_moves: Chess::RecordMoves.new)
    end

    def setup_old_game; end

    def command_input
      puts "> Enter 'start' and 'end' square seperated by comma to move piece, e.g. a2,a4"
      #puts "> Enter 's' to save and continue game, e.g. s"
      puts "> Enter 'sq' to save and quit game, e.g. sq"
      print "===> Your command: "
      gets.chomp.split(",")
    end

    def play(chess_game)
      all_moves = []
      round = 1
      game_over = false
      save_and_quit = false

      until game_over || save_and_quit
        round_move = "#{round}. "

        [@player_white, @player_black].each do |player|
          chess_game.player = player

          if chess_game.end_game?
            chess_game.announce_winner
            game_over = true
            break
          end

          chess_game.display
          puts
          repeat_turn = true

          while repeat_turn
            begin
              from, to = command_input

              if from == "s"
                save
                raise ChessGameError, "Save complete. Continuing Game..."
              elsif from == "sq"
                save
                save_and_quit = true
                puts "\nQuitting Game...\n"
                break
              end

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

          break if save_and_quit
          round_move += " "
        end

        round += 1
        all_moves << round_move

        puts "-----"
        print "Moves made: "
        puts all_moves.join(" ").colorize(color: :yellow)
        puts "-----"
      end
    end
  end
end

