require 'rule'
include Rule

describe GameMaster do
  
  before(:each) do
    @master = GameMaster.create
  end
  
  it "置ける?" do
    @master.reversi?(2,3).should be_true
  end
  
  it "置けない" do
    @master.reversi?(1,1).should be_false
  end
  
  it "置いたので置けない" do
    @master.reversi!(2,3)
    @master.reversi?(2,3).should be_false
  end
  
  it "終わっていない1" do
    @master.end?.should be_false
  end
  
  it "終わっていない2" do
    @master.end?.should be_false
    @master.reversi!(2,3)
    @master.end?.should be_false
  end
  
end
