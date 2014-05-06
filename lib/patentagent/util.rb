module PatentAgent
  module Util
    # coersion function for converting things to PatentNumbers
    module_function

    def PatentNumber(arg)
      case arg
      when PatentNumber           then arg
      when String, Integer        then PatentNumber.new(arg)
      when Array                                              # array of strings or PatentNumbers
        arg.flatten.map{|n| PatentNumber(n)}
      when ->(n) {n.respond_to? :to_patent}
        arg.to_patent
      else
        raise TypeError, "Cannot convert #{arg.inspect} to PatentNumber"
      end
    end
  end
end