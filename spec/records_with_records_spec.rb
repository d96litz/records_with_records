def setup_database(name, tables)
  before do
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      username: 'postgres',
      password: 'postgres'
    )

    ActiveRecord::Schema.define do
      recreate_database(name)
      self.verbose = true
      tables.each { |table| create_table(table, force: true) }
    end
  end

  after do
    ActiveRecord::Schema.define do
      self.verbose = true
      tables.each { |table| drop_table(table, force: true) }
    end
  end
end

RSpec.describe RecordsWithRecords do
  context 'when included into activerecord base with has_many relation' do
    setup_database(:records_with_records_test, %i[example_model has_many_records])

    class ExampleModel < ActiveRecord::Base
      has_many :has_many_records
    end

    class HasManyRecord < ActiveRecord::Base
    end

    it 'produces correct sql for with' do
      expect(
        ExampleModel.with(:has_many_records).to_sql
      ).to eq(ExampleModel.where(HasManyRecord.where('"has_many_records"."example_model_id" = "example_models"."id"').arel.exists).to_sql)
    end

    it 'produces correct sql for without' do
      expect(
        ExampleModel.without(:has_many_records).to_sql
      ).to eq(ExampleModel.where(HasManyRecord.where('"has_many_records"."example_model_id" = "example_models"."id"').arel.exists.not).to_sql)
    end
  end
end