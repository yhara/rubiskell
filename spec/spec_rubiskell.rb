#
# spec_rubiskell.rb - Unit test with RSpec
#
$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require 'rubiskell'

FIB = <<EOD
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-2) + fib (n-1)
EOD

MANY_ARGS = <<EOD
foo :: String -> Int -> String -> String
foo s1 n s2 = s1 ++ (show n) ++ s2
EOD

describe "parse_signetures" do
  before(:each) do
    @hs = Haskell.new("")
  end

  it "should parse Int -> Int" do
    sigs = @hs.parse_signetures(FIB)
    sigs.should have(1).items

    sig = sigs.first
    sig.name.should == "fib"
    sig.args.should == [Integer]
    sig.ret.should  == Integer
    sig.tuple_form.should == "Int"
  end

  it "should parse many args" do
    sigs = @hs.parse_signetures("foo :: String->Int->String -> Int")
    sig = sigs.first
    sig.name.should == "foo"
    sig.args.should == [String, Integer, String]
    sig.ret.should  == Integer
    sig.tuple_form.should == "(String,Int,String)"
  end
end

describe "Rubiskell" do 
  it "should run fib" do
    fib = Haskell.new(FIB)
    fib[2].should == 1
    fib[3].should == 2
  end

  it "should pass many args" do
    many = Haskell.new(MANY_ARGS)
    many["1", 2, "3"].should == "123"
  end

  it "should run file" do
    fib = Haskell.load(File.expand_path("fib.hs", File.dirname(__FILE__)))
    fib[2].should == 1
  end
end
