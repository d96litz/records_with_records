RSpec.describe RecordsWithRecords do
    context 'when included into activerecord base with has_many relation' do
      it 'provides with_[relation] method' do
        klass = Class.new(ActiveRecord::Base) do
          has_many :records
        end

        expect(klass).to respond_to(:with_records)
      end
    end
end