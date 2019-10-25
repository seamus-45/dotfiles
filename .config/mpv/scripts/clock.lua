-- Mozbugbox's lua utilities for mpv
-- Copyright (c) 2015-2018 mozbugbox@yahoo.com.au
-- Copyright (c) 2019 sr.fido@gmail.com
-- Licensed under GPL version 3 or later

--[[
Show current time on video
Usage: --script=clock
--]]

local msg = require("mp.msg")

local update_timeout = 1 -- in seconds

-- Class creation function
function class_new(klass)
    -- Simple Object Oriented Class constructor
    local klass = klass or {}
    function klass:new(o)
        local o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end
    return klass
end

-- Show OSD Clock
local OSDClock = class_new()
function OSDClock:_show_clock()
    -- Show wall clock on OSD
    local now = os.date("%H:%M:%S")
		mp.osd_message(string.format('time: %s', now))
end

local osd_clock = OSDClock:new()
osd_clock:_show_clock()
mp.add_periodic_timer(update_timeout, function() osd_clock:_show_clock() end)

