lib = require 'lib'

widget = {
  plugin = 'pipe',
  opts = {
    args = {'bspc', 'subscribe', 'report'},
  },
  cb = function(t)
    return lib.pager(t, 'R')
  end,
  event = function(t)
    lib.spawn(t)
  end,
}
