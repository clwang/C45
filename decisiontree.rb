# CPSC 531 - ID3 Algorithm using the Car Evaluation Data Set from UCI Repository
# @Authors : Charles Wang   &   Jisu Ha

require "id3tree.rb"


# The Split data method will randomly split the data 70/30 ratio
def split_data(data, test_data, training_data)
  size = data.count
  train_size = (size * 0.70).round
  test_size = size - train_size
  data = data.shuffle
  counter = 0
  data.each do |item|
    counter += 1
    if counter <= train_size
      training_data.push(item)
    else
      test_data.push(item)
    end
  end
  return training_data, test_data
end

def print_output(dtree, test_data)
  print "Input a filename for the results: "
  output_name = gets.chomp
  total = 0
  matches = 0
  File.open(File.expand_path("results/" + output_name), 'w+') do |f|
    test_data.each { |data| 
      predict = dtree.predict(data)
      actual = data.last
      total += 1
      matches += 1 if predict == actual
      if predict == actual
        match = true
      else
        match = false
      end
      f.puts "Predicted: #{predict}   |    Actual: #{actual}    |  Match: #{match}"  
    }
    f.puts "------------------------------------------------------------------------"
    f.puts "Accuracy: #{(matches.to_f/total.to_f)*100}%"
  end
end

attributes = ["buying", "maint", "doors", "persons", "lug_boot", "safety"]
training_data, test_data, fixed_data = [],[],[]

print "Input your sample data: "
file_name = gets.chomp
data = File.open(File.expand_path("test_data/" + file_name))

#convert the data from a string into an array
data.each_line do |item|
  row = item.strip.split(",")
  if !(row.last.eql?("vgood") || row.last.eql?("good"))
    fixed_data.push(row)
  end
end

foo = split_data(fixed_data, test_data, training_data)
training_data = foo[0]
test_data = foo[1]

id3_tree = DTree::ID3Tree.new(training_data, attributes)
id3_tree.begin

print_output(id3_tree,test_data)