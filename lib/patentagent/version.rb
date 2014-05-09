# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module Patentagent
  class Version
    MAJOR = 0
    MINOR = 0
    PATCH = 5
    PRE   = "pre"
  
    # @return [String]
    def self.to_s
      [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end
  end
end
