# frozen_string_literal: true

module ClickHouse
  class Connection
    include Extend::ConnectionHealthy
    include Extend::ConnectionDatabase
    include Extend::ConnectionTable
    include Extend::ConnectionSelective
    include Extend::ConnectionInserting

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def execute(query, body = nil, database: config.database)
      post(body, query: { query: query }, database: database)
    end

    def get(path = '/', query: {}, database: config.database)
      transport.get(compose(path, query.merge(database: database)))
    end

    def post(body = nil, query: {}, database: config.database)
      transport.post(compose('/', query.merge(database: database)), body)
    end

    def transport
      @transport ||= Faraday.new(config.url!) do |conn|
        conn.options.timeout = config.timeout
        conn.options.open_timeout = config.open_timeout
        conn.ssl.verify = config.ssl_verify
        conn.basic_auth(config.username, config.password) if config.auth?
        conn.response Middleware::Logging, logger: config.logger!
        conn.response Middleware::RaiseError
        conn.response :json, content_type: %r{application/json}
        conn.response Middleware::ParseCsv, content_type: %r{text/csv}
        conn.adapter config.adapter
      end
    end

    def compose(path, query = {})
      # without <query.compact> "DB::Exception: Empty query" error will occur
      "#{path}?#{URI.encode_www_form({ send_progress_in_http_headers: 1 }.merge(query).compact)}"
    end
  end
end
