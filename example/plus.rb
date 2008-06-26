require 'rubiskell'

def plus(x, y)
  Haskell.load("plus.hs").run(x, y)
end

puts "5 + 6 is #{plus(5, 6)}." 
