local module = {}

function module:DaylightSavings(Date)
	if (Date["month"] > 3 and Date["month"] < 11) or ((Date["month"] == 3 and Date["day"] >= 8) and (Date["wday"] == 0 or Date["day"] >= 14)) or ((Date["month"] == 11 and Date["day"] < 7 and Date["wday"] > 0)) then
		return true
	else
		return false
	end
end

function module:GetTime(Operation: string, Seconds: booelan, Period: boolean)
	local UTCSeconds = os.time()
	local SecondsInHour = 3600
	local ESTSeconds = UTCSeconds - (SecondsInHour * 4)
	local ESTDate = os.date("!*t", ESTSeconds)
	local HourString = tostring(ESTDate.hour > 13 and ESTDate.hour % 13 or ESTDate.hour)
	local MinuteString = ESTDate.min < 10 and "0"..ESTDate.min or tostring(ESTDate.min)
	local SecondString = ESTDate.sec < 10 and ESTDate.sec.."0" or tostring(ESTDate.sec) % 60
	local TimePeriod = ESTDate.hour > 11 and "PM" or "AM"
	
	if HourString == "0" then
		HourString = "12"
	end
	
	if self:DaylightSavings(ESTDate) then
		if HourString == 11 and TimePeriod == "AM" then
			HourString = 12
			TimePeriod = "PM"
		elseif HourString == 11 and TimePeriod == "PM" then
			HourString = 12
			TimePeriod = "AM"
		else
			HourString += 1
		end
	end
	
	if not Seconds then
		SecondString = ""
	end
	
	if not Period then
		TimePeriod = ""
	else
		TimePeriod = " " .. TimePeriod
	end
	
	if Operation == "Hour" then
		return HourString
	elseif Operation == "Period" then
		return TimePeriod
	elseif Operation == "Time" then
		return HourString .. ":" .. MinuteString .. ":" .. SecondString .. TimePeriod
	end
end

function module:GetDate()
	local UTCSeconds = os.time()
	local SecondsInHour = 3600
	local ESTSeconds = UTCSeconds - (SecondsInHour * 4)
	local ESTDate = os.date("!*t", ESTSeconds)
	local Formatted = string.format("%02d/%02d/%02d", ESTDate.month, ESTDate.day, ESTDate.year%100)
	
	return Formatted
end

return module
