require 'rule'
require 'game_event'
require 'game_status'

class Game
  
  include Rule
  
  def initialize
    @master = GameMaster.create
    @status = GameStatus.new(@master)
    @event  = GameEvent.new
    @players = yield(@status)
    @histories = []
    
    show
    show_wait
  end
  
  def status
    @status
  end
  
  def show
    @event.board(@master.cells.cells)
  end
  
  def show_wait
    @event.wait(@master.current_player)
  end
  
  def help
    @event.help
  end
  
  def score
    @event.score(@status.score)
  end
  
  def skip
    @master.skip
  end
  
  def hint
    @event.hint(@status.hint)
  end
  
  def unknown
    @event.invalid
  end
  
  def random
    point = @status.random
    reversi!(point['x'], point['y'])
  end
  
  def exit
    auto_save {
      @event.score(@status.score)
      @event.game_end
      @master = TerminatedGameMaster.new(@master)
      @event.exit
    }
  end
  
  def skip
    auto_save {
      @master.skip
      exit unless (more?)
    }
  end
  
  def reversi!(x, y)
    auto_save {
      @master.reversi?(x, y) ? @master.reversi!(x, y) : @event.cant_reversi
      exit unless (more?)
    }
  end
  
  def auto_save
    @histories << @master.clone
    yield
  end
  private :auto_save
  
  def undo(num)
    num.times{
      return if (@histories.empty?)
      @master = @histories.pop 
      @status = GameStatus.new(@master)
    }
  end
  
  def verbose
    @status.verbose
  end
  
  def action
    args = @players[@master.current_player].receive
    args = [args] unless (args.is_a?(Array))
    send(args.shift, *args)
    
    show_wait
  end
  
  def more?
    return false if (@master.end?)
    return true  if (@master.reversible?)
    skip
    more?
  end
  
end
