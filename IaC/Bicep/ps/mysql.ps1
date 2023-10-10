[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

$hostname=$args[0]
$dbusername=$args[1]

$dbpassword = 'P@ssw0rd!@#'
$dbname='auctionservicedb'

$connStr ="server="+ $hostname +";Persist Security Info=false;userid=" + $dbusername + ";pwd=" + $dbpassword + ";"

$conn = New-Object MySql.Data.MySqlClient.MySqlConnection

$conn.ConnectionString = $connStr

$conn.Open()

Write-Host "Droping auctionservicedb if database already exists"
$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.Connection  = $conn
$cmd.CommandText = "DROP DATABASE IF EXISTS " + $dbname
$result = $cmd.ExecuteNonQuery()

if($result -eq 1){
  Write-Host "Database auctionservicedb has been removed."
}else{
  Write-Host "Database auctionservicedb does not exist."
}

$cmd.CommandText = @"
CREATE SCHEMA IF NOT EXISTS auctionservicedb DEFAULT CHARACTER SET utf8;

USE auctionservicedb;

CREATE TABLE IF NOT EXISTS auctionservicedb.auction (
  idauction INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NULL DEFAULT NULL,
  description VARCHAR(300) NULL DEFAULT NULL,
  startingPrice DECIMAL(6,0) NULL DEFAULT NULL,
  auctionDate DATETIME NULL DEFAULT NULL,
  status INT(11) NULL DEFAULT NULL,
  image MEDIUMTEXT NULL DEFAULT NULL,
  activeInHours INT(11) NULL DEFAULT NULL,
  bidPrice DECIMAL(6,0) NULL DEFAULT NULL,
  userId VARCHAR(250) NULL DEFAULT NULL,
  isActive TINYINT(4) NULL DEFAULT 1,
  userName VARCHAR(300) NULL DEFAULT NULL,
  isPaymentMade TINYINT(4) NULL DEFAULT NULL,
  bidUser VARCHAR(250) NULL DEFAULT NULL,
  bidId VARCHAR(250) NULL DEFAULT NULL,
  correlationId VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (idauction)
) ENGINE = InnoDB AUTO_INCREMENT = 152 DEFAULT CHARACTER SET = utf8;
"@

$result = $cmd.ExecuteNonQuery()

if($result -eq 1){
  Write-Host "Database auctionservicedb has been created."
}else{
  Write-Host "Creationg of auctionservicedb failed."
}
$conn.Close()