local drawTable = {
	[1] = {}, -- Sunday (sun)
	[2] = {}, -- Monday (mon)
	[3] = {}, -- Tuesday (tue)
	[4] = {}, -- Wednesday (wed)
	[5] = {}, -- Thursday (thur)
	[6] = {}, -- Friday (fri)
	[7] = {}, -- Saturday (sat)
}

local days = {sun = 1, mon = 2, tue = 3, wed = 4, thur = 5, fri = 6, sat = 7, daily = 8}

local readyToStart = false

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- **Server-Side Drawing and Timing** --
function printErrorInvalid(drawNum, reason)
	print("[s1lent_lottery] <VDT01> Lottery Drawing #" .. drawNum .. " is INVALID (" .. reason .. ")")
end

function verifyDrawTime(index, drawTime)
	local reason = ""
	local isValid = true
	local rangeIsValid = true
	--Check name
	if drawTime.name == nil or (not type(drawTime.name) == "string") then
		reason = reason .. "name "
		isValid = false
	end
	--Check frequency
	if drawTable[days[drawTime.frequency]] == nil and days[drawTime.frequency] ~= 8 then --If frequency is invalid, print error
		reason = reason .. "frequency "
		isValid = false
	end
	--Check drawTimeHr
	if drawTime.drawTimeHr == nil or (not type(drawTime.drawTimeHr) == "number") or drawTime.drawTimeHr < 0 or drawTime.drawTimeHr > 23 then
		reason = reason .. "drawTimeHr "
		isValid = false
	end
	--Check drawTimeMin
	if drawTime.drawTimeMin == nil or (not type(drawTime.drawTimeMin) == "number")  or drawTime.drawTimeMin < 0 or drawTime.drawTimeMin > 59 then
		reason = reason .. "drawTimeMin "
		isValid = false
	end
	--Check ticketCost
	if drawTime.ticketCost == nil or (not type(drawTime.ticketCost) == "number") or drawTime.ticketCost < 0 then
		reason = reason .. "ticketCost "
		isValid = false
	end
	--Check prize
	if drawTime.prize == nil or (not type(drawTime.prize) == "string") then
		reason = reason .. "prize "
		isValid = false
	end
	--Check value
	if drawTime.value == nil or (not type(drawTime.value) == "number") or drawTime.value < 0 then
		reason = reason .. "value "
		isValid = false
	end
	--Check range
	if drawTime.range ~= nil then --If range is nil then default range will be used, so it is not an error
		if tonumber(drawTime.range[1]) == nil or tonumber(drawTime.range[2]) == nil or tonumber(drawTime.range[1]) < 0 or tonumber(drawTime.range[2]) < 0 then
			reason = reason .. "range "
			isValid = false
			rangeIsValid = false
		end
	end
	--Check numNumbers
	if drawTime.numNumbers ~= nil then --If range is nil then default range will be used, so it is not an error
		if tonumber(drawTime.numNumbers) == nil or tonumber(drawTime.numNumbers) < 0 then
			reason = reason .. "numNumbers "
			isValid = false
		elseif rangeIsValid and (drawTime.range[2] - drawTime.range[1]) < drawTime.numNumbers  then--FIX to cover default range and numNumbers
			reason = reason .. "range is smaller than numNumbers "
			isValid = false
		end 
	end
	--Check prizePercents FIX
	if (drawTime.prizePercents == nil) or (not type(drawTime.prizePercents) == "number") or (Config.LotteryPrizes[drawTime.prizePercents] == nil) or (not Config.LotteryPrizes[drawTime.prizePercents] == drawTime.numNumbers) then
		reason = reason .. "prizePercents "
		isValid = false
	end
	
	if not isValid then
		printErrorInvalid(index, reason)
	end
	return isValid
end

function sortDraw(drawingOne, drawingTwo) 
	if drawingOne.drawTimeHr < drawingTwo.drawTimeHr then
		return true
	elseif drawingOne.drawTimeHr > drawingTwo.drawTimeHr then
		return false
	else 
		return drawingOne.drawTimeMin < drawingTwo.drawTimeMin
	end
end

function sortDrawings()
	for i = 1, 7, 1 do
		table.sort(drawTable[i], sortDraw)
	end
end

function getTimeDif(curDay, curHr, curMin, drawing, nextDay)

	if curDay == nextDay then --If drawing is during the current day
		if curHr == drawing.drawTimeHr then --If drawing is in the same hr as current, return time until drawing (minutes)
			return drawing.drawTimeMin - curMin
		else --Return time to get to next needed hr
			return (60 * (drawing.drawTimeHr - curHr)) - curMin
		end
	else --If drawing is NOT during the current day, then wait until next hr
		return ((60 * (24 - curHr)) - curMin) + (60 * drawing.drawTimeHr) + drawing.drawTimeMin
	end
end

function loadDrawTimes()
	--Add all lottery draw times to drawTable (verify if enabled)
	for i, drawing in ipairs(Config.lotteries) do
		if Config.VerifyDrawings then
			if verifyDrawTime(i, drawing) then
				if days[drawing.frequency] == 8 then --insert daily drawings into every day
					for i = 1, 7, 1 do
						table.insert(drawTable[i], drawing)
					end
				else
					table.insert(drawTable[days[drawing.frequency]], drawing)
				end
			end
		else
			if days[drawing.frequency] == 8 then --insert daily drawings into every day
				for i = 1, 7, 1 do
					table.insert(drawTable[i], drawing)
				end
			else
				table.insert(drawTable[days[drawing.frequency]], drawing)
			end
		end
	end
end

function getTimeUntilNextDrawing(index, hr, m, lastDraw)
	if lastDraw == -1 then
		lastDraw = 0
	end
	if drawTable[index][lastDraw + 1] == nil then --reached end of drawings for the day
		local i = 1
		if index == 7 then
			index = 0
		end
		while drawTable[index + i][1] == nil do
			Citizen.Wait(0)
			if index + i >= 7 then
				index = 0
				i = 0
			end
			i = i + 1
		end
		return getTimeDif(index, hr, m, drawTable[index + i][1], index + i)
	end

	return getTimeDif(index, hr, m, drawTable[index][lastDraw + 1], index)
end

function checkDrawings(index, hr, m) --index - sun = 1, mon = 2 ... sat = 7
	local lastDraw = -1 --lastDraw tracks index of last drawing that occured
	for i, drawing in ipairs(drawTable[index]) do --Check if there is a drawing at current time, draws if there is
		if drawing.drawTimeHr == hr and drawing.drawTimeMin == m then
			local nums = draw(drawing)

			local nextID, nextDate = getNextDrawingInfo(drawing.uniqueID)
			updateDrawing(drawing.uniqueID, nextID - 1, nums)
			insertDrawing(drawing.uniqueID, nextID, nextDate)
			updateTickets(drawing, nextID - 1, nums)

			if i > lastDraw then
				lastDraw = i
			end
		end
	end
	return lastDraw
end

function updateDrawing(uniqueID, id, numbers)
	MySQL.ready(function()
		MySQL.Async.execute('UPDATE lottery_drawings SET numbers = @numbers WHERE uniqueID = @uniqueID and id = @id', --insert numbers into database
		{
			['@numbers'] = table.concat(numbers, "-"),
			['@uniqueID'] = uniqueID,
			['@id'] = id
		}, function(rowsChanged) end) 
	end)
end

function insertDrawing(uniqueID, id, date)
	MySQL.ready(function()
		MySQL.Async.execute('INSERT INTO lottery_drawings (uniqueID, id, date) VALUES (@uniqueID, @id, @date)', --Create next drawing
		{
			['@uniqueID'] = uniqueID,
			['@id'] = id,
			['@date'] = date,
		}, function(rowsChanged) end)
	end)
end

function calcPrize(nums, prizePercents, pickedNums, prize)
	local pNums = {}
	local i = string.find(pickedNums, "-")
	local x = 1
	while i and i > 0 do
		pNums[x] = tonumber(string.sub(pickedNums, 1, i - 1))
		pickedNums = string.sub(pickedNums, i + 1)
		x = x + 1
		i = string.find(pickedNums, "-")
	end
	pNums[x] = tonumber(pickedNums)

	local matches = 0
	for indexA = 1, #nums, 1 do
		for indexB = 1, #pNums, 1 do
			if nums[indexA] == pNums[indexB] then
				matches = matches + 1
				break
			end
		end
	end

	if matches == 0 then
		return 0
	end
	return math.floor(prize * (prizePercents[matches] / 100))
end

function updateTickets(drawing, drawingID, nums)
	MySQL.ready(function() --foreach drawing in the config, ensure that the next drawing (time) is created so tickets can be purchased
		MySQL.Async.fetchAll('SELECT * FROM lottery_tickets WHERE drawingUniqueID = @drawingUniqueID and drawingID = @drawingID', 
		{	
			['@drawingUniqueID'] = drawing.uniqueID,
			['@drawingID'] = drawingID
		}, 
		function(results)
			local updated = false
			local pickedNums = nil 
			local id = nil
			local prize = 0
			for i = 1, #results, 1 do
				updated = false
				pickedNums = results[i].numbers
				id = results[i].id
				prize = calcPrize(nums, Config.LotteryPrizes[drawing.prizePercents], pickedNums, drawing.value)
				MySQL.Async.execute('UPDATE lottery_tickets SET isDrawn = @isDrawn, prize = @prize WHERE id = @id', 
				{
					['@isDrawn'] = 1,
					['@prize'] = prize,
					['@id'] = id
				}, function(rowsChanged) 
					updated = true
				end) 

				while not updated do
					Citizen.Wait(0)
				end
			end
		end)
	end)
end

function draw(drawing) 
	local nums = {}
	local pNums = {}
	local randNum

	--Get numNumbers (set to default if not set in drawing)
	local numNumbers = drawing.numNumbers
	if not numNumbers then
		numNumbers = Config.DefaultNumNumbers
	end

	--Get range (set to default if not set in drawing)
	local range = drawing.range
	if not range then
		range = Config.DefaultRange
	end
	
	local j = range[1]
	for i = 1, (range[2] - range[1] + 1), 1 do
		pNums[i] = j
		j = j + 1
	end

	math.randomseed(os.time() * math.random())

	for i = 1, numNumbers, 1 do
		randNum = math.random(1, #pNums)
		nums[i] = pNums[randNum]
		table.remove(pNums, randNum)
	end

	--print(drawing.uniqueID .. ": " .. table.concat(nums, '-'))--DEBUG
	return nums
end

function checkDatabase() --Checks database to ensure all lotteries in config are available to be purchased (entry with no drawn numbers)
	MySQL.ready(function() --foreach drawing in the config, ensure that the next drawing (time) is created so tickets can be purchased
		MySQL.Async.fetchAll('SELECT * FROM lottery_drawings WHERE numbers IS NULL', {}, function(results)
			for i, drawing in ipairs(Config.lotteries) do
				local exists = false
				for i = 1, #results, 1 do
					if drawing.uniqueID == results[i]['uniqueID'] then
						exists = true
						break
					end
				end
				if not exists then
					print("[s1lent_lottery] <CD01> You must create the first draw entry in the database for " .. drawing.uniqueID)
				end
			end
		end)
	end)
end

function stringDateToInt(date)
	local i = string.find(date, "/")
	local month = tonumber(string.sub(date, 1, i - 1))
	date = date.sub(date, i + 1)

	i = string.find(date, "/")
	local day = tonumber(string.sub(date, 1, i - 1))
	date = date.sub(date, i + 1)
	
	local year = tonumber(date)

	return month, day, year
end

function verifyDateAdd(month, day, year, daysToAdd)
	day = day + daysToAdd
	local monthLength
	if month == 2 then --28 days
		monthLength = 28
	elseif month == 4 or month == 6 or month == 9 or month == 11 then --30 days
		monthLength = 30
	else --31 days
		monthLength = 31
	end

	if day > monthLength then
		day = day - monthLength

		month = month + 1
		if month > 12 then
			month = month - 12
			year = year + 1
		end
	end

	return month, day, year
end

function getDrawingFromUniqueID(uniqueID)
	for i, drawing in ipairs(Config.lotteries) do
		if drawing.uniqueID == uniqueID then
			return drawing
		end
	end

	return nil
end

function getNextDrawingInfo(uniqueID)
	local id
	local date
	local error = false

	MySQL.ready(function()
		MySQL.Async.fetchAll('SELECT * FROM lottery_drawings WHERE uniqueID = @uniqueID ORDER BY id DESC LIMIT 1',
		{['uniqueID'] = uniqueID}, 
		function(results)
			if #results > 0 then
				id =  1 + results[1]['id']
				date = results[1]['date']
			else
				print("[s1lent_lottery] <GND01> You must create the first draw entry in the database for " .. uniqueID)
				error = true
			end
		end)
	end)

	while id == nil or date == nil do
		if error then
			return nil, nil
		end

		Citizen.Wait(10)
	end
	
	local drawing = getDrawingFromUniqueID(uniqueID)
	if drawing == nil then
		print("[s1lent_lottery] <GDU01> Error fetching drawing with uniqueID: " .. uniqueID .. ", ensure all drawings in database are in config, or are removed from database")
	end

	local daysToAdd
	if drawing.frequency == "daily" then
		daysToAdd = 1
	else 
		daysToAdd = 7
	end
	
	local month, day, year = stringDateToInt(date)
	month, day, year = verifyDateAdd(month, day, year, daysToAdd)
	date = month .. "/" .. day .. "/" .. year

	return id, date
end

ESX.RegisterServerCallback('s1lent_lottery:getLotteryList', function(source, cb)
	MySQL.ready(function()
		MySQL.Async.fetchAll('SELECT * FROM lottery_drawings WHERE numbers IS NULL', {}, 
		function(results)
			local lotteryList = {}
			for i = 1, #results, 1 do
				lotteryList[i] = {}
				local drawing = getDrawingFromUniqueID(results[i].uniqueID)
				lotteryList[i][1] = drawing.name
				lotteryList[i][2] = drawing.uniqueID
				lotteryList[i][3] = results[i].id
				local hr = drawing.drawTimeHr
				if hr < 10 then
					hr = "0" .. hr
				end
				local min = drawing.drawTimeMin
				if min < 10 then
					min = "0" .. min
				end
				lotteryList[i][4] = hr .. ":" .. min
				lotteryList[i][5] = results[i].date
				lotteryList[i][6] = drawing.ticketCost

				--Get numNumbers(set to default if not set in drawing)
				local numNumbers = drawing.numNumbers
				if not numNumbers then
					numNumbers = Config.DefaultNumNumbers
				end

				lotteryList[i][7] = numNumbers

				--Get range (set to default if not set in drawing)
				local range = drawing.range
				if not range then
					range = Config.DefaultRange
				end

				lotteryList[i][8] = range[1]
				lotteryList[i][9] = range[2]
			end
			cb(lotteryList)
		end)
	end)
end)

-- **Server-Side Purchase Tickets**

RegisterServerEvent("s1lent_lottery:purchaseTicket")
AddEventHandler("s1lent_lottery:purchaseTicket", function(uniqueID, id, price, pickedNums)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	--local balance = xPlayer.getAccount('bank').money --Bank
	local balance = xPlayer.getMoney() --Cash
	if balance >= price then
		--xPlayer.removeAccountMoney('bank', price) -- Bank
		xPlayer.removeMoney(price) --Cash
		storeTicket(xPlayer.identifier, uniqueID, id, pickedNums)
	else
		--TriggerClientEvent("s1lent_lottery:notEnoughMoney", src) -- Bank
		TriggerClientEvent("s1lent_lottery:notEnoughCash", src) -- Cash
	end
end)

function storeTicket(identifier, uniqueID, id, nums)
	MySQL.ready(function()
		MySQL.Async.execute('INSERT INTO lottery_tickets (identifier, drawingUniqueID, drawingID, numbers) VALUES (@identifier, @drawingUniqueID, @drawingID, @numbers)', --Create next drawing
		{
			['@identifier'] = identifier,
			['@drawingUniqueID'] = uniqueID,
			['@drawingID'] = id,
			['@numbers'] = nums
		}, function(rowsChanged) end)
	end)
end

-- **Server-Side Redeem Tickets** --
RegisterServerEvent("s1lent_lottery:redeemTickets")
AddEventHandler("s1lent_lottery:redeemTickets", function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	MySQL.ready(function()
		MySQL.Async.fetchAll('SELECT * FROM lottery_tickets WHERE identifier = @identifier and isDrawn = @isDrawn', 
		{	
			['@identifier'] = identifier,
			['@isDrawn'] = 1
		}, 
		function(results)
			local prizeTotal = 0
			for i = 1, #results, 1 do
				prizeTotal = prizeTotal + results[i].prize
				deleteTicket(results[i].id)
			end
			--xPlayer.addAccountMoney('bank', prizeTotal) -- Bank
			xPlayer.addMoney(prizeTotal) -- Cash
			TriggerClientEvent("s1lent_lottery:ticketsRedeemed", src, prizeTotal)
		end)
	end)
end)

function deleteTicket(id)
	MySQL.ready(function()
		MySQL.Async.execute('DELETE FROM lottery_tickets WHERE id = @id',
	{
		['@id'] = id
	},
	function(rowsChanged)
	end)
	end)
end

-- **Initialize and Start Threads** --

function init()
	loadDrawTimes() --Load all from Config
	sortDrawings() --Sort drawings in time-based order
	checkDatabase()

	readyToStart = true
end

--Handles timing of drawings
Citizen.CreateThread(function()
	init()

	while not readyToStart do
		Citizen.Wait(10)
	end
	local curDate
	local timeUntilNext
	local lastDraw
	while true do
		Citizen.Wait(0)
	
		curDate = os.date("*t", os.time())
		--print("Current Time: " .. curDate.wday .. " - " .. curDate.hour .. ":" .. curDate.min) --DEBUG 
		lastDraw = checkDrawings(curDate.wday, curDate.hour, curDate.min)
		--print("Last Draw: " .. lastDraw) --DEBUG
		timeUntilNext = getTimeUntilNextDrawing(curDate.wday, curDate.hour, curDate.min, lastDraw)--does not check other days? / more than once?
		--print("Waiting for " .. timeUntilNext .. " minute(s)") --DEBUG
		Citizen.Wait(timeUntilNext * 60000)
		--print("Done waiting") --DEBUG
	end
end)
