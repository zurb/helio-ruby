source "https://rubygems.org"

gemspec

group :development do
  gem "coveralls", require: false
  gem "mocha", "~> 1.12.0"
  gem "rake"
  gem "shoulda-context"
  gem "test-unit"
  gem "timecop"
  gem "webmock"

  # Rubocop changes pretty quickly: new cops get added and old cops change
  # names or go into new namespaces. This is a library and we don't have
  # `Gemfile.lock` checked in, so to prevent good builds from suddenly going
  # bad, pin to a specific version number here. Try to keep this relatively
  # up-to-date, but it's not the end of the world if it's not.
  gem "rubocop", "0.50.0"
  gem "rack", ">= 2.0.8"

  platforms :mri do
    # to avoid problems, bring Byebug in on just versions of Ruby under which
    # it's known to work well
    if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("2.0.0")
      gem "byebug"
      gem "pry"
      gem "pry-byebug"
    end
  end
end
