require_relative '../lib/active_record_lite'

class MyMassObject < MassObject
  my_attr_accessible(:x, :y)
  my_attr_accessor(:x, :y)
end

obj = MyMassObject.new(:x => :x_val, :y => :y_val)
p obj
