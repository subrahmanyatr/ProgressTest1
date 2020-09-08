DEFINE BUFFER buf-edi-outbound FOR edi-outbound.
DEFINE TEMP-TABLE op_tt_table LIKE edi-outbound.

DEF INPUT PARAM ip_entity_code AS CHAR NO-UNDO.
DEF INPUT PARAM ip_order_no AS INT NO-UNDO.
DEF OUTPUT PARAM TABLE FOR op_tt_table.
    
DEFINE QUERY pq_outbound FOR edi-outbound.

    OPEN QUERY pq_outbound FOR EACH edi-outbound NO-LOCK.
        REPEAT ON ERROR UNDO, RETURN "Error":
            GET NEXT pq_outbound.
            IF NOT AVAIL edi-outbound THEN
                LEAVE.
            IF edi-outbound.xdock-entity = "" THEN
                NEXT.
            /*  by this time we have filtered it and want to update the record.
            so we are fetching the record in exclusive lock by using another buffer
            for same table. checking if its not avail and locked then message and retry.
            if record is locked succesfully, fetch it and update the record buffer and 
            copy to output temp-table. releasing the record at the end.*/
            FIND FIRST buf-edi-outbound OF edi-outbound EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE buf-edi-outbound THEN
            DO:
                IF LOCKED edi-outbound THEN  
                    UNDO, RETURN "EDI Outbound record in use!".
                ELSE
                    UNDO, RETURN "EDI Outbound record not available!".
            END.
            ASSIGN buf-edi-outbound.send-date = TODAY. 
            CREATE op_tt_table.
            BUFFER-COPY buf-edi-outbound TO op_tt_table.
            RELEASE buf-edi-outbound.
        END.

CLOSE QUERY pq_outbound.
