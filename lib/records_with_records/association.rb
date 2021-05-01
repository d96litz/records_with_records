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

  private

  def apply_scopes(scope)
    scope = scope&.instance_exec(&@assoc_scope) if @assoc_scope
    scope = scope&.instance_exec(&@reflection.scope) if @reflection.scope
    scope
  end

  class HasMany < Association
    def scope
      apply_scopes(@reflection.klass.all)
    end

    def foreign_key
      @reflection.klass.arel_table[@reflection.foreign_key]
    end
  end

  class HasManyThrough < Association
    def scope
      source = source_reflection.klass.all
      source = apply_scopes(source)
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

  # TODO: Add belongs_to association
end
