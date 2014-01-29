require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    other_class_name.constantize
  end

  def other_table_name
    other_class.table_name
  end
  
end

class BelongsToAssocParams < AssocParams 
  attr_reader :params
  attr_accessor :assoc_params

  def initialize(name, params) 
    defaults = {
      :class_name => name.to_s.camelize,
      :primary_key => "id",
      :foreign_key => "#{name}_id"
    }
    @params = defaults.merge(params)
  end
  
  def foreign_key
    self.params[:foreign_key]
  end
  
  def primary_key
    self.params[:primary_key]
  end
  
  def other_class_name
    self.params[:class_name]
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :params
  def initialize(name, params, self_class)
    defaults = {
      :class_name => name.to_s.singularize.camelize,
      :primary_key => "id",
      :foreign_key => "#{self.class.to_s.downcase.underscore}_id"
    }
    
    @params = defaults.merge(params)
  end
  
  def foreign_key
    self.params[:foreign_key]
  end
  
  def primary_key
    self.params[:primary_key]
  end
  
  def other_class_name
    self.params[:class_name]
  end
  
  def type
  end
end

module Associatable #SQLObject will extend this module
  def assoc_params
    @assoc_params ||= {}
  end
  
  def belongs_to(name, params = {})
    settings = BelongsToAssocParams.new(name, params)
    p self.assoc_params[name] = settings
    
    define_method(name) do
      other_table = settings.other_table_name
      foreign_key_value = self.send("#{settings.foreign_key}")      
      where_clause = "#{other_table}.#{settings.primary_key} = ?" 
      
      query = <<-SQL
          SELECT 
            *
          FROM
            #{other_table}
          WHERE
            #{where_clause}
          LIMIT
            1
      SQL
            
      results = DBConnection.execute(query, foreign_key_value)
      settings.other_class.parse_all(results).first
    end
  end

  def has_many(name, params = {})
    settings = HasManyAssocParams.new(name, params, self)
    
    define_method(name) do
      other_table = settings.other_table_name

      where_clause = "#{other_table}.#{settings.foreign_key} = ?"
      primary_key_value = self.send("#{settings.primary_key}")
      
      query = <<-SQL
        SELECT
          *
        FROM
          #{other_table}
        WHERE
          #{where_clause}
      SQL
      
      results = DBConnection.execute(query, primary_key_value)
      settings.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    
    define_method(assoc2) do 
      assoc1_params = self.class.assoc_params[assoc1]
      assoc2_params = assoc1_params.other_class.assoc_params[assoc2]
      
      join_clause = 
        "#{assoc1_params.other_table_name}.#{assoc2_params.foreign_key}" +
          " = #{assoc2_params.other_table_name}.#{assoc2_params.primary_key}"
       puts "JOIN CLAUSE: #{join_clause}"
   
      where_clause = 
        "#{assoc1_params.other_table_name}.#{assoc1_params.primary_key} = ?"
      foreign_key_value = self.send("#{assoc1_params.foreign_key}")
   
      query = <<-SQL
        SELECT
          #{assoc2_params.other_table_name}.*
        FROM
          #{assoc1_params.other_table_name}
        JOIN
          #{assoc2_params.other_table_name} 
        ON
          #{join_clause}
        WHERE
          #{where_clause}
        LIMIT
          1
      SQL
    
      results = DBConnection.execute(query, foreign_key_value)
      assoc2_params.other_class.parse_all(results).first
    end
  end
end
