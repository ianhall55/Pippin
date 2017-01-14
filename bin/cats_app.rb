require_relative '../lib/sql_object'
require_relative '../lib/db_connection'
require 'byebug'

class Cat < SQLObject
	belongs_to :owner
end

class Owner < SQLObject
	belongs_to :house
end

class House < SQLObject
	has_many :owners
end

# DBConnection.reset

# p Cat.table_name
p Cat.all
# p Cat.all
# p Owner.all
# p House.all
# p Owner.all[0].house
# p House.all[0].owners
