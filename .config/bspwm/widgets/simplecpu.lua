lib = require 'lib'

fd = io.open('/proc/stat', 'r')

last_idle, last_total = 0, 0

function sum(list)
  local sum = 0
  for i = 1, #list do
    sum = sum + list[i]
  end
  return sum
end

function load_avg()
  local stats = {}
  fd:seek('set', 0)
  fd:flush()
  local line = fd:read()
  for stat in line:gmatch('[^%s%a]+') do
    stats[#stats + 1] = stat
  end

  local idle, total = stats[4], sum(stats)
  local idle_delta, total_delta = idle - last_idle, total - last_total
  last_idle, last_total = idle, total
  
  return 100 * (1.0 - idle_delta / total_delta) + 0.5
end

function draw_bar()
  local avg = load_avg()
  usage = math.floor((avg / 5) + 0.5)
  free = math.floor(((100 - avg) / 5) + 0.5)
  return string.rep('%{F#fff}', usage) .. string.rep('%{F#555}', free)
end

widget = {
  plugin = 'timer',
  opts = {period = 1},
  cb = function(t) 
    return ('%%{+u}%%{U#555} %s %s %%{-u}'):format(lib.colorize('', 'icons'), draw_bar())
  end
}
