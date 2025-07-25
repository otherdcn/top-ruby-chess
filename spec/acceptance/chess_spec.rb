require_relative "../../lib/chess"
require_relative "../../lib/setup"
require_relative "../../lib/record_moves"

module Chess
  RSpec.describe Chess do
    def setup_chess
      allow(Chess::Setup).to receive(:gets).and_return("1", "red", "der")
      allow(Chess::Setup).to receive(:puts)
      allow(Chess::Setup).to receive(:print)

      players  = Chess::Setup.create_palyers
      board = Chess::Setup.create_chess_board
      pieces_white = Chess::Setup.create_chess_pieces(colour: 'White')
      pieces_black = Chess::Setup.create_chess_pieces(colour: 'Black')

      Chess::Setup.arrange_chess_board(chess_board: board,
                                       white: pieces_white,
                                       black: pieces_black)

      game = Chess::Game.new(chess_board: board,
                                   chess_moves: Chess::RecordMoves.new)

      {
        chess_gameers: {
          white: players.first, black: players.last
        },
        chess_board: board,
        chess_pieces: { 
          white: pieces_white, black: pieces_black 
        },
        chess_game: game
      }
    end

    #let(:setup)         { setup_chess }
    let(:chess_game)    { setup_chess[:chess_game] }
    let(:player_white)  { setup_chess[:chess_gameers][:white] }
    let(:player_black)  { setup_chess[:chess_gameers][:black] }

    it "has a white player named `red` and black player named `der`" do
      expect(player_white.name).to eq 'red'
      expect(player_black.name).to eq 'der'
    end

    describe "basic movements" do
      context "when player makes invalid move" do
        before do
          chess_game.player = player_white
        end

        it "raises error if player attempts unreachable move" do
          expect{ chess_game.play(from: "a2", to: "a5") }
            .to raise_error(ChessGameError, /cannot move from/)
        end

        it "raises error if player attempts friendly piece capture move" do
          expect{ chess_game.play(from: "b1", to: "d2") }
            .to raise_error(ChessGameError, /cannot capture/)
        end

        it "raises error if player attempts opponent piece move" do
          expect{ chess_game.play(from: "a7", to: "a6") }
            .to raise_error(ChessGameError, /does not belong to/)
        end

        it "raises error if player attempts beyond board limit move" do
          expect{ chess_game.play(from: "a2", to: "a9") }
            .to raise_error(StandardError, /No such square/)
        end
      end

      context "when player makes valid move" do
        before do
          chess_game.player = player_white
        end

        it "records the movement of the pawn" do
          expect(chess_game.play(from: "a2", to: "a3")).to eq "a3"
          expect(chess_game.play(from: "b2", to: "b4")).to eq "b4"
        end

        it "records the movement of the rook" do
          # Move pieces out of way to test movement
          chess_game.play(from: "b2", to: "b4")
          chess_game.play(from: "b1", to: "c3")
          chess_game.play(from: "c1", to: "a3")

          # Test multiple movements
          expect(chess_game.play(from: "a1", to: "c1")).to eq "RWc1"
          expect(chess_game.play(from: "c1", to: "b1")).to eq "RWb1"
          expect(chess_game.play(from: "b1", to: "b3")).to eq "RWb3"
          expect(chess_game.play(from: "b3", to: "b1")).to eq "RWb1"
        end

        it "records the movement of the knight" do
          expect(chess_game.play(from: "b1", to: "c3")).to eq "NWc3"
          expect(chess_game.play(from: "c3", to: "d5")).to eq "NWd5"
          expect(chess_game.play(from: "d5", to: "f4")).to eq "NWf4"
        end

        it "records the movement of the bishop" do
          # Move pieces out of way to test movement
          chess_game.play(from: "b2", to: "b4")

          expect(chess_game.play(from: "c1", to: "b2")).to eq "BWb2"
          expect(chess_game.play(from: "b2", to: "d4")).to eq "BWd4"
          expect(chess_game.play(from: "d4", to: "b6")).to eq "BWb6"
        end

        it "records the movement of the queen" do
          # Move pieces out of way to test movement
          chess_game.play(from: "c2", to: "c4")

          expect(chess_game.play(from: "d1", to: "b3")).to eq "QWb3"
          expect(chess_game.play(from: "b3", to: "b6")).to eq "QWb6"
          expect(chess_game.play(from: "b6", to: "d6")).to eq "QWd6"
          expect(chess_game.play(from: "d6", to: "d5")).to eq "QWd5"
          expect(chess_game.play(from: "d5", to: "e4")).to eq "QWe4"
          expect(chess_game.play(from: "e4", to: "d3")).to eq "QWd3"
          expect(chess_game.play(from: "d3", to: "f5")).to eq "QWf5"
        end

        it "records the movement of the king" do
          # Move pieces out of way to test movement
          chess_game.play(from: "c2", to: "c4")
          chess_game.play(from: "d2", to: "d4")
          chess_game.play(from: "e2", to: "e4")
          chess_game.play(from: "f2", to: "f4")
          chess_game.play(from: "g2", to: "g4")
          chess_game.play(from: "d1", to: "b3")
          chess_game.play(from: "f1", to: "h3")

          expect(chess_game.play(from: "e1", to: "d1")).to eq "KWd1"
          expect(chess_game.play(from: "d1", to: "d2")).to eq "KWd2"
          expect(chess_game.play(from: "d2", to: "e3")).to eq "KWe3"
          expect(chess_game.play(from: "e3", to: "f2")).to eq "KWf2"
          expect(chess_game.play(from: "f2", to: "e1")).to eq "KWe1"
        end
      end
    end

    describe "special movements" do
      context "en passant" do
        context "on the turn immediately after the two-square advance" do
          it "captures via e.p." do
            chess_game.player = player_white
            chess_game.play(from: "a2", to: "a4")
            chess_game.player = player_black
            chess_game.play(from: "a7", to: "a6")
            chess_game.player = player_white
            chess_game.play(from: "a4", to: "a5")
            chess_game.player = player_black
            chess_game.play(from: "b7", to: "b5")
            chess_game.player = player_white
            notation_message = chess_game.play(from: "a5", to: "b6")

            expect(notation_message).to eq "axb6 e.p."
            expect(chess_game.captured_pieces.last.name).to eq "PB"
            expect(chess_game.check_board_square(square: "b6")).to eq "PW"
          end
        end

        context "not on the turn immediately after the two-square advance" do
          it "raises error stating that the pawn `cannot move...`" do
            chess_game.player = player_white
            chess_game.play(from: "a2", to: "a4")
            chess_game.player = player_black
            chess_game.play(from: "a7", to: "a6")
            chess_game.player = player_white
            chess_game.play(from: "a4", to: "a5")
            chess_game.player = player_black
            chess_game.play(from: "b7", to: "b5")
            chess_game.player = player_white
            chess_game.play(from: "c2", to: "c3")
            chess_game.player = player_black
            chess_game.play(from: "e7", to: "e6")

            chess_game.player = player_white
            expect { chess_game.play(from: "a5", to: "b6") }
              .to raise_error(ChessGameError, /cannot move from/)
          end
        end
      end

      context "promotion" do
        let(:setup_promotion) { Chess::Setup }

        it "switches piece from pawn to new selected piece" do
          chess_game.player = player_white
          chess_game.play(from: "a2", to: "a4")
          chess_game.player = player_black
          chess_game.play(from: "b7", to: "b5")
          chess_game.player = player_white
          chess_game.play(from: "a4", to: "b5")
          chess_game.player = player_black
          chess_game.play(from: "b8", to: "c6")
          chess_game.player = player_white
          chess_game.play(from: "b5", to: "b6")
          chess_game.player = player_black
          chess_game.play(from: "c6", to: "e5")
          chess_game.player = player_white
          chess_game.play(from: "b6", to: "b7")
          chess_game.player = player_black
          chess_game.play(from: "e5", to: "g4")

          allow(setup_promotion).to receive(:gets).and_return('1')

          chess_game.player = player_white

          promotion_message   = chess_game.play(from: "b7", to: "b8")
          promoted_piece      = chess_game.check_board_square(square: "b8")

          expect(promotion_message).to eq("b8=QW")
          expect(promoted_piece).to include("QW")
        end
      end

      context "castling" do
        context "if certain conditions are not met" do
          it "raises error if either king or rook has already moved" do
            chess_game.player = player_white
            chess_game.play(from: "g2", to: "g4")
            chess_game.play(from: "f1", to: "h3")
            chess_game.play(from: "g1", to: "f3")
            chess_game.play(from: "e1", to: "f1")
            chess_game.play(from: "f1", to: "e1")

            expect { chess_game.play(from: "e1", to: "g1") }
              .to raise_error(ChessGameError, "King or Rook has already moved")
          end

          it "raises error if there are pieces between king and rook" do
            chess_game.player = player_white
            chess_game.play(from: "g1", to: "f3")

            expect { chess_game.play(from: "e1", to: "g1") }
              .to raise_error(ChessGameError, "There are pieces between King and Rook")
          end

          it "raises error if king is currently in check" do
            chess_game.player = player_white
            chess_game.play(from: "e2", to: "e4")
            chess_game.player = player_black
            chess_game.play(from: "e7", to: "e5")
            chess_game.player = player_white
            chess_game.play(from: "g1", to: "f3")
            chess_game.player = player_black
            chess_game.play(from: "d8", to: "h4")
            chess_game.player = player_white
            chess_game.play(from: "f1", to: "d3")
            chess_game.player = player_black
            chess_game.play(from: "h4", to: "f2")

            chess_game.player = player_white
            expect { chess_game.play(from: "e1", to: "g1") }
              .to raise_error(ChessGameError, /KING STILL IN CHECK/)
          end

          it "raises error if king finishes on a square that is attacked" do
            chess_game.player = player_white
            chess_game.play(from: "e2", to: "e4")
            chess_game.player = player_black
            chess_game.play(from: "e7", to: "e5")
            chess_game.player = player_white
            chess_game.play(from: "g1", to: "f3")
            chess_game.player = player_black
            chess_game.play(from: "d8", to: "g5")
            chess_game.player = player_white
            chess_game.play(from: "f1", to: "d3")
            chess_game.player = player_black
            chess_game.play(from: "g5", to: "g2")

            chess_game.player = player_white
            expect { chess_game.play(from: "e1", to: "g1") }
              .to raise_error(ChessGameError, /KING MOVING TO CHECK/)
          end

          it "raises error if king passes through on a square that is attacked" do
            chess_game.player = player_white
            chess_game.play(from: "e2", to: "e4")
            chess_game.player = player_black
            chess_game.play(from: "e7", to: "e5")
            chess_game.player = player_white
            chess_game.play(from: "f1", to: "d3")
            chess_game.player = player_black
            chess_game.play(from: "d8", to: "f6")
            chess_game.player = player_white
            chess_game.play(from: "f2", to: "f4")
            chess_game.player = player_black
            chess_game.play(from: "f6", to: "f4")
            chess_game.player = player_white
            chess_game.play(from: "g1", to: "h3")
            chess_game.player = player_black
            chess_game.play(from: "a7", to: "a5")

            chess_game.player = player_white
            expect { chess_game.play(from: "e1", to: "g1") }
              .to raise_error(ChessGameError, /KING MOVING THROUGH CHECK/)
          end
        end

        context "if kingside" do
          context "and for white player" do
            it "moves both pieces and records it `0-0`" do
              chess_game.player = player_white
              chess_game.play(from: "g2", to: "g4")
              chess_game.play(from: "f1", to: "h3")
              chess_game.play(from: "g1", to: "f3")

              notation_message = chess_game.play(from: "e1", to: "g1")
              at_square_g1 = chess_game.check_board_square(square: 'g1')
              at_square_f1 = chess_game.check_board_square(square: 'f1')

              expect(notation_message).to eq "0-0"
              expect(at_square_g1).to eq "KW"
              expect(at_square_f1).to eq "RW"
            end
          end

          context "and for black player" do
            it "moves both pieces and records it `0-0`" do
              chess_game.player = player_black
              chess_game.play(from: "g7", to: "g5")
              chess_game.play(from: "f8", to: "h6")
              chess_game.play(from: "g8", to: "f6")

              notation_message = chess_game.play(from: "e8", to: "g8")
              at_square_g8 = chess_game.check_board_square(square: 'g8')
              at_square_f8 = chess_game.check_board_square(square: 'f8')

              expect(notation_message).to eq "0-0"
              expect(at_square_g8).to eq "KB"
              expect(at_square_f8).to eq "RB"
            end
          end
        end

        context "if queenside" do
          context "and for white player" do
            it "moves both pieces and records it as `0-0-0`" do
              chess_game.player = player_white
              chess_game.play(from: "c2", to: "c4")
              chess_game.play(from: "d2", to: "d4")
              chess_game.play(from: "b1", to: "c3")
              chess_game.play(from: "c1", to: "e3")
              chess_game.play(from: "d1", to: "a4")

              notation_message = chess_game.play(from: "e1", to: "c1")
              at_square_c1 = chess_game.check_board_square(square: 'c1')
              at_square_d1 = chess_game.check_board_square(square: 'd1')

              expect(notation_message).to eq "0-0-0"
              expect(at_square_c1).to eq "KW"
              expect(at_square_d1).to eq "RW"
            end
          end

          context "and for black player" do
            it "moves both pieces and records it as `0-0-0`" do
              chess_game.player = player_black
              chess_game.play(from: "c7", to: "c5")
              chess_game.play(from: "d7", to: "d5")
              chess_game.play(from: "b8", to: "c6")
              chess_game.play(from: "c8", to: "e6")
              chess_game.play(from: "d8", to: "a5")
              #chess_game.play(from: "e8", to: "d8")
              #chess_game.play(from: "d8", to: "e8")

              notation_message = chess_game.play(from: "e8", to: "c8")
              at_square_c8 = chess_game.check_board_square(square: 'c8')
              at_square_d8 = chess_game.check_board_square(square: 'd8')

              expect(notation_message).to eq "0-0-0"
              expect(at_square_c8).to eq "KB"
              expect(at_square_d8).to eq "RB"
            end
          end
        end
      end
    end
  end
end
