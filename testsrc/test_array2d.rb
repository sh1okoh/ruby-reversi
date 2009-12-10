require 'test/unit'
require 'array2d'

class TestArray2D < Test::Unit::TestCase
  
  def test_init
    array = Array2D.new(1, 1){7}
    assert_equal(7, array.at(0, 0))
  end
  
  def test_to_x
    array = Array2D.new(1, 1){0}
    assert_equal(0, array.to_x(1))
  end
  
  def test_to_y
    array = Array2D.new(1, 1){0}
    assert_equal(2, array.to_y(2))
  end
  
  def test_in_x
    array = Array2D.new(2, 2){0}
    assert_equal(true,  array.in_x?(1))
    assert_equal(false, array.in_x?(2))
  end
  
  def test_in_y
    array = Array2D.new(2, 2){0}
    assert_equal(true,  array.in_y?(1))
    assert_equal(false, array.in_y?(2))
  end
  
  def test_detect
    i = -1
    array = Array2D.new(2, 2){i += 1}
    
    assert_equal(true,  array.detect?{|x, y| array.at(x, y) == 3}, "3はある")
    assert_equal(false, array.detect?{|x, y| array.at(x, y) == 5}, "5はない")
  end
  
  def test_each
    array = Array2D.new(2, 2){0}
    
    counter = 0;
    array.each{|x, y| 
      if (counter == 0) 
        assert_equal(0, x)
        assert_equal(0, y)
      end
      if (counter == 1) 
        assert_equal(1, x)
        assert_equal(0, y)
      end
      counter += 1
    }
    assert_equal(4, counter, "2*2で4になる")
  end
  
  def test_copy_deeply
    
    i = 3
    array1 = Array2D.new(2, 2){i += 1}
    array2 = array1.copy_deeply{|i| i}
    
    assert_equal(4, array1.items[0])
    assert_equal(5, array1.items[1])
    assert_equal(6, array1.items[2])
    assert_equal(7, array1.items[3])
    assert_equal(4, array2.items[0])
    assert_equal(5, array2.items[1])
    assert_equal(6, array2.items[2])
    assert_equal(7, array2.items[3])
  end
  
end