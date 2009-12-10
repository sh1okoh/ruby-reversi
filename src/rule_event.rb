class RuleEvent
  
  @@listeners = []
  
  def RuleEvent.add_listener(listener)
    raise if listener == nil
    @@listeners << listener
  end
  
  def initialize
    
    @skip = proc{|o, disk| 
      o.player_skiped(disk) if defined? o.player_skiped
    }
    @turn = proc{|o| 
      o.turn if defined? o.turn
    }
    @reversi = proc{|o, cells, disk, x, y| 
      o.reversi(cells, disk, x, y) if defined? o.reversi
    }
  end
  
  def skip(disk)
    notify(@skip, disk)
  end
  
  def turn
    notify(@turn)
  end
  
  def reversi(cells, disk, x, y)
    notify(@reversi, cells, disk, x, y)
  end
  
  private
  
  def notify(procedure, *any)
    @@listeners.each{|o| procedure.call(o, *any)}
  end
end

class NullRuleEvent
  
  def skip(disk)
    false
  end
  
  def turn
    false
  end
  
  def reversi(cells, disk, x, y)
    false
  end
end