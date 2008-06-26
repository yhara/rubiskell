require 'rubiskell'

FIB = <<EOD
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-2) + fib (n-1)
EOD

fib = Haskell.new(FIB)

puts "fib 5 is #{fib[5]}." 
