# Create some additional methods for the Ruby Array class
class Array
  def calculate_entropy
    
  end
end

module DTree

  class ID3Tree
    def initialize (data, attributes)
      @tree = {}
      @attributes = attributes
      @data = data
    end

    def hello
      puts "hello world"
    end 
  end
end