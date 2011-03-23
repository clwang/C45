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

puts fixed_data.count

foo = split_data(fixed_data, test_data, training_data)
training_data = foo[0]
test_data = foo[1]

test = DTree::ID3Tree.new(training_data, attributes)
test.hello