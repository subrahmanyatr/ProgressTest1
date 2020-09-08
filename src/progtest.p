/*Assume at least one record exists in the customer table*/

DEFINE BUFFER bfCustomer FOR customer.
DEFINE VARIABLE mcSavedName AS CHARACTER NO-UNDO.
DEF VAR pv_error_msg AS CHAR NO-UNDO.

FIND FIRST bfCustomer NO-LOCK NO-ERROR.

DISPLAY "About to update the first customer"
        bfCustomer.name.

ASSIGN mcSavedName = bfCustomer.name
    pv_error_msg = "Update failed!".

/* Here udpates are made to customer table in 2 procedures. So all the updates are scoped to 1 main 
transaction so that any error occured in the transaction block gets undone. Before starting this transaction customer table
record is backed up in .BI file */
DO TRANSACTION ON ERROR UNDO, LEAVE:
    RUN UpdateCust.
    IF RETURN-VALUE <> "" THEN
    DO:
        pv_error_msg = RETURN-VALUE.
        UNDO, LEAVE.
    END.
    FIND CURRENT bfcustomer EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAIL bfcustomer THEN DO:
        IF LOCKED bfcustomer THEN
            pv_error_msg = "Customer record in use. Update failed!".
        ELSE
            pv_error_msg = "Customer record not available. Update failed!".
        UNDO, LEAVE.
    END.
    DISPLAY "Changing name back".
    ASSIGN bfCustomer.name = mcSavedName.
    pv_error_msg = "".
END.
IF pv_error_msg <> "" THEN
    MESSAGE pv_error_msg
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
ELSE
    MESSAGE "Record updated successfully."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.


PROCEDURE UpdateCust:

  /* Here we are opening a sub-transaction, Before starting this transaction customer table
    record is backed up in Local before image (LBI) so that if any error occurs in this sub-transaction
    blcok then it can be rolled back to the earlier state.  */
  DO TRANSACTION ON ERROR UNDO, RETURN "Update failed!":
      FIND FIRST customer EXCLUSIVE-LOCK NO-ERROR.
      IF NOT AVAIL customer THEN
      DO:
          IF LOCKED customer THEN
              UNDO, RETURN "Customer record in use. Update failed!".
          ELSE
              UNDO, RETURN "Customer record not available. Update failed!".
      END.
      ASSIGN customer.name = customer.name + "-test".
      RELEASE customer.
  END.
  RETURN.
END.
