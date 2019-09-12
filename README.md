# s1lent_lottery

## Features
* Automatic scheduled drawings 
* UI for purchasing lottery tickets
* Ability to create custom lottery drawings

## Usage
* Go to the LS Lottery Office in the city to purchase tickets for the available lotteries
* Once the lottery has been drawn, return to the LS Lottery Office to redeem your tickets
* For custom lottery drawings, see [Customization](https://github.com/jwritz/s1lent_lottery/wiki/Customization)
* Look at the [Wiki Page](https://github.com/jwritz/s1lent_lottery/wiki) for full information

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
* See [Customization](https://github.com/jwritz/s1lent_lottery/wiki/Customization) to learn how to customize and create lottery drawings
* See [Errors](https://github.com/jwritz/s1lent_lottery/wiki/Errors) for help with errors
