lib = require 'lib'

widget = {
  plugin = 'xkb',
  cb = function(t)
    local text = string.format(
      ' %s %s ',
      lib.colorize('', 'icons'),
      ({['us'] = 'En', ['ru'] = 'Ru'})[t.name] or '??'
    )
    return lib.colorize(
      text,
      ({['us'] = 'lang1', ['ru'] = 'lang2'})[t.name] or 'err'
    )
  end,
}
