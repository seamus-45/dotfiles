lib = require 'lib'

days = {
  'Воскресенье',
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
}

months = {
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентрября',
  'октября',
  'ноября',
  'декабря',
}

widget = {
  plugin = 'timer',
  opts = {period = 5},
  cb = function(t)
    local d = os.date('*t')
    local text = string.format(
      ' %s %s, %d %s %s %02d:%02d ',
      lib.colorize('', 'icons'),
      days[d.wday],
      d.day,
      months[d.month],
      lib.colorize('', 'icons'),
      d.hour,
      d.min)
    return lib.colorize(text, 'clock')
  end,
}
