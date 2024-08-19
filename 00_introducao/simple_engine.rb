require "yaml"

solutions = []
propositions = []
queries = []

# Load propositions and queries from a YAML file passed as first argument
# and store them in an array

if ARGV.size > 0
  filename = ARGV[0]
  if File.exist?(filename)
    data = YAML.load_file(filename)
    if data
      if data["propositions"]
        propositions = data["propositions"]
      end
      if data["queries"]
        queries = data["queries"]
      end
    end
  end
end

# Extract all variables from the propositions
# and store them in an array

variables = propositions.map do |expression|
  expression.scan(/[a-z0-9]+/).uniq
end.flatten.uniq.sort

# Declare variables from extracted variables

b = binding

variables.each do |variable|
  eval("#{variable} = false", b)
end

puts "# Expressions"
puts propositions.join("\n")

# puts "\n# Variables"
# puts variables.join("\n")

# create all permutations on variables a, c, d, e, f, i
# where a, c, d, e, f, i are boolean variables

# a, c, d, e, f, i = [false, false, false, false, false, false]

permutations = [false, true].repeated_permutation(variables.size).to_a

permutations.each do |permutation|
  variables.each_with_index do |variable, index|
    eval("#{variable} = #{permutation[index]}", b)
  end
  if propositions.map { |expression| eval(expression, b) }.all? 
    solutions << permutation
  end
end

puts "\n# Solutions"
puts variables.join("\t") if solutions.size > 0
solutions.each do |solution|
  puts solution.join("\t")
end

puts "\n# Queries"
solutions.each do |solution|
  variables.each_with_index do |variable, index|
    eval("#{variable} = #{solution[index]}", b)
  end
  queries.each do |query|
    result = eval(query, b)
    puts [query, result].join("=") 
  end
end

