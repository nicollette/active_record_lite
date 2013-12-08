require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  # sets the table_name
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
    all_rows = DBConnection.execute(<<-SQL)
      SELECT 
        *
      FROM 
        #{self.table_name}
    SQL
    self.parse_all(all_rows)
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    record = DBConnection.execute(<<-SQL, id)
      SELECT 
        *
      FROM 
        #{self.table_name}
      WHERE 
        id = ?
      LIMIT
        1
    SQL
    return nil if record.empty?
    self.parse_all(record).first
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def create
    attr_array = self.class.attributes
    attribute_names = attr_array.join(", ")
    question_marks = (['?'] * attr_array.length).join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO 
        #{self.class.table_name} (#{attribute_names})
      VALUES
      (#{question_marks})
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
  def update
    set_line = self.class.attributes.map do |attr_name|
      "#{attr_name} = ?"
    end.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE 
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = #{self.id}
    SQL
  end

  # call either create or update depending if id is nil.
  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  # helper method to return values of the attributes.
  def attribute_values
    self.class.attributes.map do |attr_name|
      self.send("#{attr_name}")
    end
  end
end