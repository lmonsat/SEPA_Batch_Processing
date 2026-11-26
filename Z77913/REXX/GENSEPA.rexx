
/* Allocate output file */
/* ADDRESS TSO "ALLOC FILE(SEPAIN) DA('Z77913.OUTPUT') MOD REUSE"

IF rc \= 0 THEN DO
    SAY "Allocation Error, RC =" rc
    EXIT 8
END
*/


/*
iban.1 = "FR7630006000011234567890189"
iban.2 = "LU280019400544750000"
iban.3 = "FR7630001007941234567890123"
iban.4 = "DE89370400440532013000"
iban.5 = "BE68539007547034"
iban.count = 5
*/

/* Declaration */
/* Reading the IBAN file and writting into a stem variable */
"EXECIO * DISKR" LISTACCT "(STEM iban. FINIS"

iban.count = iban.0

reason.1 = "Rent Transfer"
reason.2 = "Car Purchase"
reason.3 = "Gift"
reason.4 = "Reimbursement for business travel expenses"
reason.5 = "EDF Bill 2026/10"
reason.6 = "Deposit for Works"
reason.7 = "Vacation"
reason.count = 7

tx_id = 0

/* Generate a record */
DO nbr_transactions = 1 TO 100

    tx_id = tx_id + 1

    new_id = RANDOM(1, reason.count)
    new_reason = reason.new_id
    new_id = RANDOM(1, iban.count)
    new_iban_credit = iban.new_id
    new_id = RANDOM(1, iban.count)
    new_iban_debit = iban.new_id

    DO WHILE new_iban_credit = new_iban_debit
        new_id = RANDOM(1, iban.count)
        new_iban_debit = iban.new_id
    END

    /* amount is in cents */
    amount = RANDOM(25000, 125000)

    CALL write_record tx_id, new_iban_debit, new_iban_credit, amount, new_reason

END

/* To mark EOF write FINIS when writting is done */
"EXECIO 0 DISKW " SEPAIN "(FINIS)"

EXIT 0

/* Formatting and writting into the output file */
write_record:

    PARSE ARG tx_id, iban_debit, iban_credit, amount, reason

    /*say tx_id || iban_credit || iban_debit || amount || reason*/

    /* String format */
    format_tx_id = "TX_" || RIGHT(tx_id, 13, "0")
    format_iban_credit = LEFT(iban_credit, 34, " ")
    format_iban_debit = LEFT(iban_debit, 34, " ")
    format_reason = LEFT(reason, 26, " ")
    format_amount = RIGHT(amount, 10, "0")

    record.1 = format_tx_id || format_iban_debit || format_iban_credit ||,
        format_amount || format_reason

    SAY record.1

    /* Writting in file with EXECIO using STEM variable */
    "EXECIO 1 DISKW" SEPAIN "(STEM record."

    IF rc \= 0 THEN DO
        SAY "Writting Error, RC =" rc
        EXIT 8
    END

RETURN
