# frozen_string_literal: true

module ClickHouse
  class Config
    DEFAULT_SCHEME = 'http'
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = '8123'

    DEFAULTS = {
      adapter: Faraday.default_adapter,
      url: nil,
      scheme: 'http',
      host: 'localhost',
      port: '8123',
      logger: nil,
      database: nil,
      username: nil,
      password: nil,
      timeout: nil,
      open_timeout: nil,
      ssl_verify: false,
      headers: {}
    }.freeze

    attr_accessor :adapter
    attr_accessor :logger
    attr_accessor :scheme
    attr_accessor :host
    attr_accessor :port
    attr_accessor :database
    attr_accessor :url
    attr_accessor :username
    attr_accessor :password
    attr_accessor :timeout
    attr_accessor :open_timeout
    attr_accessor :ssl_verify
    attr_accessor :headers

    def initialize(params = {})
      assign(DEFAULTS.merge(params))
      yield(self) if block_given?
    end

    # @return [self]
    def assign(params = {})
      params.each { |k, v| public_send("#{k}=", v) }

      self
    end

    def auth?
      !username.nil? || !password.nil?
    end

    def logger!
      @logger || Logger.new('/dev/null')
    end

    def url!
      @url || "#{scheme}://#{host}:#{port}"
    end
  end
end
