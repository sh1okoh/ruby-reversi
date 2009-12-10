require 'AI/log'
require 'AI/exp'

class Brisket
  
  def initialize(game_status)
    @game_status = game_status
  end
  
  def receive
    
    return :skip if @game_status.hint.empty?;
    
    disks = @game_status.get_not_empty_cell_count
    @depth = disks < 10 ? 1 : disks < 20 ? 1 : disks < 30 ? 1 : disks < 40 ? 2 : disks < 50 ? 2 : 2
    
    best = think(@game_status)
    Log.p("もっともらしいのは#{best.item} score:#{best.score}\n")
    
    return :reversi!, best.item['x'], best.item['y']
  end
  
  def think(orginal_status)
    
    pos = nil
    min = 2 ** 31
    
    #
    # 相手が最も小さい値になる場所に自分は置く。
    #
    scores = Calculator.new(orginal_status).scores
    scores.each{|v|
      
      return v if (v.score >= 5)
      
      status = orginal_status.cloned_status
      
      hits_me(v, status)
      best_hits(status)
      
      @depth.times{
        best_hits(status)
        best_hits(status)
      }
      
      status.master.turn
      best_score = Calculator.new(status).score
      if (best_score == nil)
        next
      end
      if (min > best_score.score)
        min = best_score.score
        pos = v
      end
    }
    if (pos == nil)
      return scores[0]
    end
    return pos
  end
  
  def hits_me(v, status)
    return unless (v)
    status.master.reversi!(v.item['x'], v.item['y'])
  end
  
  def best_hits(status)
    hits_me(Calculator.new(status).score, status)
  end
  
  class Calculator
    
    include Exp
    
    def initialize(status)
      @game_status = status
    end
    
    def score
      values = scores.sort{|a, b| a.score <=> b.score }
      Log.scores(values)
      return values[-1]
    end
    
    def scores
      
      cells = @game_status.get_native_cells
      @game_status.hint.map{|item|
        s1 = Math::log(Expanse.new(cells).count(item)   + 1) / Math::log(4)
        s2 = Math::log(Perimeter.new(cells).count(item) + 1) / Math::log(4)
        s3 = Corner.new(cells).count(item)
        s4 = Power.new(cells).count()
        
        Score.new(s1 + s2 + s3 + s4, item)
      }
    end
  end
  
  class Score
    attr_reader :score, :item
    
    def initialize(score, item)
      @score = score
      @item  = item
    end
  end
  
end