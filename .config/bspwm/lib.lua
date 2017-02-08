local lib = {}

local colors = {
  M = {fg = '#000', bg = '#00bfff'},
  m = {fg = '#00bfff', bg = '#aa000000'},
  O = {fg = '#fff', bg = '#104e8b', u = '#00bfff'},
  o = {fg = '#fdf6e3', bg = '#aa000000', u = '#aaa'},
  F = {fg = '#777', bg = '#104e8b', u = '#00bfff'},
  f = {fg = '#777', bg = '#aa000000', u = '#aaa'},
  U = {fg = '#fff', bg = '#aa104e8b', u = '#00bfff'},
  u = {fg = '#00bfff', bg = '#aa000000', u = '#00bfff'},
  L = {fg = '#aaa', bg = '#aa000000'},
  lang1 = {u = '#fa5000'},
  lang2 = {u = '#fffa00'},
  clock = {fg = '#fff', u = '#00bfff'},
  title = {fg = '#fff', u = '#fa5000'},
  icons = {fg = '#aaa'},
  err = {fg = '#333', bg = '#ff0000'},
}

function lib.colorize(text, key)
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
  for chunk in status:gmatch('[W|:]([mM].-:L%w)') do
    if chunk:match('^[mM]' .. screen) then
      local text = ''
      for block in chunk:gmatch('[^:]+') do
        local key, val = block:sub(1,1), block:sub(2)
        if key == 'L' then
          val = val == 'T' and '' or ''
        end
        val = lib.colorize(' ' .. val .. ' ', key)
        val = key:match('[OoFfUu]') and
          string.format(
            '%%{A:bspc desktop -f %s:}%s%%{A}',
            block:sub(2),
            val
          ) or val
        text = text .. val
      end
      return text
    end
  end
end

return lib
