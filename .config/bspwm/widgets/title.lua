utf8 = require 'utf8'
lib = require 'lib'

widget = {
  plugin = 'xtitle',
  cb = function(t)
    t = t or ''
    t = (utf8.len(t) < 100 and t) or utf8.sub(t, 1, 100) .. '...'
    t = luastatus.barlib.escape(t)
    return ('%%{c}%s%%{r}'):format(
      t:match('[^%s]') and lib.colorize((' %s '):format(t), 'title') or ''
    )
  end,
}
