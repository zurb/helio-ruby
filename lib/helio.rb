# Helio Ruby bindings
# API spec at https://helio.zurb.com
require "cgi"
require "faraday"
require "json"
require "logger"
require "openssl"
require "rbconfig"
require "securerandom"
require "set"
require "socket"
require "uri"

# Version
require "helio/version"

# API operations
require "helio/api_operations/create"
require "helio/api_operations/delete"
require "helio/api_operations/list"
require "helio/api_operations/nested_resource"
require "helio/api_operations/request"
require "helio/api_operations/save"

# API resource support classes
require "helio/errors"
require "helio/util"
require "helio/helio_client"
require "helio/helio_object"
require "helio/helio_response"
require "helio/list_object"
require "helio/api_resource"
require "helio/singleton_api_resource"

# Named API resources
require "helio/customer_list"
require "helio/participant"

module Helio
  DEFAULT_CA_BUNDLE_PATH = File.dirname(__FILE__) + "/data/ca-certificates.crt"

  @app_info = nil

  @api_base = "https://helio.zurb.com/api/public"

  @log_level = nil
  @logger = nil

  @max_network_retries = 0
  @max_network_retry_delay = 2
  @initial_network_retry_delay = 0.5

  @ca_bundle_path = DEFAULT_CA_BUNDLE_PATH
  @ca_store = nil
  @verify_ssl_certs = true

  @open_timeout = 30
  @read_timeout = 80

  class << self
    attr_accessor :api_id, :api_token, :api_base, :verify_ssl_certs, :api_version, :client_id,
                  :open_timeout, :read_timeout

    attr_reader :max_network_retry_delay, :initial_network_retry_delay
  end

  # Gets the application for a plugin that's identified some. See
  # #set_app_info.
  def self.app_info
    @app_info
  end

  def self.app_info=(info)
    @app_info = info
  end

  # The location of a file containing a bundle of CA certificates. By default
  # the library will use an included bundle that can successfully validate
  # Helio certificates.
  def self.ca_bundle_path
    @ca_bundle_path
  end

  def self.ca_bundle_path=(path)
    @ca_bundle_path = path

    # empty this field so a new store is initialized
    @ca_store = nil
  end

  # A certificate store initialized from the the bundle in #ca_bundle_path and
  # which is used to validate TLS on every request.
  #
  # This was added to the give the gem "pseudo thread safety" in that it seems
  # when initiating many parallel requests marshaling the certificate store is
  # the most likely point of failure (see issue #382). Any program attempting
  # to leverage this pseudo safety should make a call to this method (i.e.
  # `Helio.ca_store`) in their initialization code because it marshals lazily
  # and is itself not thread safe.
  def self.ca_store
    @ca_store ||= begin
      store = OpenSSL::X509::Store.new
      store.add_file(ca_bundle_path)
      store
    end
  end

  # map to the same values as the standard library's logger
  LEVEL_DEBUG = Logger::DEBUG
  LEVEL_ERROR = Logger::ERROR
  LEVEL_INFO = Logger::INFO

  # When set prompts the library to log some extra information to $stdout and
  # $stderr about what it's doing. For example, it'll produce information about
  # requests, responses, and errors that are received. Valid log levels are
  # `debug` and `info`, with `debug` being a little more verbose in places.
  #
  # Use of this configuration is only useful when `.logger` is _not_ set. When
  # it is, the decision what levels to print is entirely deferred to the logger.
  def self.log_level
    @log_level
  end

  def self.log_level=(val)
    # Backwards compatibility for values that we briefly allowed
    if val == "debug"
      val = LEVEL_DEBUG
    elsif val == "info"
      val = LEVEL_INFO
    end

    if !val.nil? && ![LEVEL_DEBUG, LEVEL_ERROR, LEVEL_INFO].include?(val)
      raise ArgumentError, "log_level should only be set to `nil`, `debug` or `info`"
    end
    @log_level = val
  end

  # Sets a logger to which logging output will be sent. The logger should
  # support the same interface as the `Logger` class that's part of Ruby's
  # standard library (hint, anything in `Rails.logger` will likely be
  # suitable).
  #
  # If `.logger` is set, the value of `.log_level` is ignored. The decision on
  # what levels to print is entirely deferred to the logger.
  def self.logger
    @logger
  end

  def self.logger=(val)
    @logger = val
  end

  def self.max_network_retries
    @max_network_retries
  end

  def self.max_network_retries=(val)
    @max_network_retries = val.to_i
  end

  # Sets some basic information about the running application that's sent along
  # with API requests. Useful for plugin authors to identify their plugin when
  # communicating with Helio.
  #
  # Takes a name and optional version and plugin URL.
  def self.set_app_info(name, version: nil, url: nil)
    @app_info = {
      name: name,
      url: url,
      version: version,
    }
  end

  # DEPRECATED. Use `Util#encode_parameters` instead.
  def self.uri_encode(params)
    Util.encode_parameters(params)
  end
  private_class_method :uri_encode
  class << self
    extend Gem::Deprecate
    deprecate :uri_encode, "Helio::Util#encode_parameters", 2016, 1
  end
end

Helio.log_level = ENV["HELIO_LOG"] unless ENV["HELIO_LOG"].nil?
