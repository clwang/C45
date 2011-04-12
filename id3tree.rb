# Create some additional methods for the Ruby Array class
class Array
  def calculate_entropy
    # entropy calculation is done using the following algorithm
    # Entropy(acc, unacc) = - acc / (acc + unacc) * logbase2(acc/(acc+unacc)) - unacc / (acc + unacc) * logbase2(unacc/(acc+unacc))
    classification = {} 
    counter = 0
    # iterate through all classifications, in our case acceptable and unaccepatable
    # initially the hash is empty, the first instance will set the key and increase the value of the classification for each instance found
    # the counter will count the total, which will be the ( acc + unacc of our equation )
    each { |foo| classification[foo] = !classification[foo] ? 1 : (classification[foo] + 1); counter += 1 }
    classification.each do | key, value |
      puts key
      puts value
    end
  end
  
  def classification
    # The classification is always the last element of the array
    collect { |i| i.last }
  end
end

module DTree

  class ID3Tree
    def initialize (data, attributes)
      @tree = {}
      @attributes = attributes
      @data = data
      puts @data.count
    end
    
    def get_information_gain(data, attributes, attribute)
      # grab all the possible values for the attribute passed into this function
      values = data.collect { |d| d[attributes.index(attribute)] }.uniq.sort
      # find all the possible matches for each value and store it in an array
      partitions = values.collect { |v| data.select { |d| d[attributes.index(attribute)].eql?(v) } }
      puts partitions.inspect
      remainder = partitions.collect { |p| (p.size.to_f / data.size) * p.classification.calculate_entropy }.inject(0) {|result,element| element+=result }
    end
    
    def begin
      @tree = train(@data, @attributes)
    end
    
    def train(data, attributes)
      # if the entire data set has the same classification we will return that classification
      return @data.first.last if data.classification.uniq.size.eql? 1

      # Calculate the attribute that has the highest information gain and create a node
      total_gain = attributes.collect { |attribute| get_information_gain(data, attributes, attribute) }
    end
  end
end