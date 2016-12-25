RSpec.configure do |config|
  # Make short `#create` or `#build` factory_girl methods available in specs
  config.include FactoryGirl::Syntax::Methods

  factories_to_lint = FactoryGirl.factories.reject do |factory|
    factory.name.in? [:course, :section, :lesson, :user, :role, :quiz_answer, :quiz_question]
  end

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint factories_to_lint
    ensure
      DatabaseCleaner.clean
    end
  end
end

# config.before(:each, js: true) do
#   # JS examples are run with Poltergeist which uses separate db
#   # connection. It's impossible to use :transaction strategy in this case
#   # because records shouldn't be available outside of the transaction (e.g. in
#   # another db connection). For such examples :truncation strategy is more
#   # appropriate.
#   DatabaseCleaner.strategy = :truncation
# end
