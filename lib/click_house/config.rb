# frozen_string_literal: true

module ClickHouse
  class Config
    DEFAULTS = {
      adapter: Faraday.default_adapter,
      adapter_options: [],
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
      read_timeout: nil,
      ssl_verify: false,
      headers: {},
      global_params: {},
      json_parser: ClickHouse::Middleware::ParseJson,
      json_serializer: ClickHouse::Serializer::JsonSerializer,
      oj_dump_options: {
        mode: :compat # to be able to dump improper JSON like {1 => 2}
      },
      oj_load_options: {
        mode: :custom,
        allow_blank: true,
        bigdecimal_as_decimal: false, # dump BigDecimal as a String
        bigdecimal_load: :bigdecimal, # convert all decimal numbers to BigDecimal
      },
      json_load_options: {
        decimal_class: BigDecimal,
      },
      # should be after json load options
      symbolize_keys: false,
    }.freeze

    attr_accessor :adapter
    attr_accessor :adapter_options
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
    attr_accessor :read_timeout
    attr_accessor :ssl_verify
    attr_accessor :headers
    attr_accessor :global_params
    attr_accessor :oj_load_options
    attr_accessor :json_load_options
    attr_accessor :json_parser # response middleware
    attr_accessor :oj_dump_options
    attr_accessor :json_serializer # [ClickHouse::Serializer::Base]
    attr_accessor :symbolize_keys # [NilClass, Boolean]

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

    # @param klass [ClickHouse::Serializer::Base]
    def json_serializer=(klass)
      @json_serializer = klass.new(self)
    end

    def symbolize_keys=(value)
      bool = value ? true : false

      # merge to be able to clone a config
      # prevent overriding default values
      self.oj_load_options = oj_load_options.merge(symbol_keys: bool)
      self.json_load_options = json_load_options.merge(symbolize_names: bool)
      @symbolize_keys = bool
    end

    # @param name [Symbol, String]
    def key(name)
      symbolize_keys ? name.to_sym : name.to_s
    end
  end
end
