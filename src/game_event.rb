#
# ゲームの状態が変わったことを通知します。
#
class GameEvent
  
  @@listeners = []
  
  def GameEvent.add_listener(listener)
    raise if listener == nil
    @@listeners << listener
  end
  
  def initialize
    
    @game_end = proc{|o, *any| 
      o.game_end if defined? o.game_end
    }
    @exit = proc{|o, *any| 
      o.exit if defined? o.exit
    }
    @abort = proc{|o, e| 
      o.game_abort(e) if defined? o.game_abort
    }
    @invalid = proc{|o, *any| 
      o.invalie_command if defined? o.invalie_command
    }
    @board = proc{|o, cells| 
      o.board(cells) if defined? o.board
    }
    @wait = proc{|o, disk| 
      o.wait_command(disk) if defined? o.wait_command
    }
    @cant_reversi = proc{|o, *any| 
      o.player_cant_reversi_at if defined? o.player_cant_reversi_at
    }
    @help = proc{|o, *any| 
      o.help if defined? o.help
    }
    @score = proc{|o, scores| 
      o.score(scores) if defined? o.score
    }
    @hint = proc{|o, hints| 
      o.hint(hints) if defined? o.hint
    }
  end
  
  def board(cells)
    notify(@board, cells)
  end
  
  def invalid
    notify(@invalid)
  end
  
  def wait(disk)
    notify(@wait, disk)
  end
  
  def abort(e)
    notify(@abort, e)
  end
  
  def exit
    notify(@exit)
  end
  
  def game_end
    notify(@game_end)
  end
  
  def cant_reversi
    notify(@cant_reversi)
  end
  
  def help
    notify(@help)
  end
  
  def score(scores)
    notify(@score, scores)
  end
  
  def hint(hints)
    notify(@hint, hints)
  end
  
  private
  
  def notify(procedure, *any)
    @@listeners.each{|o| procedure.call(o, *any)}
  end
end

class NullGameEvent
  
  def board(cells)
    false
  end
  
  def invalid
    false
  end
  
  def wait(disk)
    false
  end
  
  def abort(e)
    false
  end
  
  def exit
    false
  end
  
  def game_end
    false
  end
  
  def cant_reversi
    false
  end
  
  def help
    false
  end
  
  def score(scores)
    false
  end
  
  def hint(hints)
    false
  end
end