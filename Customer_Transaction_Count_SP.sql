-- Customer Transaction Count

USE [BOM_FIS_DB]
GO


/*** Object: Stored Procedure [dbo].[GetCustomerTransactionCount)
 Date: 4/19/2024 1:15:34 PM ***/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Description: Check Customer Transaction Count Based on transaction type

ALTER PROCEDURE [dbo].[GetCustomerTransactionCount]

	@accountNo varchar(50),

	@transType varchar(5),

	@transDate date,

	@transCount int output,

	@monthtransCount int output

AS

BEGIN

	SET NOCOUNT ON;


	SELECT @transCount = COUNT (1)

	FROM dbo.online transactions tl

	WHERE

	--tl.cr_dr = @transType

	--AND

	CONVERT(date, tl.transaction_date) = @transDate

	AND tl.cbs_sent = 'Success'

	AND tl.account_no = @accountNo

	AND tl.cashInd IN ('C', 'T')

	AND NOT EXISTS

	(

		SELECT 1

		FROM dbo.online_transactions t2

		WHERE

		CONVERT(date, t2.transaction_date) = @trans Date

		AND t2.cbs_sent = 'Success'

		AND t2.account_no = tl.account_no

		AND t2.pos_trans_no = tl.pos_trans_no

		AND t2.cashInd IN ('C', 'T')

		GROUP BY t2.pos_trans_no

		HAVING COUNT (1) > 1
	)


	SELECT @monthtransCount = COUNT (1)  -- checks Transaction Limits

	FROM dbo. TransactionLogLimitCheck tl

	WHERE

	CONVERT(varchar(7), tl.transaction_date, 126) = CONVERT (varchar(7), @transDate, 126)

	AND tl.cbs_sent = 'Success'		-- checks only successful transactions

	AND tl.account_no = @accountNo

	AND tl.cashInd IN ('C', 'T')   -- only Fund Transfer or Cash Transaction

	AND NOT EXISTS
	
	(

		SELECT 1
		
		FROM dbo.TransactionLogLimitCheck t2  		-- doesn't count money back after concellation

		WHERE

		CONVERT(varchar(7), tl.transaction_date, 126) = CONVERT(varchar(7), @trans Date, 126)

		AND t2.cbs_sent = 'Success' 

		AND t2.account_no = tl.account_no 

		AND t2.pos_trans_no = tl.pos_trans_no 

		AND t2.trans_type = '400' 

		AND t2.cashInd IN ('C', 'T')

	)

END










