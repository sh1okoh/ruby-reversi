class Random
  
  def initialize(game_status)
    @game_status = game_status
  end
  
  def receive
    return :random
  end
  
end