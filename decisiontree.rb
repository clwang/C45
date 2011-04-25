# CPSC 531 - ID3 Algorithm using the Car Evaluation Data Set from UCI Repository
# @Authors : Charles Wang   &   Jisu Ha

require "id3tree.rb"


# The Split data method will randomly split the data 80/20 ratio
def split_data(data, test_data, training_data)
  size = data.count
  train_size = (size * 0.90).round
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

def single_result(data, dtree)
  puts "Displaying test data set......\n"
  counter = 0
  count = data.count
  data.each do |d|
    print "#{counter += 1} ) "
    puts d.inspect
  end
  print "\n------------------------------------------------------------------------\n"
  begin
    print "Input a record number to be tested : "
    record = gets.chomp
    if record.to_i <= 0 || record.to_i > count
      puts "Invalid record, please try again!"
    end
  end while record.to_i <= 0 || record.to_i > count 
  print "You have selected record : "
  puts data[record.to_i-1].inspect
  puts "Processing.........\n"
  predict = dtree.predict(data[record.to_i-1])
  actual = data[record.to_i-1].last
  if predict == actual
    match = true
  else
    match = false
  end
  puts "Predicted: #{predict}   |    Actual: #{actual}    |  Match: #{match}"
  return true 
end

def menu
  print "\n------------------------------------------------------------------------\n"
  print "OPTIONS:\n"
  print "\t G : Graph \n"
  print "\t S : Select a record to test\n"  
  print "\t O : Display Available Menu Options\n"
  print "\t Q : Quit program\n"        
  print "------------------------------------------------------------------------\n\n"
end

def print_intro
  print "------------------------------------------------------------------------\n"
  print "\t\t Welcome to the ID3 Decision Tree Program \n"
  print "\t\t CPSC 531 - Spring 2011 \n"
  print "\t\t Developed by Jisu Ha and Charles Wang\n"      
  print "------------------------------------------------------------------------\n\n"
end

def graph(dtree)
  puts "Graphing......"
  dtree.graph("graph")
  puts "Graph completed... check for graph.png in the program directory"
end

attributes = ["buying", "maint", "doors", "persons", "lug_boot", "safety"]
training_data, test_data, fixed_data = [],[],[]

print_intro
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
menu

begin
  print "Input your menu selection: "
  input = gets.chomp
  case input
    when 'G','g' 
      graph(id3_tree)
    when 'S','s'
      single_result(test_data, id3_tree)
    when 'O','o' 
      menu
    when 'Q', 'q'
      puts "Quitting......"
      puts "Goodbye!!"
    else
      puts "Not a valid input, please try again!"
      menu
  end
end while !input.eql? 'q' || 'Q'
