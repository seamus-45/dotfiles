lib = require 'lib'

fd = io.open('/proc/stat', 'r')

stats = {}

function sum(list, range)
  local result = 0
  for i = 1, range do
    result = result + list[i]
  end
  return result
end

function draw_bar(data, data_old)
  -- data ( user, nice, system, idle, ... )
  -- usage = 100 * delta_total - delta_idle / delta_total
  local total = sum(data, #data)
  local unsi = sum(data, 4)
  local total_old = sum(data_old, #data_old)
  local unsi_old = sum(data_old, 4)
  local delta_total = total - total_old
  local delta_unsi = unsi - unsi_old
  U = 100 * ((delta_total - delta_unsi + data[1] - data_old[1]) / delta_total)
  N = 100 * ((delta_total - delta_unsi + data[2] - data_old[2]) / delta_total)
  S = 100 * ((delta_total - delta_unsi + data[3] - data_old[3]) / delta_total)
  U, N, S = math.floor(U + 0.5), math.floor(N + 0.5), math.floor(S + 0.5)
  local text = ''
  local colors = {'#1e90ff', '#0f0', '#f00', '#777'}
  for k, v in ipairs({N, U, S}) do
    for i = 1, (v + 2.5) / 5 do
      text = i == 1 and ('%s%%{F%s}'):format(text, colors[k]) or text
      text = text .. ''
    end
  end
  _, count = text:gsub('', '')
  for i = 1, (100 / 5 - count) do
    text = i == 1 and ('%s%%{F%s}'):format(text, colors[4]) or text
    text = text .. ''
  end
  return text
end

function load_avg(cores)
  fd:seek('set', 0)
  local nowstats = {}
  for line in fd:lines() do
    local k, v = line:match('(cpu%d?)%s+(.*)')
    if k then
      nowstats[k] = {}
      for stat in v:gmatch('[^%s]+') do
        nowstats[k][#nowstats[k] + 1] = stat
      end
    end
  end

  local text = ''
  if stats['cpu'] then
    if type(cores) == 'table' and #cores > 0 then
      for i = 1, #cores do
        sep = i > 1 and ' ' or ''
        text = text .. sep ..draw_bar(nowstats['cpu' .. cores[i]], stats['cpu' .. cores[i]])
      end
    else
      text = text .. draw_bar(nowstats['cpu'], stats['cpu'])
    end
  end

  stats = nowstats
  return text
end

widget = {
  plugin = 'timer',
  opts = {period = 1},
  cb = function(t) 
    return (' %s %s '):format(lib.colorize('', 'icons'), load_avg({0, 1}))
  end
}
