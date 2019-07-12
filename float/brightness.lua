-----------------------------------------------------------------------------------------------------------------------
--                                        RedFlat brightness control widget                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Brightness control using xbacklight
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local string = string
local awful = require("awful")
local beautiful = require("beautiful")

local rednotify = require("redflat.float.notify")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local brightness = { dbus_correction = 1 }

local defaults = { down = false, step = 2 }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		notify = {},
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.brightness") or {})
end

-- Change brightness level
-----------------------------------------------------------------------------------------------------------------------

-- Change with xbacklight
------------------------------------------------------------
function brightness:change_with_xbacklight(args)
	args = redutil.table.merge(defaults, args or {})

	local command = string.format("xbacklight %s %d", args.down and "-dec" or "-inc", args.step)
	awful.spawn.easy_async(command, self.info_with_xbacklight)
end

--Change with brightnessctl
function brightness:chande_with_brightnessctl(args)

	if args.down then
		awful.spawn.easy_async("brightnessctl set " .. args.step .. "-", self.info_with_brightnessctl)
	else
		awful.spawn.easy_async("brightnessctl set +" .. args.step, self.info_with_brightnessctl)
	end
end

-- Update brightness level info
-----------------------------------------------------------------------------------------------------------------------

-- Update from xbacklight
------------------------------------------------------------
function brightness.info_with_xbacklight()
	if not brightness.style then brightness.style = default_style() end
	awful.spawn.easy_async(
		"xbacklight -get",
		function(output)
			rednotify:show(redutil.table.merge(
				{ value = output / 100, text = string.format('%.0f', output) .. "%" },
				brightness.style.notify
			))
		end
	)
end

-- Update from brightnessctl
------------------------------------------------------------
function brightness.info_with_brightnessctl()
	if not brightness.style then brightness.style = default_style() end
	local max_brightness_level = redutil.read.output("brightnessctl max")
	local brightness_level = (redutil.read.output("brightnessctl get") / max_brightness_level) * 100

	rednotify:show(redutil.table.merge(
			{ value = brightness_level / 100, text = string.format('%.0f', brightness_level) .. "%" },
			brightness.style.notify
	))
end

-----------------------------------------------------------------------------------------------------------------------
return brightness
