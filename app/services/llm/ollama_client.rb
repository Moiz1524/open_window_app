require "net/http"

module LLm
  class Error < StandardError; end

  class OllamaClient
    attr_accessor :model, :uri

    def initialize
      host = "http://localhost:11434"
      
      @uri = URI.join(host, "/api/chat")
      @model = "qwen2.5:7b"
    end

    def chat(messages:, tools: [])
      payload = { model:, messages:, stream: false }
      payload[:tools] = tools if tools.any?

      normalize(post(payload))
    end

    private

    def post(payload)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 180

      request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      request.body = payload.to_json

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Ollama returned #{response.code}: #{response.body}"
      end

      JSON.parse(response.body)
    rescue Errno::ECONNREFUSED
      raise Error, "Cannot reach Ollama at #{uri.host}:#{uri.port} - is the server running (brew services start ollama)"
    end

    def normalize(raw)
      message = raw.fetch("message")

      calls = Array(message["tool_calls"]).map do |tc|
        fn = tc.fetch("function")
        ToolCall.new(name: fn.fetch("name"), arguments: fn.fetch("arguments"))
      end

      Response.new(content: message["content"].to_s, tool_calls: calls)
    end    
  end
end