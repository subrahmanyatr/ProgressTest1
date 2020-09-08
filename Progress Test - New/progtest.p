/*Assume at least one record exists in the customer table*/

DEFINE BUFFER bfCustomer FOR customer.
DEFINE VARIABLE mcSavedName AS CHARACTER NO-UNDO.

FIND FIRST bfCustomer.

DISPLAY "About to update the first customer"
        bfCustomer.name.

mcSavedName = bfCustomer.name.

RUN UpdateCust.

DISPLAY "Changing name back".
ASSIGN bfCustomer.name = mcSavedName.

PROCEDURE UpdateCust:

  DO TRANSACTION:
   FIND FIRST customer EXCLUSIVE-LOCK.
   ASSIGN customer.name = customer.name + "-test".
  END.

  RETURN.
END.
