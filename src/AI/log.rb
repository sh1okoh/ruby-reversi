
class Log
  
  @@enable = false
  
  def Log.enable?
    @@enable
  end
  
  def Log.enable(arg)
    raise "Argument type is not boolean." unless arg == true || arg == false
    @@enable = arg
  end
  
  def Log.p(s)
    
    return unless @@enable
    
    print s
  end
  
  def Log.scores(socres)
    
    return unless @@enable
    
    s = "\n"
    socres.each{|v|
      s += "#{v.item} score:#{v.score}\n"
    }
    s += "\n"
    
    print s 
  end
  
end