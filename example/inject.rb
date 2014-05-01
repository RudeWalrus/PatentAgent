arr = %w[ a word that has no meaning]

def cap(word); word.upcase; end
p sum = arr.inject([]){|o, word| o << cap(word)}  # !> assigned but unused variable - sum

@pig=10
p (2..@pig).map(&:to_s)