require 'active_record'
require_relative 'records_with_records/association'

module RecordsWithRecords
  METHOD_NAME_REGEX = /^(with(out)?)_(\w+)$/.freeze

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def with(assoc, scope = nil)
      where(exist(find_reflection(assoc), scope))
    end

    def without(assoc, scope = nil)
      where.not(exist(find_reflection(assoc), scope))
    end

    def respond_to_missing?(name, *args)
      name.to_s =~ METHOD_NAME_REGEX || super
    end

    def method_missing(name, *args, &block)
      return super unless name.to_s =~ METHOD_NAME_REGEX

      send(Regexp.last_match[1], Regexp.last_match[-1], &block)
    end

    private

    def find_reflection(assoc)
      reflect_on_association(assoc) || raise("association #{assoc} does not exist for #{name}")
    end

    # Returns arel exists node
    def exist(reflection, assoc_scope)
      association = Association.for(reflection, assoc_scope)
      association.scope.where(arel_table.grouping(association.foreign_key.eq(arel_table[primary_key]))).arel.exists
    end
  end
end

ActiveRecord::Base.include(RecordsWithRecords)
