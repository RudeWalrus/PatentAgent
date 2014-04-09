$: << File.expand_path(File.dirname(__FILE__)) + '/../lib'

require 'benchmark'
require 'patentagent.rb'

# puts "Patent Number(?)"
# number = gets.chomp

numbers = %w[US7071234 US8084321 US7676765]
patents = {}

numbers.each do|pnum|
  patents[pnum] = PatentAgent::USPTO::Patent.get(pnum)
  puts "#{patents[pnum].name} is #{patents[pnum].valid?}"
end

#
# test for claims
#
patents.each do |name, patent|
  puts "#{name}"
  puts "\t Total Claims: #{patent.claims.total}"
  puts "\t Dep Claims:   #{patent.claims.dep_count}"
  puts "\t InDep Claims: #{patent.claims.indep_count}"
end
