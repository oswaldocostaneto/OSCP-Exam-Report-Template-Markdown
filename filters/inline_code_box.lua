local function latex_escape(text)
  local escaped = text
  -- Protect backslashes first, then escape special chars, then restore.
  -- This avoids turning \textbackslash{} into \textbackslash\{\}.
  local backslash_token = "PANDOCBACKSLASHTOKEN"
  escaped = escaped:gsub("\\", backslash_token)
  escaped = escaped:gsub("([#%%&%${}_])", "\\%1")
  escaped = escaped:gsub("%^", "\\textasciicircum{}")
  escaped = escaped:gsub("~", "\\textasciitilde{}")
  escaped = escaped:gsub(backslash_token, "\\textbackslash{}")
  return escaped
end

local function latex_url_escape(text)
  local escaped = text
  escaped = escaped:gsub("\\", "\\textbackslash{}")
  escaped = escaped:gsub("([%%#{}])", "\\%1")
  return escaped
end

function Code(el)
  local raw = pandoc.utils.stringify(el)
  return pandoc.RawInline("latex", "\\inlinecode{" .. latex_escape(raw) .. "}")
end

function Str(el)
  -- Convert plain URLs to \url{...} so long links wrap within margins.
  if el.text:match("^https?://") or el.text:match("^www%.") then
    return pandoc.RawInline("latex", "\\url{" .. latex_url_escape(el.text) .. "}")
  end

  -- Plain text that contains backslashes (e.g. NT AUTHORITY\SYSTEM)
  -- must be escaped for LaTeX.
  if el.text:find("\\", 1, true) then
    return pandoc.RawInline("latex", latex_escape(el.text))
  end
end
