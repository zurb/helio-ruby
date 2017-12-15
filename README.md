# Helio Ruby Library

## Installation

You don't need this source code unless you want to modify the gem. If you just
want to use the package, just run:

    gem install helio-ruby

If you want to build the gem from source:

    gem build helio-ruby.gemspec

### Requirements

* Ruby 2.0+.

### Bundler

If you are installing via bundler, you should be sure to use the https rubygems
source in your Gemfile, as any gems fetched over http could potentially be
compromised in transit and alter the code of gems fetched securely over https:

``` ruby
source 'https://rubygems.org'

gem 'rails'
gem 'helio-ruby'
```

## Usage

The library needs to be configured with your account's secret key which is
available in your [Helio Dashboard][api-keys]. Set `Helio.api_token` to its
value:

``` ruby
require "helio"
Helio.api_token = "..."

# list charges
Helio::Participant.list()

# retrieve single charge
Helio::Participant.retrieve(
  "id",
)
```

### Per-request Configuration

It's also possible to set a per-request key and/or account:

``` ruby
require "helio"

Helio::Participant.list(
  {},
  :api_token => "sk_test_...",
  :api_id => "acct_..."
)

Helio::Participant.retrieve(
  "id",
  :api_token => "token...",
  :api_id => "acct_..."
)
```

### Configuring a Client

While a default HTTP client is used by default, it's also possible to have the
library use any client supported by [Faraday][faraday] by initializing a
`Helio::HelioClient` object and giving it a connection:

``` ruby
conn = Faraday.new
client = Helio::HelioClient.new(conn)
charge, resp = client.request do
  Helio::participant.retrieve(
    "id",
  )
end
puts resp.request_id
```

### Configuring CA Bundles

By default, the library will use its own internal bundle of known CA
certificates, but it's possible to configure your own:

    Helio.ca_bundle_path = "path/to/ca/bundle"

### Configuring Automatic Retries

The library can be configured to automatically retry requests that fail due to
an intermittent network problem:

    Helio.max_network_retries = 2

### Configuring Timeouts

Open and read timeouts are configurable:

```ruby
Helio.open_timeout = 30 // in seconds
Helio.read_timeout = 80
```

Please take care to set conservative read timeouts. Some API requests can take
some time, and a short timeout increases the likelihood of a problem within our
servers.

### Logging

The library can be configured to emit logging that will give you better insight
into what it's doing. The `info` logging level is usually most appropriate for
production use, but `debug` is also available for more verbosity.

There are a few options for enabling it:

1. Set the environment variable `HELIO_LOG` to the value `debug` or `info`:
   ```
   $ export HELIO_LOG=info
   ```

2. Set `Helio.log_level`:
   ``` ruby
   Helio.log_level = Helio::LEVEL_INFO
   ```

### Writing a Plugin

If you're writing a plugin that uses the library, we'd appreciate it if you
identified using `#set_app_info`:

    Helio.set_app_info("MyAwesomePlugin", version: "1.2.34", url: "https://myawesomeplugin.info");

This information is passed along when the library makes calls to the Helio
API.

## Development

Run the linter:

    bundle exec rake rubocop

Update bundled CA certificates from the [Mozilla cURL release][curl]:

    bundle exec rake update_certs

<!--
# vim: set tw=79:
-->
