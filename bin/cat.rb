require_relative '../lib/sql_object'

class Cat < SQLObject
  belongs_to :owner

end

class Owner < SQLObject
	belongs_to :house
  has_many :cats
  
end

class House < SQLObject
	has_many :owners

end
