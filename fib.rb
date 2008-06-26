require 'rubiskell.rb'

def fib(n)
  Haskell.load("fib.hs").run(n)
end

puts "fib 5 is #{fib(5)}." 
