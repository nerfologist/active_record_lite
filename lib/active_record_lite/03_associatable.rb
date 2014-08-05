require_relative '02_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :class_name => name.to_s.titleize,
      :foreign_key => "#{name.to_s}_id".to_sym,
      :primary_key => :id
    }
    
    opts = defaults.merge(options)
    opts.each { |k, v| send("#{k}=", v) }
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :class_name => name.to_s.singularize.titleize,
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :primary_key => :id
    }
    
    opts = defaults.merge(options)
    opts.each { |k, v| send("#{k}=", v) }
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    
    define_method(name) do
      options.model_class.where(
        options.primary_key => self.send(options.foreign_key)
      ).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      options.class_name.constantize.where(
        options.foreign_key => self.send(options.primary_key)
      )
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
