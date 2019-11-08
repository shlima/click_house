# frozen_string_literal: true

module ClickHouse
  class Config
    DEFAULT_SCHEME = 'http'
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = '8123'

    DEFAULTS = {
      url: nil,
      scheme: 'http',
      host: 'localhost',
      port: '8123',
      logger: nil,
      database: nil,
      username: nil,
      password: nil
    }.freeze

    attr_accessor :logger
    attr_accessor :scheme
    attr_accessor :host
    attr_accessor :port
    attr_accessor :database
    attr_accessor :url
    attr_accessor :username
    attr_accessor :password

    def initialize(params = {})
      DEFAULTS.merge(params).each { |k, v| public_send("#{k}=", v) }
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
