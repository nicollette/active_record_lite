class MassObject
  # takes a list of attributes.
  # adds attributes to whitelist.

  def self.my_attr_accessible(*attributes)
    @attributes = attributes
  end

  # takes a list of attributes.
  # makes getters and setters
  def self.my_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method("#{attribute}") do
        instance_variable_get("@#{attribute}")
      end
      
      define_method("#{attribute}=") do |value|
        instance_variable_set("@#{attribute}", value)
      end
    end
  end


  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    new_objects = results.map do |result|
      self.new(result)
    end
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.is_a?(Symbol) ? attr_name : attr_name.to_sym
      
      if self.class.attributes.include?(attr_name)
         set_method_name = "#{attr_name}="
         self.send(set_method_name, value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end
