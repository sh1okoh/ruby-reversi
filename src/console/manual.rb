require 'rule'

class Manual
  include Rule::CellHelper
  
  def receive
    begin 
      cmd, arg1, arg2, *others = input
      
      if (cmd =~ /[0-9]/)
        arg2 = arg1
        arg1 = cmd
        cmd = 'reversi'
      end
      if (cmd == 'reversi')
        return create_reversi(arg1, arg2)
      end
      if (cmd == 'undo')
        return create_undo(arg1)
      end
      return {
        'exit'    => :exit,
        'show'    => :show,
        'skip'    => :skip,
        'score'   => :score,
        'help'    => :help,
        'hint'    => :hint,
        'random'  => :random,
        'r'       => :random,
        'undo'    => :undo,
        'verbose' => :verbose,
      }.fetch(cmd, :unknown)
      
    rescue InvalidCommandException
      'unknown'
    end
  end
  
  private
  
  def create_undo(arg1)
    if (arg1 == nil)
      return :undo, 2
    end
    begin
      num = Integer(arg1)
    rescue ArgumentError => e
      raise InvalidCommandException, "戻す手数には数字を入力して下さい"
    end
    return :undo, num
  end
  
  def create_reversi(arg1, arg2)
    if (arg1 == nil || arg2 == nil)
      raise InvalidCommandException, "パラメータの入力が足りません" 
    end
    begin
      x = Integer(arg1)
      y = Integer(arg2)
    rescue ArgumentError => e
      raise InvalidCommandException, "xとyには数字を入力して下さい"
    end
    if (invalid_xy?(x, y))
      raise InvalidCommandException, "xとyの値は有効ではありません"
    end
    return :reversi!, x, y
  end
  
  #
  # コンソールからの入力を受け付けます。
  #
  def input
    str = gets
    if (str == nil || str.strip == "")
      raise InvalidCommandException, "パラメータが入力されていませんでした" 
    end
    return str.strip.split
  end
  
  class InvalidCommandException  < Exception; end
end