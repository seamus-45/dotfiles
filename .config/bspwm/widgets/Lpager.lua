lib = require 'lib'

widget = {
  plugin = 'pipe',
  opts = {
    args = {'bspc', 'subscribe', 'report'},
  },
  cb = function(t)
    return lib.pager(t, 'L')
  end,
  event = function(t)
    lib.spawn(t)
  end,
}
