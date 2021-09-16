# frozen_string_literal: true

module ClickHouse
  class Connection
    include Extend::ConnectionHealthy
    include Extend::ConnectionDatabase
    include Extend::ConnectionTable
    include Extend::ConnectionSelective
    include Extend::ConnectionInserting
    include Extend::ConnectionAltering
    include Extend::ConnectionExplaining

    attr_reader :config

    # @param [Config]
    def initialize(config)
      @config = config
    end

    def execute(query, body = nil, database: config.database)
      post(body, query: { query: query }, database: database)
    end

    # @param path [String] Clickhouse HTTP endpoint, e.g. /ping, /replica_status
    # @param body [String] SQL to run
    # @param database [String, NilClass] database to use, nil to skip
    # @param query [Hash] other CH settings to send through params, e.g. max_rows_to_read=1
    # @example get(body: 'select number from system.numbers limit 100', query: { max_rows_to_read: 10 })
    # @return [Faraday::Response]
    def get(path = '/', body: '', query: {}, database: config.database)
      # backward compatibility since
      # https://github.com/shlima/click_house/pull/12/files#diff-9c6f3f06d3b575731eae4b6b95ddbcdcc20452c432b8f6e87a3a8e8645818107R24
      if query.is_a?(String)
        query = { query: query }
        config.logger!.warn('since v1.4.0 use connection.get(body: "SELECT 1") instead of connection.get(query: "SELECT 1")')
      end

      transport.get(path) do |conn|
        conn.params = { database: database }.merge(query).compact
        conn.params[:query] = '' unless query.empty?
        conn.body = body
      end
    end

    def post(body = nil, query: {}, database: config.database)
      transport.post(compose('/', query.merge(database: database)), body)
    end

    def transport
      @transport ||= Faraday.new(config.url!) do |conn|
        conn.options.timeout = config.timeout
        conn.options.open_timeout = config.open_timeout
        conn.headers = config.headers
        conn.ssl.verify = config.ssl_verify
        conn.request :basic_auth, config.username, config.password if config.auth?
        conn.response Middleware::Logging, logger: config.logger!
        conn.response Middleware::RaiseError
        conn.response :json, content_type: %r{application/json}
        conn.response Middleware::ParseCsv, content_type: %r{text/csv}
        conn.adapter config.adapter
      end
    end

    def compose(path, query = {})
      # without <query.compact> "DB::Exception: Empty query" error will occur
      "#{path}?#{URI.encode_www_form(query.compact)}"
    end
  end
end
