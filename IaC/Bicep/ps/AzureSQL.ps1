$SQLServer = $args[0]
$db = "auctionpaymentdb"
$username = $args[1]
$qcd = "USE [AuctionPaymentDB]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AuctionPayment]') AND type in (N'U'))
BEGIN
    /****** Object:  Table [dbo].[AuctionPayment]    Script Date: 11/10/2021 2:36:39 PM ******/
    SET ANSI_NULLS ON
    SET QUOTED_IDENTIFIER ON
    CREATE TABLE [dbo].[AuctionPayment](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [CreditCardNo] [nvarchar](max) NULL,
        [Name] [nvarchar](max) NULL,
        [IdAuction] [int] NOT NULL,
        [BidUser] [nvarchar](max) NULL,
        [Month] [int] NOT NULL,
        [Year] [int] NOT NULL,
        [PaymentStatus] [int] NOT NULL,
        [PaymentDate] [datetime2](7) NOT NULL,
        [CorrelationId] [nvarchar](100) NULL,
     CONSTRAINT [PK_AuctionPayment] PRIMARY KEY CLUSTERED 
    (
        [Id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
" 
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $qcd -Username $username -Password "P@ssw0rd!@#" -Verbose

Write-Output "Payment Database has been setup successfully" 