# frozen_string_literal: true

module ClickHouse
  class Config
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
      headers: {},
      global_params: {},
      json_parser: ClickHouse::Middleware::ParseJson,
      oj_load_options: {
        mode: :custom,
        allow_blank: true,
        bigdecimal_as_decimal: false, # dump BigDecimal as a String
        bigdecimal_load: :bigdecimal, # convert all decimal numbers to BigDecimal
        empty_string: false,
        second_precision: 6,
        time_format: :ruby,
      },
      json_load_options: {
        decimal_class: BigDecimal,
      },
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
    attr_accessor :global_params
    attr_accessor :oj_load_options
    attr_accessor :json_load_options
    attr_accessor :json_parser # response middleware

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
      @logger || null_logger
    end

    def url!
      @url || "#{scheme}://#{host}:#{port}"
    end

    def null_logger
      @null_logger ||= Logger.new(IO::NULL)
    end
  end
end
