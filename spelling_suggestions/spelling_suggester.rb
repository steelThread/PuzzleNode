module SpellingSuggester
  def self.suggest
    input = File.open('sample_input.txt')
    case_count = input.readline.to_i
    File.open('solution.txt', 'w+').puts(
      (1..case_count).collect {solve(fetch_test_case(input))}
    )
  end  
  
  def self.fetch_test_case(input)
    input.readline
    (0..2).collect {input.readline}
  end
  
  def self.solve(test_case)
    puts "solving #{test_case[0]}"
    attempt = test_case[0]
    first_attempt = lcs_size(attempt, test_case[1])
    first_attempt > lcs_size(attempt, test_case[2]) ? test_case[1] : test_case[2]
  end

  def self.lcs_size(s1, s2)
    c = Array.new(s1.size){Array.new(s2.size)}
    (0..s1.size-1).each {|i| c[i][0] = 0}
    (0..s2.size-1).each {|j| c[0][j] = 0}
    (1..s1.size).each do |i|
      (1..s2.size).each do |j|
        if s1[i] == s2[j]
          c[i][j] = 1 + c[i-1][j-1]
        else
          c[i][j] = [c[i][j-1], c[i-1][j]].max
        end
      end
    end
    c[s1.size-1][s2.size-1]
  end

  # def self.lcs_size(s1, s2)
  #   num = Array.new(s1.size){Array.new(s2.size)}
  #   len, ans = 0
  #   s1.scan(/./).each_with_index do |l1, i|
  #     s2.scan(/./).each_with_index do |l2, j|
  #       unless l1 == l2
  #         num[i][j] = 0
  #       else
  #         (i == 0 or j == 0) ? num[i][j] = 1 : num[i][j] = 1 + num[i-1][j-1]
  #         len = ans = num[i][j] if num[i][j] > len
  #       end
  #     end
  #   end
  #   ans
  # end
end
  
#   def self.lcs_size(str1, str2)
#     LCS.new(str1, str2).length
#   end
#   
#   class LCS
#     def initialize(str1, str2)
#       @str1, @str2 = str1, str2
#       @solved = Array.new(str1.size) {Array.new(str2.size)}      
#     end
#     
#     def length(i=0, j=0)
#       puts "i #{i} j #{j}"
#       if @solved[i][j].nil?
#         if @str1[i] == @str2[j]
#           @solved[i,j] = 1 + length(i+1, j+1)
#         else
#           @solved[i,j] = max(length(i+1, j), length(i, j+1))
#         end
#       end
#       @solved[i,j]
#     end
#   end
# end

SpellingSuggester.suggest


# def self.lcs_size(str1, str2)
#   return '' if str1.empty? or str2.empty?
#   match, test = str1[0], str2[0]
#   if match == test
#     match + lcs(str1[1..-1], str2[1..-1])
#   else
#     [lcs(str1, str2[1..-1]), lcs(str1[1..-1], str2)].max_by {|x| x.size}
#   end
# end
