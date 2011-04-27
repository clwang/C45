require 'graph/graphviz_dot'

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
      result += -value.to_f/counter*Math.log(value.to_f/counter)/Math.log(2.0) if (count > 0)
    end
    result
  end
  
  def classification
    # The classification is always the last element of the array
    collect { |i| i.last }
  end
  
  def most_common
    # this method is used to find the most common classification based on the data set
    freq = self.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    self.sort_by { |v| freq[v] }.last
  end
end

module DTree
  Node = Struct.new(:attribute, :gain)

  class ID3Tree
    def initialize (data, attributes)
      @tree = {}
      @attributes = attributes
      @data = data
      @default = data.classification.most_common
    end
    
    def get_information_gain(data, attributes, attribute)
      # grab all the possible values for the attribute passed into this function
      values = data.collect { |d| d[attributes.index(attribute)] }.uniq.sort
      
      # find all the possible matches for each value and store it in an array
      partitions = values.collect { |v| data.select { |d| d[attributes.index(attribute)] == v } }
      
      # calculate the entropy of all the attributes minus the total entropy of the data
      remainder = partitions.collect { |p| (p.size.to_f / data.size) * p.classification.calculate_entropy }.inject(0) {|result,element| element+=result }
      
      # return the array with the information gain and the index of the attribute name
      [data.classification.calculate_entropy - remainder, attributes.index(attribute)]
    end
    
    def begin(data=@data, attributes = @attributes)
      initialize(data, attributes)
      @tree = train(@data, @attributes, @default)
    end
    
    def train(data, attributes, default)
      # if the data set is empty then return the default expected value
      return default if data.empty?
      
      # if the entire data set has the same classification we will return that classification
      return data.first.last if data.classification.uniq.size == 1
      
      # if there are no more available attributes then we will return the most common classification value of the current data
      return default if attributes.empty?
      
      # Calculate the attribute that has the highest information gain and create a node
      total_gain = attributes.collect { |attribute| get_information_gain(data, attributes, attribute) }
      
      # find the highest information gain from the returned result
      highest_gain = total_gain.max { |a,b| a[0] <=> b[0] }
      
      # store the results in a node
      node = Node.new(attributes[total_gain.index(highest_gain)], highest_gain[0])
      
      tree = { node => {} }

      # get possible values of the current node (vi)
      values = data.collect { |d| d[attributes.index(node.attribute)] }.uniq.sort

      # partition the data of each set based on the values
      partitions = values.collect { |v| data.select { |d| d[attributes.index(node.attribute)] == v } }
      
      # for each partition of data, we will recursively repeat the id3 training algorithm and finally return the tree
      partitions.each_with_index { |items, index|
        # pass in the attributes - { A }, since we want to remove its parent node from the attributes list when recursing
        tree[node][values[index]] = train(items, attributes-[values[index]], items.classification.most_common)
      }
      tree
    end
    
    def predict(test_data)
      return traverse_tree(@tree, test_data)
    end
    
    def graph(filename)
      # we will initialize the Dot Graph Printer from http://rockit.sourceforge.net/subprojects/graphr/ 
      dgp = DotGraphPrinter.new(build_tree)
      # set the size of the image (70 is used for large scale graphs)
      dgp.size = 300
      dgp.write_to_file("#{filename}.png", "png")
    end
  
  private
    def traverse_tree(tree, data)
      attr = tree.to_a.first
      # if the tree goes down a branch that does not exist then return the default common value of the data set
      return @default if !attr[1][data[@attributes.index(attr[0].attribute)]]
      # we traverse down the tree seeing if we get a result. if the node points to a hash it means that there is another attribute node
      return attr[1][data[@attributes.index(attr[0].attribute)]] if !attr[1][data[@attributes.index(attr[0].attribute)]].is_a?(Hash)
      return traverse_tree(attr[1][data[@attributes.index(attr[0].attribute)]],data)
    end
    
    def build_tree(tree = @tree)
      # validation for an empty tree
      return [] unless tree.is_a?(Hash)
      # set a default if the tree is empty
      return [["default", @default]] if tree.empty?
      # get a node
      attr = tree.to_a.first
      # iterate through all the possible values of that node
      links = attr[1].keys.collect do |key|
        parent_text = "#{attr[0].attribute}\n(#{attr[0].object_id})"
        # if the node points to another attr node then set its text
        if attr[1][key].is_a?(Hash) then
          child = attr[1][key].to_a.first[0]
          child_text = "#{child.attribute}\n(#{child.object_id})"
        else
          child = attr[1][key]
          child_text = "#{child}\n(#{child.to_s.clone.object_id})"
        end
        label_text = "#{key}"
        
        # first index is the parent node aka main node
        # the second index is what the main node will point to (our node must be unique so we ID it)
        # the third index is the edge label aka the line that connects the nodes
        [parent_text, child_text, label_text]
      end
      # we will recursively build the tree by linking all the nodes
      attr[1].keys.each { |key| links += build_tree(attr[1][key]) }

      return links
    end
  end
end