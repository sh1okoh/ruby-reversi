class Array2D
  
  attr_reader :row, :col, :max, :items
  
  def initialize(row, col)
    @row = row
    @col = col
    @max = @row * @col
    @items = Array.new(@max, nil)
    @items.map!{|item| item = yield}
  end
  
  def to_x(i) i % @row               end
  def to_y(i) i == 0 ? 0 :(i / @col) end
  
  def in_x?(x) x >= 0 && x < @row end
  def in_y?(y) y >= 0 && y < @col end
  
  def at?(x, y) x >= 0 && y >= 0 && x < @row && y < @col end
  def at (x, y) @items[y * @row + x]                     end
  
  #
  # ブロックが評価できればtrueを返します。
  #
  def detect?
    @items.each_index{|i| 
      return true if yield(to_x(i), to_y(i))
    }
    return false
  end
  
  #
  # xとyのindexを順にeachします。
  # このようなブロックになります。{|x, y| ...}
  #
  def each
    @items.each_index{|i| 
      yield(to_x(i), to_y(i))
    }
  end
  
  def copy_deeply
    i = -1
    return Array2D.new(@row, @col){ i += 1; yield(@items[i]) }
  end
  
end