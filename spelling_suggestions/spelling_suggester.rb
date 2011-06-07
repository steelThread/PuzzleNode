#
# 
#
module SpellingSuggester
  def self.suggest
    input      = File.open('sample_input.txt')
    test_cases = input.readline.to_i
    puts test_cases
  end
end

SpellingSuggester.suggest
