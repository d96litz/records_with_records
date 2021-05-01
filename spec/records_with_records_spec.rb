def setup_database(name, tables)
  before do
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      username: 'postgres',
      password: 'dario'
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
    setup_database(:records_with_records_test, %i[users posts])

    class User < ActiveRecord::Base
      has_many :posts
      has_many :read_posts, -> { where(read: true) }, class_name: 'Post'
    end

    class Post < ActiveRecord::Base
    end

    it "produces correct sql for 'where_exists'" do
      expect(
        User.where_exists(:posts).to_sql
      ).to eq(User.where(Post.where('"posts"."user_id" = "users"."id"').arel.exists).to_sql)
    end

    it "produces correct sql for 'where_not_exists'" do
      expect(
        User.where_not_exists(:posts).to_sql
      ).to eq(User.where(Post.where('"posts"."user_id" = "users"."id"').arel.exists.not).to_sql)
    end

    it "produces correct sql for 'where_exists' with reflection scope" do
      expect(
        User.where_exists(:read_posts).to_sql
      ).to eq(User.where(Post.where(read: true).where('"posts"."user_id" = "users"."id"').arel.exists).to_sql)
    end
  end
end