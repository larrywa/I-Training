SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema auctionservicedb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema auctionservicedb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `auctionservicedb` DEFAULT CHARACTER SET latin1 ;
USE `auctionservicedb` ;

-- -----------------------------------------------------
-- Table `auctionservicedb`.`auction`
-- -----------------------------------------------------
CREATE TABLE `auction` (
  `idauction` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `description` varchar(300) DEFAULT NULL,
  `startingPrice` decimal(6,0) DEFAULT NULL,
  `auctionDate` datetime DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `image` mediumtext,
  `activeInHours` int(11) DEFAULT NULL,
  `bidPrice` decimal(6,0) DEFAULT NULL,
  `userId` varchar(250) DEFAULT NULL,
  `isActive` tinyint(4) DEFAULT '1',
  `userName` varchar(300) DEFAULT NULL,
  `isPaymentMade` tinyint(4) DEFAULT NULL,
  `bidUser` varchar(250) DEFAULT NULL,
  `bidId` varchar(250) DEFAULT NULL,
  `correlationId` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idauction`)
) ENGINE=InnoDB AUTO_INCREMENT=175 DEFAULT CHARSET=latin1;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
