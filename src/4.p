/* 4) Looking at the attached .csv file (cust-sales.csv)
-Create a temp-table to store the data
-Import the data from disk into the temp table
-Sum the sales data by customer into a new temp-table
-Export the resulting data to a new .csv file */

DEFINE TEMP-TABLE tt_sales1
  FIELD  customer      AS  CHARACTER 
  FIELD  invoice-date  AS  DATE 
  FIELD  sales-amt     AS  DECIMAL 
.

DEFINE TEMP-TABLE tt_sales2
  FIELD  customer  as CHARACTER 
  FIELD  sales-amt as DECIMAL.

INPUT FROM "C:\temp\cust-sales.csv".
REPEAT:
    ERROR-STATUS:ERROR = NO.
    CREATE tt_sales1.
    IMPORT DELIMITER "," tt_sales1 NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
    DO:
        DELETE tt_sales1.
        UNDO, NEXT.
    END.
    FIND FIRST tt_sales2 WHERE tt_sales2.customer = tt_sales1.customer NO-ERROR.
    IF NOT AVAILABLE tt_sales2 THEN
    DO:
        CREATE tt_sales2.
        BUFFER-COPY tt_sales1 TO tt_sales2.
    END.
    ELSE 
        tt_sales2.sales-amt = tt_sales2.sales-amt + tt_sales1.sales-amt.
END.
INPUT CLOSE.

OUTPUT TO "C:\temp\result.csv".
FOR EACH tt_sales2:
    EXPORT DELIMITER "," tt_sales2.
END.
OUTPUT CLOSE.
