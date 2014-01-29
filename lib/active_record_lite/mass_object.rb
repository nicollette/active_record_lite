class MassObject
  def self.my_attr_accessible(*attributes)
    self.attributes.concat(attributes.map { |attr| attr.to_sym })
  end

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

  def self.attributes
    if self == MassObject
      raise "Must not call #attributes on MassObject directly"
    end
    @attributes ||= []
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      
      unless self.class.attributes.include?(attr_name)
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
      
      self.send("#{attr_name}=", value)
    end
  end
end
