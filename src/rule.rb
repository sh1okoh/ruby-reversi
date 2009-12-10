require 'array2d'
require 'rule_event'
require 'forwardable'

module Rule
  
  module CellHelper
    
    def assert_disk(disk)
      raise InvalidArgument, "指定した#{disk}は有効ではありません。" unless Cell::Disks.value?(disk)
    end
    
    def assert_xy(x, y)
      raise "xには数字を入力して下さい" if(x == nil || !x.is_a?(Integer))
      raise "yには数字を入力して下さい" if(y == nil || !y.is_a?(Integer))
      raise "xには0以上#{Cells.col}以上の数字を入力して下さい" if(x < 0 || x >= Cells.col)
      raise "yには0以上#{Cells.row}以上の数字を入力して下さい" if(y < 0 || y >= Cells.row)
    end
    
    def invalid_xy?(x, y)
      begin
        assert_xy(x, y)
        false
      rescue RuntimeError => e
        true
      end
    end
  end
  
  #
  # 盤を構成する１マスです。
  #
  # オセロの石はdiskと表現しています。
  #
  class Cell
    include CellHelper
    
    Disks = {
      'blank' => '＋',
      'white' => '●',
      'black' => '○',
    }.freeze
    
    attr_reader :disk
    
    def initialize(disk)
      assert_disk(disk)
      @disk = disk
    end
    
    def reversi!(disk)
      assert_disk(disk)
      @disk = disk
    end
    
    def ==(other)
      return other.is_a?(Cell) ? other.disk == disk : false
    end
    
    def copy_deeply
      Cell.new(disk)
    end
    
    def Cell.BLANK
      Cell.new(Disks['blank'])
    end
    
    def Cell.WHITE
      Cell.new(Disks['white'])
    end
    
    def Cell.BLACK
      Cell.new(Disks['black'])
    end
  end  
  
  #
  # Cellを一列に並べたものです。
  #
  # Cellをdiskを置いた場所を基点とした前方向と後方向の2つに分けて保持しています。
  # 端においた場合など、前後ろどちらかの方向にCellがない場合には空配列を保持します。
  #
  class CellLine
    include CellHelper
    
    attr_reader :backs, :forwards
    
    def initialize(backs, forwards)
      @backs    = backs
      @forwards = forwards
    end
    
    #
    # 指定したdiskでひっくり返すことのできるCellを全て返します。
    #
    def collect_all(disk)
      assert_disk(disk)
      collect(disk, @backs) + collect(disk, @forwards)  
    end
    
    #
    # 指定したdiskでひっくり返せるならばtrueを返します。できなければfalseを返します。
    #
    def collect?(disk)
      assert_disk(disk)
      !collect_all(disk).empty?
    end
    
    #
    # このラインの起点に指定したdiskを置いてひっくり返します。
    #
    def reversi!(disk)
      assert_disk(disk)
      raise InvalidArgument, "指定した#{disk}ではひっくり返せません。" unless collect?(disk)
      collect_all(disk).each {|cell| cell.reversi!(disk)}
    end
    
    def ==(other)
      return false unless other.instance_of? CellLine
      return @backs == other.backs && @forwards == other.forwards
    end
    
    private
    #
    # 指定したdisksから指定したdiskでひっくり返すことのできるCellを返します。
    #
    def collect(disk, disks)
      assert_disk(disk)
      
      takes = []
      disks.each{|item|
        
        return []    if (item == Cell.BLANK)
        return takes if (item.disk == disk)
        takes.push(item)
      }
      return []
    end
  end
  #
  # 二次元なCellの集まりです。
  # デフォルトは縦8横8です。
  #
  class Cells
    include CellHelper
    
    attr_reader :cells
    
    @@row = 8
    @@col = 8
    
    #
    # Change row(x) size for Test.
    #
    def Cells.row=(row) @@row = row end
    #
    # Change column(y) size for Test.
    #
    def Cells.col=(col) @@col = col end
    
    def Cells.row() @@row end
    def Cells.col() @@col end
    
    #
    # 真ん中に白と黒を交互に置きます。
    #
    def self.create
      cells = Array2D.new(@@row, @@col){Cell.BLANK}
      cells.at(cells.row/2-1, cells.col/2-1).reversi!(Cell.WHITE.disk)
      cells.at(cells.row/2-1, cells.col/2  ).reversi!(Cell.BLACK.disk)
      cells.at(cells.row/2,   cells.col/2-1).reversi!(Cell.BLACK.disk)
      cells.at(cells.row/2,   cells.col/2  ).reversi!(Cell.WHITE.disk)
      Cells.new(cells)
    end
    
    def initialize(cells)
      @cells = cells
    end
    
    #
    # 縦一列
    #
    def fetch_x(x, y)
      assert_xy(x, y)
      return fetch_2way(x, y, 1, 0)
    end
    
    #
    # 横一列
    #w
    def fetch_y(x, y)
      assert_xy(x, y)
      return fetch_2way(x, y, 0, 1)
    end
    
    #
    # 右下がり
    #
    def fetch_right_slope(x, y)
      assert_xy(x, y)
      return fetch_2way(x, y, 1, 1)
    end
    
    #
    # 左下がり
    #
    def fetch_left_slope(x, y)
      assert_xy(x, y)
      return fetch_2way(x, y, -1, 1)
    end
    
    #
    # 前後2方向のデータを返します。
    # 
    def fetch_2way(x, y, add_x, add_y)
      assert_xy(x, y)
      CellLine.new(fetch(x, y,  add_x,  add_y), fetch(x, y, -add_x, -add_y))
    end
    
    #
    # 全方向のデータを返します。
    # 
    def fetch_all(x, y)
      assert_xy(x, y)
      [fetch_x(x, y), fetch_y(x, y), fetch_right_slope(x, y), fetch_left_slope(x, y)]
    end
    
    #
    # 一方向を取り出し返します
    #
    def fetch(x, y, add_x, add_y)
      assert_xy(x, y)
      
      raise "全てのパラメータが指定されていなければなりません" if x == nil || y == nil || add_x == nil || add_y == nil
      raise "全て0ではデータを取り出すことができません。"     if x == 0 && y == 0 && add_x == 0 && add_y == 0
      raise "add_xは1,0,-1のみ有効です" unless add_x.abs < 2
      raise "add_yは1,0,-1のみ有効です" unless add_y.abs < 2
      
      values = []
      loop {
        x -= add_x
        y -= add_y
        if (@cells.at?(x, y))
          values.push(@cells.at(x, y))
        else
          break
        end
      }
      return values
    end
    
    #
    # 指定した場所にdiskを置いてひっくり返します。
    #
    def reversi!(disk, x, y)
      
      raise "x=#{x},y=#{y}にdisk=#{disk}を置いてもひっくり返せません。" unless collect_at?(disk, x, y)
      
      collect_at(disk, x, y).each{|line| line.reversi!(disk)}
      @cells.at(x, y).reversi!(disk)
    end
    
    #
    # 指定した場所に石を置いてひっくり返せる方向を返します。
    #
    def collect_at(disk, x, y)
      return [] unless (@cells.at(x, y) == Cell.BLANK) 
      fetch_all(x, y).select{|line| line.collect?(disk)}
    end
    
    #
    # 指定した場所に石を置いてひっくり返せるかを返します。
    #
    def collect_at?(disk, x, y)
      !collect_at(disk, x, y).empty?
    end
    
    #
    # 指定した石でひっくり返せるデータがあるかを返します。
    #
    def collect?(disk)
      @cells.detect?{|x, y| collect_at?(disk, x, y)}
    end
  end
  
  #
  # ゲームの進行役です。
  #
  # 全ての行動はこれに問い合わせ代わりに実行してもらいます。
  #
  class GameMaster
    include CellHelper
    
    GameMaster.private_class_method :new
    
    def initialize(cells, players, event)
      @cells   = cells
      @players = players
      @event   = event
    end
    
    #
    # デフォルトのインスタンスを返します。
    # これはnewの代わりに利用します。
    #
    def self.create
      new(Cells.create, [Cell.BLACK.disk, Cell.WHITE.disk], RuleEvent.new)
    end
    
    #
    # 状態をdeepcopyしたcloneを返します。このインスタンスはevent通知を行ないます。
    #
    def self.clone(obj)
      new(obj.copied_cells, obj.players, RuleEvent.new)
    end
    
    #
    # 状態をdeepcopyしたcloneを返します。このインスタンスはevent通知を行ないません。
    #
    def self.clone_noevent(obj)
      new(obj.copied_cells, obj.players, NullRuleEvent.new)
    end
    
    def copied_cells
      Cells.new(@cells.cells.copy_deeply{|cell| cell.copy_deeply})
    end
    
    #
    # 現在のプレイヤーが指定した場所に置くことができればtrueを返します。できなければfalseを返します。
    #
    def reversi?(x, y)
      assert_xy(x, y)
      @cells.collect_at?(current_player, x, y)
    end
    
    #
    # 現在のプレイヤーが置くことができればtrueを返します。できなければfalseを返します。
    #
    def reversible?
      @cells.collect?(current_player)
    end
    
    #
    # ひっくり返します
    #
    def reversi!(x, y)
      assert_xy(x, y)
      raise "現在のプレイヤーは置くことができません" unless (reversible?)
      raise "現在のプレイヤーは指定した場所に置くことができません" unless (reversi?(x, y))
      
      @cells.reversi!(current_player, x, y)
      @event.reversi(cells.cells, current_player, x, y)
      turn
    end
    
    def skip
      @event.skip(current_player)
      turn
    end
    
    #
    # ターンを次に進めます
    # ひっくり返さず次に進めるとスキップと同義になります。
    #
    def turn
      @players.push(@players.shift)
      @event.turn
    end
    
    #
    # ゲームが終了しているかを返します。
    # 置ける場所があるうちはゲームが終わりません。
    #
    def end?
      @players.each{|disk| 
        if @cells.collect?(disk)
          return false   
        end
      }
      true
    end
    
    def players
      @players.dup
    end
    
    def current_player
      @players.first
    end
    
    def cells
      @cells
    end
    
  end
  
  #
  # Functions frozen GameMaster. 
  #
  class TerminatedGameMaster
    
    extend Forwardable
    def_delegators(:@master, :cells, :current_player, :players)
    
    def initialize(master)
      @master = master
    end
    
    def reversi?(x, y)
      false
    end
    
    def reversible? 
      false
    end
    
    def end?
      true
    end
    
    def reversi!(x, y)
      raise "A game terminated."
    end
    
    def skip
      raise "A game terminated."
    end
    
    def turn
      raise "A game terminated."
    end
  end
  
end