module RecordsWithRecords
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def has_many(name, scope = nil, **options, &extension)
      super
      reflection = reflect_on_association(name)
      define_with(reflection)
      define_without(reflection)
    end

    private

    # Defines a singleton method 'with_[association]'
    # returns scope with associated [association] records
    def define_with(reflection)
      define_singleton_method "with_#{reflection.name}" do |assoc_scope = nil|
        where(exist(reflection, assoc_scope))
      end
    end

    # Defines a singleton method 'without_[association]'
    # returns scope without associated [association] records
    def define_without(reflection)
      define_singleton_method "without_#{reflection.name}" do |assoc_scope = nil|
        where.not(exist(reflection, assoc_scope))
      end
    end

    # Returns arel exists
    def exist(reflection, assoc_scope)
      association = Association.for(reflection, assoc_scope)
      association.scope.where(association.foreign_key.eq(arel_table[primary_key])).arel.exists
    end
  end

  class Association
    def initialize(reflection, assoc_scope)
      @reflection = reflection
      @assoc_scope = assoc_scope
    end

    def self.for(reflection, assoc_scope)
      (reflection.through_reflection ? HasManyThrough : HasMany).new(reflection, assoc_scope)
    end

    def scope
      raise NotImplementedError
    end

    def foreign_key
      raise NotImplementedError
    end
  end

  class HasMany < Association
    def scope
      s = @reflection.klass
      s = s.instance_eval(&@reflection.scope) if @reflection.scope
      s = s.instance_exec(&@assoc_scope) if @assoc_scope
      s
    end

    def foreign_key
      @reflection.klass.arel_table[@reflection.foreign_key]
    end
  end

  class HasManyThrough < Association
    def scope
      source = source_reflection.klass.all
      source = source.instance_eval(&@reflection.scope) if @reflection.scope
      source = source.instance_exec(&@assoc_scope) if @assoc_scope

      through_reflection.klass.joins(source_reflection.name).merge!(source)
    end

    def foreign_key
      through_reflection.klass.arel_table[through_reflection.foreign_key]
    end

    private

    def through_reflection
      @reflection.through_reflection
    end

    def source_reflection
      @reflection.source_reflection
    end
  end
end