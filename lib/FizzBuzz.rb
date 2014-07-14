module FizzBuzz
extend self
  def listing num
    (1..num).map do |x|
      if ((x%15) == 0)
        "FizzBuzz"
      elsif ((x%3) == 0)
        "Fizz"
      elsif ((x%5) == 0)
        "Buzz"
      else
        String(x)
      end
    end
  end

end