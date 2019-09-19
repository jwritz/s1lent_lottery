USE `essentialmode`;

ALTER TABLE `lottery_tickets` ADD `drawDate` VARCHAR(255) NOT NULL;
ALTER TABLE `lottery_tickets` ADD `drawTime` VARCHAR(255) NOT NULL;