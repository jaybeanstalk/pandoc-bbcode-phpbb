-- panspigotmc - SpigotMC BBCode writer for pandoc
-- Originally written by Jens Oliver John, adapted for SpigotMC by Minecrell.
-- Original copyright:
-- Copyright (C) 2014 Jens Oliver John < dev ! 2ion ! de >
-- Licensed under the GNU General Public License v3 or later.
-- Written for Lua 5.{1,2}

local function enclose(t, s, p)
  if p then
    return string.format("[%s=%s]%s[/%s]", t, p, s, t)
  else
    return string.format("[%s]%s[/%s]", t, s, t)
  end
end

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
function Doc(body, metadata, variables)
  local buf = {}
  local function _(e)
    table.insert(buf, e)
  end
  if metadata['title'] and metadata['title'] ~= "" then
    _(metadata['title'])
  end
  _(body)
  if #notes > 0 then
    _("--")
    for i,n in ipairs(notes) do
      _(string.format("[%d] %s", i, n))
    end
  end
  return table.concat(buf, '\n')
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Plain(s)
  return s
end

function CaptionedImage(src, tit, txt)
  return LineBreak() .. enclose('center', enclose('img', src))
end

function Para(s)
  return s
end

function RawBlock(s)
    return RawInline(s)
end

function HorizontalRule()
  return '---'
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  return '\n' .. enclose('size', s, 7 - lev)  .. '\n'
end

function CodeBlock(s, attr)
  return enclose('code', s, attr.class)
end

function BlockQuote(s)
  local a, t = s:match('@([%w]+): (.+)')
  if a then
    return enclose('quote', t or "Unknown" , a)
  else
    return enclose('quote', s)
  end
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buf = {}
  for _,r in ipairs(rows) do
    local rbuf = ""
    for i,c in ipairs(r) do
      if i~=#r then
        rbuf = rbuf .. c .. '@'
      else
        rbuf = rbuf .. c
      end
    end
    table.insert(buf, rbuf)
  end
  local cin = table.concat(buf, '\n')
  return enclose('code', column(cin))
end

local function makelist(items, ltype)
  local buf = string.format("[list=%s]", ltype)
  for _,e in ipairs(items) do
    buf = buf .. '[*]' .. e .. '\n'
  end
  buf = buf .. '[/list]'
  return buf
end

function BulletList(items)
  return makelist(items, '*')
end

function OrderedList(items)
  return makelist(items, '1')
end

-- Revisit association list STackValue instance.
function DefinitionList(items)
  local buf = ""
  local function mkdef(k,v)
    return string.format("%s: %s\n", enclose('b', k), v)
  end
  for _,e in ipairs(items) do
    for k,v in pairs(items) do
      buf = buf .. mkdef(k,v)
    end
  end
  return buf
end

function Div(s, attr)
  return s
end


-- Blocksep is used to separate block elements.
function Blocksep()
  return LineBreak()
end

function Str(s)
  return s
end

function Space()
  return ' '
end

function Emph(s)
  return enclose('i', s)
end

function Strong(s)
  return enclose('b', s)
end

function Strikeout(s)
  return enclose('s', s)
end

function Subscript(s)
  return string.format("{%s}", s)
end

function Superscript(s)
  return string.format("[%s]", s)
end

function SmallCaps(s)
  return s
end

function SingleQuoted(s)
  return '\'' .. s .. '\''
end

function DoubleQuoted(s)
  return '"' .. s .. '"'
end

function Cite(s)
  return s
end

function Code(s, attr)
  return enclose('font', s, 'Courier New')
end

-- What is this?
function DisplayMath(s)
  return InlineMath(s)
end

function InlineMath(s)
  return Code(s, 'math')
end

function RawInline(s)
  return enclose('plain', s)
end

function LineBreak()
  return '\n'
end

function Link(s, src, tit)
  return enclose('url', s, src)
end

function Image(s, src, tit)
  return enclose('img', src)
end

function Note(s)
  table.insert(notes, s)
  return string.format("[%d]", #notes)
end

function Span(s, attr)
  return s
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)
