require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
require_relative 'searchable'
require_relative 'associatable'
require 'byebug'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    if @columns.nil?
      columns = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
      @columns = columns.first.map(&:to_sym)
    else
      @columns
    end
  end

  def self.finalize!
    columns.each do |col_name|
      define_method "#{col_name}=" do |arg|
        attributes[col_name] = arg
      end

      define_method col_name do
        attributes[col_name]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    instances = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(instances)
  end

  def self.parse_all(results)
    instances = []
    results.each do |params|
      instances << self.new(params)
    end
    instances
  end

  def self.find(id)
    hash_values = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = #{id}
    SQL
    return nil if hash_values.empty?
    self.new(hash_values.first)
  end

  def initialize(params = {})

    params.each do |attr_name,val|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
    end
    self.class.finalize!
    params.each do |attr_name,val|
      self.send("#{attr_name}=", val)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # @attributes.values
    self.class.columns.map { |col| self.send("#{col}") }
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(",")
    ques_marks = ["?"] * cols.count
    vals = ques_marks.join(",")

    DBConnection.execute(<<-SQL,*attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{vals})
    SQL

    id = DBConnection.last_insert_row_id
    self.id = id
  end

#   UPDATE
# table_name
# SET
# col1 = ?, col2 = ?, col3 = ?
# WHERE
# id = ?


  def update
    cols = self.class.columns
    col_names = cols[1..-1].map {|col| "#{col} = ?"}
    set = col_names.join(",")
    rotate_values = *attribute_values.rotate

    DBConnection.execute(<<-SQL,rotate_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set}
      WHERE
        id = ?
    SQL
  end

  def save
    
    self.id.nil? ? send(:insert) : send(:update)
  end
end
