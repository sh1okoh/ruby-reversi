require 'test/unit'
require 'rule'

class TestRule
  
  class TestCellLine  < Test::Unit::TestCase
    include Rule
    
    def setup
      @black = Cell.BLACK
      @white = Cell.WHITE
      @blank = Cell.BLANK
      @cell_line = nil
    end
    
    def test_黒が置ける
      @cell_line = CellLine.new([@white, @black], [@white, @black])
      assert_equal(true, @cell_line.collect?(@black.disk))
    end
    
    def test_黒で取る
      @cell_line = CellLine.new([@white, @black], [@white, @black])
      assert_equal([@white, @white], @cell_line.collect_all(@black.disk))
    end
    
    def test_白は置けない
      @cell_line = CellLine.new([@white, @black], [@white, @black])
      assert_equal(false, @cell_line.collect?(@white.disk))
    end
    
    def test_白は取れない
      @cell_line = CellLine.new([@white, @black], [@white, @black])
      assert_equal([], @cell_line.collect_all(@white.disk))
    end
    
    def test_途中にブランクがあると取れない1
      @cell_line = CellLine.new([@white, @blank, @black], [])
      assert_equal(false, @cell_line.collect?(@black.disk))
    end
    
    def test_途中にブランクがあると取れない2
      @cell_line = CellLine.new([@blank, @blank, @black], [])
      assert_equal(false, @cell_line.collect?(@black.disk))
    end
    
    def test_挟まっていないと取れない1
      @cell_line = CellLine.new([@white, @blank, @blank, @blank], [])
      assert_equal(false, @cell_line.collect?(@black.disk))
    end
    
    def test_挟まっていないと取れない2
      @cell_line = CellLine.new([@white, @blank, @black, @blank], [])
      assert_equal(false, @cell_line.collect?(@black.disk))
    end
  end  
  
  class TestCells < Test::Unit::TestCase
    include Rule
    
    def setup
      @cells = Cells.create
    end
    
    def _i(x, y)
      y * 8 + x
    end
    
    #
    # テストのため、@cellsを0から連続した数字で埋めます。
    #
    def fill_for_test!
      i = -1
      @cells.cells.items.collect!{|item| i+=1}
    end
    
    def test_fetch_illgal_parameters
      fill_for_test!
      
      assert_raise(RuntimeError) {
        @cells.fetch(0,0,0,0) 
      }
      assert_raise(RuntimeError) {
        @cells.fetch(-1,0,0,0) 
      }
      assert_raise(RuntimeError) {
        @cells.fetch(0,-1,0,0) 
      }
      assert_raise(RuntimeError) {
        @cells.fetch(0,0,100,0) 
      }
      assert_raise(RuntimeError) {
        @cells.fetch(0,0,0,100) 
      }
    end
    
    def test_fetch_x
      fill_for_test!
      
      assert_equal(CellLine.new([], [_i(1,0), _i(2,0), _i(3,0), _i(4,0), _i(5,0), _i(6,0), _i(7,0)]), @cells.fetch_x(0,0))
      assert_equal(CellLine.new([], [_i(1,1), _i(2,1), _i(3,1), _i(4,1), _i(5,1), _i(6,1), _i(7,1)]), @cells.fetch_x(0,1))
      assert_equal(CellLine.new([_i(3,0), _i(2,0), _i(1,0), _i(0,0)], [_i(5,0), _i(6,0), _i(7,0)]),   @cells.fetch_x(4,0))
      assert_equal(CellLine.new([_i(5,0), _i(4,0), _i(3,0), _i(2,0), _i(1,0), _i(0,0)], [_i(7,0)]),   @cells.fetch_x(6,0))
    end
    
    def test_fetch_y
      fill_for_test!
      
      assert_equal(CellLine.new([], [_i(0,1), _i(0,2), _i(0,3), _i(0,4), _i(0,5), _i(0,6), _i(0,7)]), @cells.fetch_y(0,0))
      assert_equal(CellLine.new([], [_i(1,1), _i(1,2), _i(1,3), _i(1,4), _i(1,5), _i(1,6), _i(1,7)]), @cells.fetch_y(1,0))
    end
    
    def test_fetch_right_slope
      fill_for_test!
      
      assert_equal(CellLine.new([], [_i(1,1), _i(2,2), _i(3,3), _i(4,4), _i(5,5), _i(6,6), _i(7,7)]), @cells.fetch_right_slope(0,0))
      assert_equal(CellLine.new([], [_i(2,1), _i(3,2), _i(4,3), _i(5,4), _i(6,5), _i(7,6)]),          @cells.fetch_right_slope(1,0))
    end
    
    def test_fetch_left_slope
      fill_for_test!
      
      assert_equal(CellLine.new([], [_i(6,1), _i(5,2), _i(4,3), _i(3,4), _i(2,5), _i(1,6), _i(0,7)]), @cells.fetch_left_slope(7,0))
      assert_equal(CellLine.new([], [_i(6,2), _i(5,3), _i(4,4), _i(3,5), _i(2,6), _i(1,7)]),          @cells.fetch_left_slope(7,1))
      assert_equal(CellLine.new([_i(5,2), _i(6,1), _i(7,0)], [_i(3,4), _i(2,5), _i(1,6), _i(0,7)]),   @cells.fetch_left_slope(4,3))
      assert_equal(CellLine.new([_i(6,4), _i(7,3)],          [_i(4,6), _i(3,7)]),                     @cells.fetch_left_slope(5,5))
    end
    
    def test_fetch_x2
      line = @cells.fetch_x(2,4);
      assert_equal(true, line.collect?("●"))
    end
    
    def test_reversible?
      assert_equal(false, @cells.collect_at?("○", 0,0));
      assert_equal(false, @cells.collect_at?("●", 0,0));
      assert_equal(false, @cells.collect_at?("○", 2,4));
      assert_equal(true, @cells.collect_at?("●", 2,4));
    end
    
    def test_take_stone
      assert_equal(true, @cells.collect_at?("●", 2,4));
      @cells.collect_at("●", 2,4).each{|line| line.reversi!("●")};
      assert_equal(false, @cells.collect_at?("●", 2,4));
    end
  end
  
  class TestGameMaster < Test::Unit::TestCase
    include Rule
    
    def setup
      Cells.row = 8
      Cells.col = 8
      
      @master = GameMaster.create
    end
    
    def test_cannot_use_default_constructor
      
      assert_raise(NoMethodError) {
        GameMaster.new(nil, nil, nil)
      }
      
    end
    
    def test_put_置ける?
      @master.turn
      assert_equal(true, @master.reversi?(2,4))
    end
    
    def test_put_置けない?
      @master.turn
      assert_equal(false, @master.reversi?(1,1))
    end
    
    def test_put_置いたので置けない?
      @master.turn
      @master.reversi!(2,4)
      assert_equal(false, @master.reversi?(2,4))
    end
    
    def test_end_終わっていない
      assert_equal(false, @master.end?)
      
      @master.turn
      @master.reversi!(2,4)
      
      assert_equal(false, @master.end?)
    end
    
    def test_end_終わった
      Cells.row = 2
      Cells.col = 2
      @cells = Cells.create
      assert_equal(false, @cells.collect?(Cell.BLACK.disk))
      assert_equal(false, @cells.collect?(Cell.WHITE.disk))
    end
    
    def test_end_終わった2
      Cells.row = 2
      Cells.col = 2
      @master = GameMaster.create
      assert_equal(true, @master.end?)
    end
    
    def test_clone
      
      @cloned = GameMaster.clone(@master)
      @master.reversi!(2,3)
      
      assert_equal(Cell.BLACK.disk, @cloned.players[0], "clonedのプレイヤーは変わっていない")
      assert_equal(Cell.WHITE.disk, @cloned.players[1], "clonedのプレイヤーは変わっていない")
      
      assert_equal(Cell.BLANK, @cloned.cells.cells.at(2, 3),
        "masterでは既に2,3に置いているがこれはclonedだからBlankのままである")
      
      assert_nothing_thrown("masterでは既に2,3に置いているがこれはclonedだからmasterの変更は反映されない"){
        @cloned.reversi!(2,3)
      }
    end
    
  end
  
  class TestTurn < Test::Unit::TestCase
    include Rule
    
    def setup
      @black = Cell.BLACK.disk
      @white = Cell.WHITE.disk
      @master = GameMaster.create
    end
    
    def test_turn
      assert_equal(@black, @master.current_player)
      @master.turn
      assert_equal(@white, @master.current_player)
      @master.turn
      assert_equal(@black, @master.current_player)
    end
    
    def test_players
      @master.players <=> [@white, @black]
    end
  end
  
  class TestCellHelper < Test::Unit::TestCase
    include Rule::CellHelper
    
    def test_valid
      assert_equal(false, invalid_xy?(0, 0))
    end
    
    def test_invalid
      assert_equal(true, invalid_xy?(-1, -1))
    end
    
  end
  
end