require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  
  def self.all
    query = <<-SQL
      SELECT 
        *
      FROM 
        #{self.table_name}
    SQL
    
    results = DBConnection.execute(query)
    self.parse_all(results)
  end

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.underscore.pluralize
  end

  def self.find(id)
    query = <<-SQL
      SELECT 
        *
      FROM 
        #{self.table_name}
      WHERE 
        id = :id
      LIMIT
        1
    SQL
    
    results = DBConnection.execute(query, :id => id)
    self.parse_all(results).first
  end

  def attribute_values
    self.class.attributes.map { |attr_name| self.send(attr_name) }
  end

  def insert
    attribute_names = self.class.attributes.join(", ")
    question_marks = (["?"] * self.class.attributes.length).join(", ")
    
    query = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{attribute_names})
      VALUES
        (#{question_marks})
    SQL
    
    DBConnection.execute(query, *self.attribute_values)
    self.id  = DBConnection.last_insert_row_id
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
  
  def update
    set_line = self.class.attributes.map do |attr_name|
      "#{attr_name} = ?"
    end.join(", ")
    
    query = <<-SQL
      UPDATE 
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?   
    SQL
    
    DBConnection.execute(query, *self.attribute_values, self.id)
  end
end