$: << File.expand_path(File.dirname(__FILE__)) + '/../lib'

require 'benchmark'
require 'patentagent.rb'

# puts "Patent Number(?)"
# number = gets.chomp

numbers = %w[US8011015] #US8084321 US7676765]
patents = {}

numbers.each do|pnum|
  patents[pnum] = PatentAgent::USPTO::Patent.fetch(pnum)
  puts "#{patents[pnum].name} is #{patents[pnum].valid?}"
end

#
# test for claims
#
patents.each do |name, patent|
  puts "#{name}"
  puts "\t Total Claims: #{patent.claims.count}"
  puts "\t Dep Claims:   #{patent.claims.dep_count} => #{patent.claims.dep_claims}"
  puts "\t InDep Claims: #{patent.claims.indep_count} => #{patent.claims.indep_claims}"

  patent.claims.each do |num, claim|
    puts "Claim: #{claim.dep}: #{claim.parent} =>#{claim.text}"
  end
end

#
# Test for fields
#
patents.each do |name, patent|
  puts "#{name}"
  puts "\t Title: #{patent.title}"
  puts "\t Abstract: #{patent.abstract}"
  puts "\t Inventors: #{patent.inventors}"
  puts "\t Assignees: #{patent.assignees}"
  puts "\t Text: #{patent.text}"

end