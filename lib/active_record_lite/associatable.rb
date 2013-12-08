require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class = @other_class_name.constantize
  end

  def other_table_name
    @other_table_name = @other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams 
  attr_reader :foreign_key, :primary_key
  
  def initialize(name, params) 
    if params[:class_name].nil?
      @other_class_name = name.to_s.camelize
    else
      @other_class_name = params[:class_name]
    end
    
    if params[:primary_key].nil?
      @primary_key = "id"
    else
      @primary_key = params[:primary_key]
    end
      
    if params[:foreign_key].nil?
      @foreign_key = "#{name}_id"
    else
      @foreign_key = params[:foreign_key]
    end
  end

  def type
    @other_class
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable #SQLObject will extend this module
  def assoc_params
  end

  def belongs_to(name, params = {})
    settings = BelongsToAssocParams.new(name, params)
    where_clause = "#{self.table_name}.#{settings.foreign_key} = ?"
    define_method(name) do
      assoc_rows = DBConnection.execute(<<-SQL, settings.primary_key)
        SELECT 
          *
        FROM
          #{@other_table_name}
        WHERE
          #{where_clause}
        LIMIT
          1
      SQL
      
      @other_class.parse_all(assoc_rows)
    end
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
