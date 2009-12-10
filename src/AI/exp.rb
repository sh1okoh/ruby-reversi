

module Exp
  
  class Power
    
    def initialize(cells)
      @cells  = cells
    end
    
    def count()
      
      max_x = @cells.row - 1
      max_y = @cells.col - 1
      
      disks = (@cells.row * @cells.col) - @cells.items.grep(Cell.BLANK).length
      disks + 1
      
      cnt = 0
      cnt += (32 / disks) if @cells.at(0, 0)
      cnt += (32 / disks) if @cells.at(0, max_y)
      cnt += (32 / disks) if @cells.at(max_x, 0)
      cnt += (32 / disks) if @cells.at(max_x, max_y)
      cnt
    end
  end
  
  class Corner
    
    def initialize(cells)
      @cells  = cells
    end
    
    def count(item)
      
      x = item['x']
      y = item['y']
      
      max_x = @cells.row - 1
      max_y = @cells.col - 1
      
      if (x == 0 && y == 0 || x == max_x && y == 0 || x == 0 && y == max_y || x == max_x && y == max_y)
        disks = (@cells.row * @cells.col) - @cells.items.grep(Cell.BLANK).length
        disks + 1
        64 / disks
      else
        0
      end 
    end
    
  end
  
  #
  # o-o のような両隣が敵のdiskで真ん中が空白の場合に高いスコアを付ける。4端だとさらによし。
  #
  # あとはおかれちゃいけない場所に置かないようにする。
  # そういう場所はポイント高くして、そういうところがあったら
  #
  class EnemyBlankEnemy
    
    def initialize(cells)
      @cells  = cells
    end
    
    def count(item)
      raise "Not Yet."
    end
    
  end
  
  #
  # 指定したitemを中心に4 * 4 に置いてあるdisk数を返します。
  #
  class Perimeter
    
    def initialize(cells)
      @cells  = cells
    end
    
    def count(item)
      
      s_x = item['x'] - 2
      s_y = item['y'] - 2
      e_x = item['x'] + 2
      e_y = item['y'] + 2
      
      counter = 0
       (s_x..e_x).each{|x|
       (s_y..e_y).each{|y|
          next         unless @cells.at?(x, y) 
          counter += 1 unless @cells.at(x, y) == Cell.BLANK
        }
      }
      return counter
    end
    
  end
  
  #
  # 空間の広さを返します。
  #
  class Expanse
    
    def initialize(cells)
      @cells  = cells
      @tracks = []
    end
    
    def count(item)
      
      counter = 0
      ways = [[1, 0],[0, 1], [-1, 0], [0, -1]]
      ways.each {|way|
        next_x   = way[0] + item['x']
        next_y   = way[1] + item['y']
        next_way = {'x' => next_x, 'y' => next_y}
        
        unless (@cells.at?(next_x, next_y))
          next
        end
        unless (@cells.at(next_x, next_y) == Cell.BLANK)
          next
        end
        if (@tracks.include?(next_way))
          next
        end
        @tracks << next_way
        counter += count(next_way) + 1
      }
      return counter
    end
  end
  
end