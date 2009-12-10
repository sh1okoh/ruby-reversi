require 'AI/log'

class GameStatus
  
  def initialize(master)
    @master = master
  end
  
  def get_cells
    @master.cells
  end
  
  def get_native_cells
    @master.cells.cells
  end
  
  def get_internal_cells
    @master.cells.cells.items
  end
  
  
  #
  # ボードにあるdiskの合計を返します。
  # 返される値は以下のようなハッシュになります。
  # {'+' => 2, '○' => 8 ..}
  #
  def score
    
    scores = {}
    get_internal_cells.each{|cell|
      value = scores.has_key?(cell.disk) ? scores[cell.disk] + 1 : 1;
      scores[cell.disk] = value
    }
    return scores
  end
  
  #
  # 現在のプレイヤーが置ける場所を返します。
  # 返される値は以下のようなハッシュの配列になります。
  # [{'x' => 1, 'y' => 0}, {'x' => 1, 'y' => 1}, ....]
  #
  def hint
    
    hints = []
    get_native_cells.each{|x, y| 
      if (get_cells.collect_at?(@master.current_player, x, y)) 
        hints.push({'x' => x, 'y' => y})
      end
    }
    return hints
    
  end
  
  #
  # 置ける場所をrandomに返します。
  # 返される値は以下のようなハッシュです。
  # {'x' => 1, 'y' => 0}
  #
  def random
    hints = hint
    hints[rand(hints.length)]
  end
  
  def verbose
    Log.enable? ? Log.enable(false) : Log.enable(true)
  end
  
  def get_empty_cell_count
    get_internal_cells.grep(Cell.BLANK).length
  end
  
  def get_not_empty_cell_count
    Cells.row * Cells.col - get_empty_cell_count
  end
  
  def cloned_status
    status = GameStatus.new(GameMaster.clone_noevent(@master))
    status.cloned
    status
  end
  
  def master
    raise "cloneされたインスタンスのみ呼び出せます。" unless (@cloned)
    @master
  end
  
  def cloned
    @cloned = true
  end
  private_methods :cloned
  
end