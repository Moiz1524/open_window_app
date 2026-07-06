module Llm
  # One tool invocation requested by the model, e.g.
  # name: "invite_user", arguments: { "email" => "abc@example.co" }
  ToolCall = Data.define(:name, :arguments)

  # A normalized reply from any LLM provider: either text,
  # tool calls, or (rarely) both.
  Response = Data.define(:content, :tool_calls) do
    def tool_calls?
      tool_calls.any?
    end
  end
end