require_relative 'db_connection'
require 'active_support/inflector'
require 'pry'
#NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
#    of this project. It was only a warm up.

class SQLObject
  def self.columns
    cols = DBConnection.instance.execute2(
              "SELECT * FROM #{table_name} LIMIT 0"
           )
           .first.map(&:to_sym)
    
    cols.each do |col|
      define_method(col) do
        attributes[col]
      end
      define_method("#{col.to_s}=") do |val|
        attributes[col] = val
      end
    end
    
    cols
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    self.parse_all(DBConnection.instance.execute(
      "select #{self.table_name}.* from #{self.table_name}"
    ))
  end
  
  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.find(id)
    result = DBConnection.instance.execute(<<-SQL, id).first
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
      WHERE #{self.table_name}.id = ?
      LIMIT 1
    SQL
    
    self.new(result) if result
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    DBConnection.instance.execute(<<-SQL, *attribute_values)
  INSERT INTO #{self.class.table_name} (#{self.class.columns[1..-1].join(', ')})
  VALUES (#{ (['?']*self.class.columns[1..-1].length).join(', ') })
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |att, value|
      unless self.class.columns.include?(att.to_sym)
        raise ArgumentError.new("unknown attribute '#{att}'")
      end
      
      self.send("#{att.to_s}=", value)
    end
  end

  def save
    attributes[:id].nil? ? insert : update
  end

  def update
    DBConnection.instance.execute(<<-SQL, attribute_values, attributes[:id])
    UPDATE #{self.class.table_name}
    SET #{ attributes.keys.map { |att| "#{att} = ?"}.join(", ") }
    WHERE id = ?
    SQL
  end

  def attribute_values
    self.attributes.keys.map { |key| self.send(key) }
  end
end