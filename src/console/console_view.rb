require 'singleton'

class ConsoleView
  include Singleton
  
  def wait_command(disk)
    print "#{disk}さん。入力してください:"
  end
  
  def invalie_command
    print "不明なコマンドが入力されました。\n"
  end
  
  def player_cant_reversi_at
    print "置けない場所を指定しました。\n"
  end
  
  def player_skiped(disk)
    print "#{disk}はスキップしました。\n"
  end
  
  def board(cells)
    print "  "
    cells.row.times{|i|
      print format("%2d", i)
    }
    cells.items.each_with_index{|cell, index| 
      
      if (index % cells.row == 0)
        print "\n"
        print format("%2d", index / cells.row)
      end
      print cell.disk
    }
    print "\n"
    
  end
  
  def score(scores)
    
    print "\n"
    scores.each_pair{|key, value| 
      print "#{key} = #{value}\n"
    }
    print "\n"
  end
  
  def reversi(cells, disk, x, y)
    print "#{disk}は x=#{x}, y=#{y}におきました。\n"
    board(cells)
  end
  
  def turn
    print "ターンが進みました。\n"
  end
  
  def exit
    print "\nゲームを終了します。\n"
  end
  
  def hint(hints)
    
    print "\n"
    hints.each{|xy|
      print "(#{xy['x']} #{xy['y']}): x = #{xy['x']}, y = #{xy['y']}"
      print "\n"
    }
  end
  
  def game_end
    print "\nゲームが終わりました。\n"
  end
  
  def game_abort(exception)
    print exception.class.to_s + " : " + exception.message + "\n"
    print exception.backtrace.join("\n")
    print "\nゲームを強制終了します。#{exception.message}\n"
  end
  
  def help
    print <<HELP

----------------------------------------------------------------
  exit
    ゲームを終了します
  show
    ボードを表示します
  skip
    自手をスキップします
  score
    スコアを表示します
  help
    ヘルプを表示します
  hint
    プレイヤー置ける場所を表示します
  random, r
    ランダムでプレイヤーが置ける場所に置きます
  undo
    手を戻します。undo 2 とすると2手戻します。
    数字を入力しなければ2手戻します。
  verbose
    冗長なデバックメッセージを有効にします。
    もう一度指定すると無効になります。
  reversi
    石を置きます。reversi 0 1 とするとx=0, y=1に石を置きます。
    reversiは省略可能です。
----------------------------------------------------------------
HELP
  end
  
end