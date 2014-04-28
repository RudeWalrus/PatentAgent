class Me
  class << self
    attr_accessor :auth

    def set_value(hash={})
      @auth = hash.fetch(:auth) {false}
    end

    def do_work
      puts "Working on Auth"
      @auth = 15
    end
  end
end


x = Me.new