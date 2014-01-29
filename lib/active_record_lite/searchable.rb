require_relative './db_connection'

module Searchable
  def where(params)
    where_clause = params.keys.map do |attr_name|
      "#{attr_name} = ?"
    end.join(" AND ")
    
    records = DBConnection.execute(<<-SQL, *params.values)
      SELECT 
        *
      FROM
        #{self.table_name} 
      WHERE
        #{where_clause}
    SQL
    
    self.parse_all(records)
  end
end