USE [AuctionPaymentDB]
GO
/****** Object:  Table [dbo].[AuctionPayment]    Script Date: 11/10/2021 2:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
