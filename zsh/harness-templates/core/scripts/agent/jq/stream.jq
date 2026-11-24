def stream_event: . as $line | ($line | fromjson? | objects) // {type: "raw", text: $line};
def step_target: .file_path // .command // .pattern // .description // .url // .query // "";
def one_line: tostring | split("\n")[0] | .[0:120];
def progress($name):
  stream_event
  | if .type == "assistant" then .message.content[]? | select(.type == "tool_use") | "\($name) › \(.name) \(.input | step_target | one_line)"
    elif .type == "raw" and (.text | length) > 0 then "\($name) › \(.text | one_line)"
    else empty end;
def final_text:
  stream_event
  | if .type == "result" then .result // empty
    elif .type == "raw" then .text
    else empty end;
