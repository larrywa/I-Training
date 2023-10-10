[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")


$hostname =''
$dbusername = ''
$dbpassword = 'P@ssw0rd!@#'
$dbname='auctionservicedb'

$connStr ="server="+ $hostname +";Persist Security Info=false;user id=" + $dbusername + ";pwd=" + $dbpassword + ";"


$conn = New-Object MySql.Data.MySqlClient.MySqlConnection

$conn.ConnectionString = $connStr

$conn.Open()


$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.Connection  = $conn
$cmd.CommandText = "DROP DATABASE IF EXISTS " + $dbname
$cmd.ExecuteNonQuery()

$sqlfile = "C:\MIP_Development\MicroservicesIP\scripts\auctionservicedb.sql"

$cmd.CommandText = 'CREATE SCHEMA IF NOT EXISTS `auctionservicedb` DEFAULT CHARACTER SET latin1 ; USE `auctionservicedb`; CREATE TABLE IF NOT EXISTS `auctionservicedb`.`auction` (
  `idauction` INT(11) NOT NULL AUTO_INCREMENT,`name` VARCHAR(45) NULL DEFAULT NULL,`description` VARCHAR(300) NULL DEFAULT NULL,`startingPrice` DECIMAL(6,0) NULL DEFAULT NULL,`auctionDate` DATETIME NULL DEFAULT NULL, `status` INT(11) NULL DEFAULT NULL,`image` MEDIUMTEXT NULL DEFAULT NULL,`activeInHours` INT(11) NULL DEFAULT NULL, `bidPrice` DECIMAL(6,0) NULL DEFAULT NULL, `userId` VARCHAR(250) NULL DEFAULT NULL, `isActive` TINYINT(4) NULL DEFAULT 1, `userName` VARCHAR(300) NULL DEFAULT NULL,`isPaymentMade` TINYINT(4) NULL DEFAULT NULL, `bidUser` VARCHAR(250) NULL DEFAULT NULL, `bidId` VARCHAR(250) NULL DEFAULT NULL,
  `correlationId` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`idauction`))
ENGINE = InnoDB
AUTO_INCREMENT = 152
DEFAULT CHARACTER SET = latin1;'

$cmd.ExecuteNonQuery() 

#mysql $dbname -u $dbusername –p $dbpassword -e "source $sqlfile"

$conn.Close()

