-- Renders Obsidian-flavoured markdown that pandoc does not understand natively:
-- callout blocks (> [!warning] Title) and ==highlight== spans.

local callout_names = {
  note = "Note",
  abstract = "Abstract",
  summary = "Summary",
  tldr = "TL;DR",
  info = "Info",
  todo = "To do",
  tip = "Tip",
  hint = "Hint",
  important = "Important",
  success = "Success",
  check = "Check",
  done = "Done",
  question = "Question",
  help = "Help",
  faq = "FAQ",
  warning = "Warning",
  caution = "Caution",
  attention = "Attention",
  failure = "Failure",
  fail = "Fail",
  missing = "Missing",
  danger = "Danger",
  error = "Error",
  bug = "Bug",
  example = "Example",
  quote = "Quote",
  cite = "Cite",
}

local function split_first_line(inlines)
  local head, tail, seen_break = {}, {}, false
  for _, inline in ipairs(inlines) do
    if not seen_break and inline.t == "SoftBreak" then
      seen_break = true
    elseif seen_break then
      table.insert(tail, inline)
    else
      table.insert(head, inline)
    end
  end
  return head, tail
end

local function strip_leading_space(inlines)
  while #inlines > 0 and inlines[1].t == "Space" do
    table.remove(inlines, 1)
  end
  return inlines
end

function BlockQuote(quote)
  local first = quote.content[1]
  if not first or first.t ~= "Para" then return nil end

  local marker = first.content[1]
  if not marker or marker.t ~= "Str" then return nil end

  local kind = marker.text:match("^%[!([%w%-]+)%][+-]?$")
  if not kind then return nil end

  local rest = {}
  for i = 2, #first.content do table.insert(rest, first.content[i]) end

  local title, body = split_first_line(rest)
  title = strip_leading_space(title)

  local label = callout_names[kind:lower()] or kind:gsub("^%l", string.upper)
  local heading = { pandoc.Str(label) }
  if #title > 0 then
    table.insert(heading, pandoc.Str(" \u{2014} "))
    for _, inline in ipairs(title) do table.insert(heading, inline) end
  end

  local blocks = { pandoc.Para({ pandoc.Strong(heading) }) }
  if #body > 0 then table.insert(blocks, pandoc.Para(body)) end
  for i = 2, #quote.content do table.insert(blocks, quote.content[i]) end

  return pandoc.BlockQuote(blocks)
end

function Underline(elem) return elem end

function Span(span)
  if span.classes:includes("mark") and FORMAT:match("latex") then
    local out = { pandoc.RawInline("latex", "\\colorbox{yellow!35}{") }
    for _, inline in ipairs(span.content) do table.insert(out, inline) end
    table.insert(out, pandoc.RawInline("latex", "}"))
    return out
  end
end
