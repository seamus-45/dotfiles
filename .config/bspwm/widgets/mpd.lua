utf8 = require 'utf8'
lib = require 'lib'

text, time, total, is_playing = nil, nil, nil, false
timeout = 5

widget = {
  plugin = 'mpd',
  opts = {
    hostname = os.getenv('HOME') .. '/.mpd/socket',
    timeout = timeout,
    events = {'player', 'mixer', 'options'}
  },
  cb = function(t)
    if t.what == 'update' then
      -- build title
      local title = string.format('%s: %s', t.song.Artist, t.song.Title)
      title = (utf8.len(title) <= 39 and title) or utf8.sub(title, 1, 39) .. '…'

      -- draw icons
      text = string.format(' %s %s %s%s%s',
        ({play = '', pause = '', stop = ''})[t.status.state],
        title,
        ({'', ''})[t.status.random + 1],
        ({'', ''})[t.status['repeat'] + 1],
        ({'', ''})[t.status.single + 1]
      )

      -- update other globals
      if t.status.time then
        time, total = t.status.time:match('([0-9]+):([0-9]+)')
        time, total = tonumber(time), tonumber(total)
      else
        time, total = nil, nil
      end
      is_playing = t.status.state == 'play'

    elseif t.what == 'timeout' then
      if is_playing then
        time = math.min(time + timeout, total)
      end

    else
      -- 'connecting' or 'error'
      return t.what
    end

    -- calc progress
    local len = utf8.len(text)
    -- 'time' and 'total' can be nil here, we check for 'total' only
    local ulpos = (total and total ~= 0) and math.floor(len / total * time + 0.5) or len

    -- apply styles
    local res = utf8.sub(text, 1, ulpos) .. '%{U#7c9800}' .. utf8.sub(text, ulpos+1)
    for _, key in ipairs({'','',''}) do
      res = res:gsub(key, key .. '%%{F#ccc}')
    end
    for _, key in ipairs({'','',''}) do
      res = res:gsub(key, '%%{F#ff7f00}' .. key)
    end
    return '%{+u}%{U#afd700}%{F#afd700}' .. res .. '%{F-}%{-u}'
  end
}
