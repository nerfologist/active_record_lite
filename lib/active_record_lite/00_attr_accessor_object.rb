class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |att|
      define_method(att) { instance_variable_get("@#{att}") }
      define_method("#{att}=") { |arg| instance_variable_set("@#{att}", arg) }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  
end