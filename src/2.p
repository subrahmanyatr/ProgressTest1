DEFINE VARIABLE vcMonths AS CHARACTER NO-UNDO.
DEFINE VARIABLE vcMonths1 AS CHARACTER NO-UNDO.

DEFINE  VARIABLE  ivcnt as int no-undo.
vcMonths = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec".
DO ivcnt = num-entries(vcMonths) TO  1 BY -1:
  vcMonths1 = vcMonths1
            + (if vcMonths1 = ""  THEN  "" ELSE ",") 
            + entry(ivcnt, vcMonths, ",").
END.
DISP vcMonths1  FORMAT "X(60)".
