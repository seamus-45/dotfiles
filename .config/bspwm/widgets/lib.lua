local lib = {}

local colors = {
  default = {fg = '#333', bg = '#f00'},
  err = {fg = '#333', bg = '#f00'},
  clock = {fg = '#fff', u = '#00bfff'},
  icons = {fg = '#aaa'},
  lang1 = {u = '#f00'},
  lang2 = {u = '#00cd00'},
  title = {fg = '#fff', u = '#9400d3'},
  mail = {fg = '#777', u = '#20b2aa'},
  mail_unseen = {fg = '#fff', u = '#20b2aa'},
  M = {fg = '#000', bg = '#00bfff'},
  m = {fg = '#00bfff', bg = '#99000000'},
  O = {fg = '#fff', bg = '#104e8b', u = '#00bfff'},
  o = {fg = '#fdf6e3', bg = '#99000000', u = '#005a70'},
  F = {fg = '#777', bg = '#104e8b', u = '#00bfff'},
  f = {fg = '#777', bg = '#99000000', u = '#005a70'},
  U = {fg = '#fff', bg = '#aa104e8b', u = '#00bfff'},
  u = {fg = '#00bfff', bg = '#99000000', u = '#00bfff'},
  L = {fg = '#00bfff', bg = '#99000000'},
  T = {fg = '#00bfff', bg = '#99000000'},
  G = {fg = '#00bfff', bg = '#99000000'},
}

local glyphs = {
  -- layout
  L = { T = '', -- tiled
        M = '' }, -- monocle
  -- node state
  T = { T = '', -- tiled
        P = '', -- pseudo tiled
        F = '', -- floating
        ['='] = '', -- fullscreen
        ['@'] = '' }, -- ??
  -- flags
  G = { S = '', -- sticky
        P = '', -- private
        L = '' } -- locked
}

function lib.colorize(text, key)
  key = colors[key] and key or 'default'
  text = (colors[key].fg and string.format('%%{F%s}%s%%{F-}', colors[key].fg, text)) or text
  text = (colors[key].bg and string.format('%%{B%s}%s%%{B-}', colors[key].bg, text)) or text
  text = (colors[key].u and string.format('%%{+u}%%{U%s}%s%%{U-}%%{-u}', colors[key].u, text)) or text
  return text
end

function lib.spawn(cmd)
    local args = {}
    for v in cmd:gmatch('[^%s]+') do
      args[#args + 1] = v
    end
    luastatus.spawn(args)
end

function lib.pager(status, screen)
  local current = ''
  local text = ''
  for field in status:sub(2):gmatch('[^:]+') do
    current = field:match('^[mM]') and field:sub(2) or current
    if current == screen then
      local key, val = field:sub(1,1), field:sub(2)
        -- apply styles
        val = key:match('[LTG]') and val:gsub('[%u=@]', function(a) return (' %s'):format(glyphs[key][a]) end) or val
        val = key:match('[^LTG]') and (' %s '):format(val) or val 
        val = val:match('[^%s]') and lib.colorize(('%s'):format(val), key) or ''
        -- bind actions
        val = key:match('[OoFfUu]') and ('%%{A:bspc desktop -f %s:}%s%%{A}'):format(field:sub(2), val) or val
        text = text .. val
    end
  end
  return text .. ' '
end

function lib.unseen(account)
  dofile'/home/fedotov_sv/.credentials.lua'
  if creds[account].ssl then
    connection = imap4(creds[account].hostname, creds[account].port, {protocol = creds[account].ssl})
  else
    connection = imap4(creds[account].hostname, creds[account].port)
  end
  assert(connection:isCapable('IMAP4rev1'))
  connection:login(creds[account].login, creds[account].pass)
  local stat = connection:status('INBOX', {'UNSEEN'})
  return stat.UNSEEN
end

return lib
