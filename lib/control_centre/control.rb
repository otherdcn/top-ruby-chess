require_relative "setup"
require_relative "serialise"
require_relative "../chess"
require_relative "../record_moves"
require "colorize"

module Chess
  class ChessGameError < StandardError; end

  class Control
    GameStateData = Struct.new("GameStateData", :all_moves, :round, :round_move, :game_over, :save_and_quit,
                               :player_white, :player_black, :current_player_turn, :chess_game, keyword_init: true)

    def initialize
      @game_state_data = GameStateData.new(all_moves: [],
                                           round: 1,
                                           round_move: "",
                                           game_over: false,
                                           save_and_quit: false,
                                           player_white: nil,
                                           player_black: nil,
                                           current_player_turn: nil,
                                           chess_game: nil)
    end

    def start
      puts "Would you like to play:"
      puts "1. Start new game"
      puts "2. Load old game"
      print "Select number [1 or 2]: "

      game_option = gets.chomp.to_i

      if game_option == 1
        setup_new_game
        play
      elsif game_option == 2
        setup_old_game
        play
      else
        puts "Unknown option #{game_option}!"
      end
    end

    private

    def save
      puts "** SAVING GAME **".colorize(color: :yellow)

      Serialise.dump(@game_state_data)

      puts "Save complete".colorize(color: :green)
    end

    def setup_new_game
      puts "\nSetting New Game...".colorize(color: :yellow)
      puts

      @game_state_data.player_white, @game_state_data.player_black = Chess::Setup.create_palyers
      chess_board                 = Chess::Setup.create_chess_board
      chess_pieces_white          = Chess::Setup.create_chess_pieces(colour: "White")
      chess_pieces_black          = Chess::Setup.create_chess_pieces(colour: "Black")

      Chess::Setup.arrange_chess_board(chess_board: chess_board,
                                       white: chess_pieces_white,
                                       black: chess_pieces_black)

      @game_state_data.chess_game = Chess::Game.new(chess_board: chess_board,
                                                    chess_moves: Chess::RecordMoves.new)
    end

    def setup_old_game
      puts "\n*** LOADING GAME ***".colorize(color: :yellow)

      @game_state_data = Serialise.load

      @game_state_data.save_and_quit = false
      @reloaded_mid_round = true if @game_state_data.current_player_turn == @game_state_data.player_black

      puts "\nLoad complete\n".colorize(color: :green)
      puts "CONTINUING FROM WHERE WE LEFT OFF...".colorize(color: :yellow)
    end

    def reloaded_mid_round?
      @reloaded_mid_round
    end

    def command_input
      puts "> Enter 'start' and 'end' square seperated by comma to move piece, e.g. a2,a4"
      puts "> Enter 's' to save and continue game, e.g. s"
      puts "> Enter 'sq' to save and quit game, e.g. sq"
      print "===> Your command: "
      gets.chomp.split(",")
    end

    def play
      until @game_state_data.game_over || @game_state_data.save_and_quit

        if reloaded_mid_round?
          make_move(@game_state_data.player_black) if reloaded_mid_round?
          @reloaded_mid_round = false
        else
          @game_state_data.round_move = "#{@game_state_data.round}. "

          [@game_state_data.player_white, @game_state_data.player_black].each do |current_player_turn|
            make_move(current_player_turn)
            break if @game_state_data.save_and_quit
          end
        end

        @game_state_data.round += 1
        @game_state_data.all_moves << @game_state_data.round_move

        puts "-----"
        print "Moves made: "
        puts @game_state_data.all_moves.join(" ").colorize(color: :yellow)
        puts "-----"
      end
    end

    def make_move(current_player_turn)
      @game_state_data.chess_game.player = current_player_turn
      @game_state_data.current_player_turn = current_player_turn

      if @game_state_data.chess_game.end_game?
        @game_state_data.chess_game.announce_winner
        @game_state_data.game_over = true
        return
      end

      @game_state_data.chess_game.display
      puts
      repeat_turn = true

      while repeat_turn
        begin
          from, to = command_input

          if from == "s"
            save
            raise ChessGameError, "CONTINUING GAME..."
          elsif from == "sq"
            save
            @game_state_data.save_and_quit = true
            puts "\nQuitting Game...\n"
            break
          end

          raise ChessGameError, "Missing source square" if from.nil? || from.empty?
          raise ChessGameError, "Missing target square" if to.nil? || to.empty?

          player_move = @game_state_data.chess_game.play(from: from, to: to)
          @game_state_data.round_move += player_move

          puts "NOTE: #{player_move}".colorize(color: :green)
          repeat_turn = false
        rescue ChessGameError => e
          # puts "Type: #{e.class}"
          # puts "Message: #{e.message}"
          # puts "First line of trace: #{e.backtrace.first}"
          puts "\nNOTE: #{e}".colorize(color: :red)
          puts
          puts "#{current_player_turn.name} (#{current_player_turn.colour}), TRY AGAIN!"
            .colorize(color: :black, background: :white)

          repeat_turn = true
        rescue StandardError => e
          # puts "Type: #{e.class}"
          # puts "Message: #{e.message}"
          # puts "First line of trace: #{e.backtrace.first}"
          puts "\nNOTE: #{e}".colorize(color: :red)
          puts "\nNOTE: #{e.full_message}".colorize(color: :red)
          puts
          puts "#{current_player_turn.name} (#{current_player_turn.colour}), TRY AGAIN!"
            .colorize(color: :black, background: :white)

          repeat_turn = true
        end

        puts
      end

      return if @game_state_data.save_and_quit

      @game_state_data.round_move += " "
    end
  end
end
