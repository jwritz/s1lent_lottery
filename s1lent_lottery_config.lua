--VERSION: 1.0.4
--GITHUB: https://github.com/jwritz/s1lent_lottery
Config = {}
Config.Locale = 'en'

Config.Blips = {
	{title = "Lottery", color = 69, id = 587, x = 877.38, y = -132.59, z = 78.73}
}

Config.MarkerZones = {
	{markerType = 29, x = 877.38, y = -132.59, z = 78.73, zoneSize = {x = 2.0, y = 2.0, z = 2.0} , color = {r = 21, g = 214, b = 34}}
}

Config.DrawDistance = 200.0

Config.VerifyDrawings = true --(Recommended to be true, otherwise it may crash) Verifies that lottery listings in config are correct (may take slightly longer to initialize)

Config.DefaultRange = {1, 69}
Config.DefaultNumNumbers = 5

Config.WeeklyDBTime = 1 -- Amount of time (weeks) weekly (ex: frequency = "mon") drawings stay in database and able to be cashed in by players (Higher numbers increase db storage usage)
Config.DailyDBTime = 7 -- Amount of time (days) weekly (ex: frequency = "mon") drawings stay in database and able to be cashed in by players (Higher numbers increase db storage usage)

Config.LotteryPrizes = {
	[1] = {5, 10, 25, 35, 100}, -- (DEFAULT) Percent of prize per matched num (ex: 1 match = 5% of prize value, 4 matches = 35%) There MUST be same numbers of percentages as there are number of numbers
	[2] = {25, 100},
	[3] = {0, 5, 10, 30, 100}
}

Config.lotteries = {--See GitHub Wiki for more information on creating lotteries
	{name = "Daily Lotto", uniqueID ="daily_lotto" , frequency = "daily", drawTimeHr = 12, drawTimeMin = 00, ticketCost = 10, prize = "amt", value = 100, range = {0, 10}, numNumbers = 2, prizePercents = 2},
	{name = "Monday Lotto", uniqueID ="monday_lotto" , frequency = "mon", drawTimeHr = 18, drawTimeMin = 00, ticketCost = 100, prize = "amt", value = 1500, prizePercents = 1}, 
	{name = "Friday Lotto", uniqueID ="friday_lotto" , frequency = "fri", drawTimeHr = 18, drawTimeMin = 00, ticketCost = 100, prize = "amt", value = 1500, prizePercents = 1},
	{name = "Wednesday Pool Lotto", uniqueID ="wednesday_pool_lotto" , frequency = "wed", drawTimeHr = 14, drawTimeMin = 00, ticketCost = 100, prize = "pool", value = 100, startValue = 500, range = {0, 50}, prizePercents = 3}
}
