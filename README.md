# s1lent_lottery

## Features
* Automatic scheduled drawings 
* UI for purchasing lottery tickets
* Ability to create custom lottery drawings

## Usage
* Go to the LS Lottery Office in the city to purchase tickets for the available lotteries
* Once the lottery has been drawn, return to the LS Lottery Office to redeem your tickets
* For custom lottery drawings, see [Customization](#customization)

## Requirements
* [es_extended](https://github.com/ESX-Org/es_extended)

## Download & Installation
* Download the latest [release](https://github.com/jwritz/s1lent_lottery/releases)
* Rename folder to `s1lent_lottery` and place it in your resources folder
* Add the following to your `server.cfg`:
```
start s1lent_lottery
```
* Import `s1lent_lottery.sql` in your database
* **_Important_ to do before starting s1lent_lottery for the first time:** In `s1lent_lottery_config.lua`, update default lotteries with correct date (MM/DD/YYYY): 
  * Daily Lotto: Date of next day where 12:00 will occur (may be current day if before 12:00)
  * Monday Lotto: Date of next monday where 18:00 will occur (may be current day if before 18:00)
  * Friday Lotto: Date of next friday where 18:00 will occur (may be current day if before 18:00)
* See [Customization](#customization) to learn how to customize and create lottery drawings
---
## Customization
To customize lotteries and prizes go to `s1lent_lottery_config.lua` and look at the below information
### Lotteries
* Example Lottery: 
```
{name = "Daily Lotto", uniqueID ="daily_lotto" , frequency = "daily", drawTimeHr = 12, drawTimeMin = 00, ticketCost = 10, prize = "amt", value = 100, range = {0, 10}, numNumbers = 2, prizePercents = 2}
```
* Breakdown Of Values:
  * name : Name of lottery, which will appear in-game
  * uniqueID : ID for the lottery that *must* be unique for each lottery
  * frequency : How often the lottery will be drawn 
    * Options:
      * Sunday : sun
      * Monday : mon
      * Tuesday : tue
      * Wednesday : wed
      * Thursday : thur
      * Friday : fri
      * Saturday : sat
  * drawTimeHr : Hour that the lottery will be held (in 24 hour format)
  * drawTimeMin : Minute that the lottery will be held 
  * ticketCost : Cost of each ticket
  * prize : Must be `amt`, may be utilized in future update
  * value : Prize value for the grand prize (100%)
  * range : Range of numbers players will be able to choose from {lowestValue, highestValue} (optional)
  * numNumbers : Number of numbers players must choose when purchasing a ticket (optional)
    * *Must* be less than the numbers available in the range
  * prizePercents : Index of the prizePercent values from `Config.LotteryPrizes` (See [Prizes](#prizes))
* To customize the default lotteries change the values in the config
* To add a new a new lottery:
  * Copy and paste a default lottery, or the lottery above, below the last lottery. (Make sure to have a `,` between lotteries)
  * Change the values
  * Create a new row in your database in `lottery_drawings` and enter:
    * uniqueID: the uniqueID of your lottery
    * id : 0
    * date : the next date that your lottery will be drawn (may be the current day)
    * numbers : Leave the numbers column for your lottery as `(null)`

### Prizes
Example LotteryPrizes Percents:
```
[1] = {5, 10, 25, 35, 100}
```
* Explaination: These values are the percentage of the value for the lottery drawing that matching a certain amount of numbers gets
  * In the example: If players match 1 number, they get 5% of the value for the lottery, if they match all 5 numbers they get 100% of the value for the lottery
  * **There must be the same number of percents as there are numNumbers for the lottery drawing**
* To add a new LotteryPrizes Percent:
  * Copy and paste the last prize percents, or example above, below the last LotteryPrize Percents (Make sure to have a `,` between lotteries)
  * Change the index number (in []) to the last index + 1, or a number that is not already in use
  * Use the index value as your `prizePercents`
  * **There must be the same number of percents as there are numNumbers for the lottery drawing**
