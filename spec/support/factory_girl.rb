RSpec.configure do |config|
  # Make short `#create` or `#build` factory_girl methods available in specs
  config.include FactoryGirl::Syntax::Methods

  factories_to_lint = FactoryGirl.factories.reject do |factory|
    factory.name.in? [:course, :section, :lesson, :user, :role]
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
