class Person
  attr_accessor :name, :sex
  def initialize(name, sex)
    @name, @sex = name, sex
  end
end

class Programmer < Person
  def initialize(name, sex, lang)
    super(name, sex)
    @lang = lang
  end
  def name
    "#{@name} The #{@lang} Programmer"
  end
end


p1 = Person.new("Bowo", 21)
p2 = Programmer.new("Agus", 32, "Ruby")

puts "p1.name: #{p1.name}"
puts "p2.name: #{p2.name}"
