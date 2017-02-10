lib = require 'lib'

widget = {
  plugin = 'mpd',
  opts = {
    hostname = '/home/fedotov_sv/.mpd/socket',
  },
  cb = function(t) 
    if t.what == 'update' then
      return string.format(
        '%%{+u}%%{U#afd700}%%{F#afd700} %s %%{F#aea9b1}%s - %s %%{F#ff7f00}%s%s%s%%{F-}%%{U-}%%{-u}',
        ({play = '', pause = '', stop = ''})[t.status.state],
        t.song.Artist,
        t.song.Title,
        t.status.random == '1' and ' ' or '',
        t.status['repeat'] == '1' and ' ' or '',
        t.status.single == '1' and ' ' or ''
      )
    end
  end
}
