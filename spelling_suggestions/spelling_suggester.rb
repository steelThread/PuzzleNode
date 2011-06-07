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
    attempt = test_case[0]
    puts lcs(attempt, test_case[1])
    puts lcs(attempt, test_case[2])
    first_attempt = lcs(attempt, test_case[1]).size
    first_attempt > lcs(attempt, test_case[2]).size ? test_case[1] : test_case[2]
  end
  
  def self.lcs(str1, str2)
    return '' if str1.empty? or str2.empty?
    match, test = str1[0], str2[0]
    if match == test
      match + lcs(str1[1..-1], str2[1..-1])
    else
      [lcs(str1, str2[1..-1]), lcs(str1[1..-1], str2)].max_by {|x| x.size}
    end
  end
end

SpellingSuggester.suggest
