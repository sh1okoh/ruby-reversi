STDOUT.sync = true
$KCODE = "utf8"

require 'game_event'
require 'game'
require 'rule_event'
require 'rule'
require 'console/manual'
require 'console/console_view'
require 'AI/random'
require 'AI/brisket'

include Rule

Cells.row = 8
Cells.col = 8

GameEvent.add_listener(ConsoleView.instance)
RuleEvent.add_listener(ConsoleView.instance)

game = Game.new{|status|
  #{Cell.BLACK.disk => Random.new(status), Cell.WHITE.disk => Random.new(status)}
  {Cell.BLACK.disk => Manual.new, Cell.WHITE.disk => Brisket.new(status)}
  #{Cell.BLACK.disk => Random.new(status), Cell.WHITE.disk => Random.new(status)}
}

while(game.more?)
  game.action
end
