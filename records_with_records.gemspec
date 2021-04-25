Gem::Specification.new do |s|
  s.name        = 'records_with_records'
  s.version     = '0.0.1'
  s.summary     = 'Query records with/without records'
  s.description = "An extension for Active Record for querying records with or without associated records"
  s.authors     = ["Dario Litz"]
  # s.files       = ["lib/records_with_records.rb"]
  # s.homepage    =
  s.license       = 'MIT'
  s.add_development_dependency 'activerecord', '>= 6'
  s.add_development_dependency 'rubocop', '~> 0.60'
  s.add_development_dependency 'rubocop-performance', '~> 1.5'
  s.add_development_dependency 'rubocop-rspec', '~> 1.37'
  s.add_development_dependency 'rspec'
end