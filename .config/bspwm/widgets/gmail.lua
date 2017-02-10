imap4 = require 'imap4'
lib = require 'lib'

widget = {
  plugin = 'timer',
  opts = {period = 180},
  cb = function(t)
    unseen = lib.unseen('gmail')
    return lib.colorize(
      string.format(' %s %d ',
        (unseen == 0 and '') or '',
        unseen
      ),
      (unseen == 0 and 'mail') or 'mail_unseen'
    )
  end,
}
