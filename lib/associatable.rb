require_relative 'searchable'
require 'active_support/inflector'


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
    @foreign_key = options[:foreign_key] || "#{name.to_s.underscore}_id".to_sym
    @class_name = options[:class_name] || name.to_s.camelize.singularize
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.underscore}_id".to_sym
    @class_name = options[:class_name] || name.to_s.camelize.singularize
    @primary_key = options[:primary_key] || :id
  end
end

# Use send to get the value of the foreign key.
# Use model_class to get the target model class.
# Use where to select those models where the primary_key column is equal to the foreign key value.
# Call first (since there should be only one such item).
# Throughout this method definition, use the options object so that defaults are used appropriately.


module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method ("#{name}") do
      options = self.class.assoc_options[name]

      fk = self.send(options.foreign_key)
      instances = options.model_class.where(id: fk)
      instances.first

    end

  end

  def has_many(name, options = {})

    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method ("#{name}") do
      options = self.class.assoc_options[name]

      fk = options.foreign_key
      instances = options.model_class.where(fk => self.id)

    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]

      source_options =
        through_options.model_class.assoc_options[source_name]

      fk = self.send(through_options.foreign_key)
      through_instance = through_options.model_class.where(id: fk)

      fk = through_instance.first.send(source_options.foreign_key)
      instances = source_options.model_class.where(id: fk)
      instances.first
    end
  end
end

class SQLObject
  extend Associatable
end
