lib = require 'lib'

widget = {
  plugin = 'pipe',
  opts = {
    args = {'bspc', 'control', '--subscribe'},
  },
  cb = function(t)
    return lib.pager(t, 'L')
  end,
  event = function(t)
    lib.spawn(t)
  end,
}
