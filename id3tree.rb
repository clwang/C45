# Create some additional methods for the Ruby Array class
class Array
  def calculate_entropy
    # entropy calculation is done using the following algorithm
    # Entropy(acc, unacc) = - acc / (acc + unacc) * logbase2(acc/(acc+unacc)) - unacc / (acc + unacc) * logbase2(unacc/(acc+unacc)) - ....
    return 0 if empty?
    classification = {} 
    counter = 0
    result = 0
    # iterate through all classifications, in our case acceptable and unaccepatable
    # initially the hash is empty, the first instance will set the key and increase the value of the classification for each instance found
    # the counter will count the total, which will be the ( acc + unacc of our equation )
    each { |foo| classification[foo] = !classification[foo] ? 1 : (classification[foo] + 1); counter += 1 }
    classification.each do | key, value |
      # sums the entropy of all the attributes of a classification
      # we have to use a conversion method for the log since the algorithm uses log base 2, and the computer only knows log base 10
      result += -value.to_f/counter*Math.log(value.to_f/counter)/Math.log(2.0)
    end
    result
  end
  
  def classification
    # The classification is always the last element of the array
    collect { |i| i.last }
  end
end

module DTree
  Node = Struct.new(:attribute, :threshold, :gain)

  class ID3Tree
    def initialize (data, attributes)
      @tree = {}
      @attributes = attributes
      @data = data
      @attr_list = {}
    end
    
    def get_information_gain(data, attributes, attribute)
      # grab all the possible values for the attribute passed into this function
      values = data.collect { |d| d[attributes.index(attribute)] }.uniq.sort
      # find all the possible matches for each value and store it in an array
      partitions = values.collect { |v| data.select { |d| d[attributes.index(attribute)].eql?(v) } }
      remainder = partitions.collect { |p| (p.size.to_f / data.size) * p.classification.calculate_entropy }.inject(0) {|result,element| element+=result }
      # return the array with the information gain and the index of the attribute name
      [data.classification.calculate_entropy - remainder, attributes.index(attribute)]
    end
    
    def begin
      @tree = train(@data, @attributes)
    end
    
    def train(data, attributes)
      # if the entire data set has the same classification we will return that classification
      return @data.first.last if data.classification.uniq.size.eql? 1

      # Calculate the attribute that has the highest information gain and create a node
      total_gain = attributes.collect { |attribute| get_information_gain(data, attributes, attribute) }
      # find the highest information gain from the returned result
      highest_gain = total_gain.max { |a,b| a[0] <=> b[0] }
      # store the results in a node
      node = Node.new(attributes[total_gain.index(highest_gain)], highest_gain[1], highest_gain[0])
      # add the attribute to the used list so that way we don't use it again in our calculations down the tree
      @attr_list.has_key?(node.attribute) ? @attr_list[node.attribute] += [node.threshold] : @attr_list[node.attribute] = [node.threshold]
      tree = { node => {} }
      
      # check to see if we need to recursively go further down the tree by taking the exisiting node 
      # and seeing if the entropy of its attributes is either 1 or 0
      values = data.collect { |d| d[attributes.index(node.attribute)] }.uniq.sort
      puts values.inspect
      partitions = values.collect { |v| data.select { |d| d[attributes.index(node.attribute)].eql?(v) } }
      partitions.each_with_index { |items, index|
        tree[node][values[index]] = train(items, attributes-[values[index]])
      }
      puts tree
      tree
    end
    
    def predict(test_data)
      return traverse_tree(@tree, test_data)
    end
  
  private
    def traverse_tree(tree, data)
      attr = tree.to_a.first
      return attr[1][data[@attributes.index(attr[0].attribute)]] if !attr[1][data[@attributes.index(attr[0].attribute)]].is_a?(Hash)
      return traverse_tree(attr[1][data[@attributes.index(attr[0].attribute)]],data)
    end
  end
end