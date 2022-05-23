
-- This file shows the queries used for the inBetweeners NFT Dashboard.
-- The inBetweeners NFT Dashboard has been done using Dune Analytics.
-- Dune Analytics is a community-based, open-source data provider, which allows anyone to publish and access crypto trends in real time.


----------------------------------------------------------------------
-- Floor Price (Tracker)
SELECT 
    date_trunc('day', block_time) as "Day",
    sum(original_amount) as "Volume",
    percentile_cont(.5) within group (order by original_amount) as "Floor Price"
FROM nft.trades nftt
WHERE nftt."original_currency" IN ('ETH', 'WETH') AND number_of_items = 1 AND original_amount > 0.01
AND nft_contract_address = CONCAT('\x', substring('\contract address goes here' from 3))::bytea
AND "trade_type" = 'Single Item Trade'
group by "Day"
order by "Day" DESC
----------------------------------------------------------------------



----------------------------------------------------------------------
-- Total Volume (Tracker)
SELECT date_trunc('day', block_time) AS "Date",
SUM(usd_amount) AS "Total Volume"
FROM nft."trades"
WHERE nft_contract_address = '\contract address goes here'
GROUP BY "Date"
ORDER BY "Date" DESC
----------------------------------------------------------------------



----------------------------------------------------------------------
-- Last 24 Hours Sales
SELECT
    SUM("original_amount") as ETH,
    COUNT(tx_hash) as sales,
    SUM("original_amount") filter (WHERE (NOW() - block_time) <= interval '24 hours') as vol_24,
    COUNT(tx_hash) filter (WHERE (NOW() - block_time) <= interval '24 hours') as sales_24,
    SUM("original_amount") filter (WHERE (NOW() - block_time) <= interval '1 week') as vol_7d,
    COUNT(tx_hash) filter (WHERE (NOW() - block_time) <= interval '1 week') as sales_7d
FROM
    nft."trades"
WHERE
    nft_contract_address ='\nft contract address goes here'
AND
    original_currency in ('ETH','WETH')
----------------------------------------------------------------------



----------------------------------------------------------------------
-- Operations / Community Wallet Balance over time
SELECT SUM(transfer) over (ORDER BY day ASC), day
FROM (

SELECT date_trunc('day', block_time) AS day, SUM(-value/1e18) AS transfer
        FROM ethereum."traces"
        WHERE "from" = '\wallet address goes here' 
        AND (LOWER(call_type) NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type is NULL)
        AND "tx_success" = true
        AND success = true
        GROUP BY 1
        
        UNION all
        
        SELECT
        date_trunc('day', block_time) AS day, SUM(value/1e18) AS transfer
        FROM ethereum."traces"
        WHERE "to" = '\wallet address goes here' 
        AND (LOWER(call_type) NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type is NULL)
        AND "tx_success" = true
        AND success = true
        GROUP BY 1
        
        UNION ALL --gas costs
        
        SELECT
        date_trunc('day', block_time) AS day, -SUM(gas_price*"gas_used")/1e18 AS transfer
        FROM ethereum."transactions"
        WHERE "from" = '\wallet address goes here' 
        GROUP BY 1
    ) AS x
----------------------------------------------------------------------



----------------------------------------------------------------------
-- Total Sales
SELECT
    SUM("original_amount") as ETH,
    COUNT(tx_hash) as sales,
    SUM("original_amount") filter (WHERE (NOW() - block_time) <= interval '24 hours') as vol_24,
    COUNT(tx_hash) filter (WHERE (NOW() - block_time) <= interval '24 hours') as sales_24,
    SUM("original_amount") filter (WHERE (NOW() - block_time) <= interval '1 week') as vol_7d,
    COUNT(tx_hash) filter (WHERE (NOW() - block_time) <= interval '1 week') as sales_7d
FROM
    nft."trades"
WHERE
    nft_contract_address ='\nft contract address goes here'
AND
    original_currency in ('ETH','WETH')
----------------------------------------------------------------------



----------------------------------------------------------------------
-- Total Supply
SELECT output_0 as "Total Supply" FROM inbetweeners."InBetweeners_call_totalSupply";
----------------------------------------------------------------------
