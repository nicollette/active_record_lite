Active Record Lite
==================

Re-created Active Record's basic components: attr_accessor, mass_assignment, associations, and SQL queries. 

Highlights
==========

*   [https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/mass_object.rb](https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/mass_object.rb)

    *   attr_accessor: Used metaprogramming to get and set variables
    *   mass_assignment

*   [https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/sql_object.rb](https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/sql_object.rb)
    *   SQL queries: Re-created ::all, ::find, #insert, #update, #save methods with custom SQL queries.

*   [https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/searchable.rb](https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/searchable.rb)
    *   Re-created #where with SQL query.
    
*   [https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/associatable.rb](https://github.com/nicollette/active_record_lite/blob/master/lib/active_record_lite/associatable.rb)
    *   Used metaprogramming and SQL queries to recreate Active Record's associations: belongs_to, has_many, has_one_through.