      *-----------------------
       IDENTIFICATION DIVISION.
      *-----------------------
       PROGRAM-ID.    GENIBAN
       AUTHOR.        Monsat Lilian
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *     SELECT IBAN-FILE ASSIGN TO IBANLIST.
      *-------------
       DATA DIVISION.
      *-------------
       FILE SECTION.
      * FD  IBAN-FILE RECORDING MODE F.
      * 01  REC-IBAN.
      *     05  IBAN       PIC X(34).
      *
       WORKING-STORAGE SECTION.
      *-------------------------------------------------------------
      * IBAN structure by country:
      *
      * FR (27 chars): header(FR + 2 digits) + bank code(5 digits) +
      *    agency code(5 digits) + accnt number (11 digits) +
      *    RIB key(2 digits).
      *
      * LU (20 chars): header(LU + 2 digits) + bank code(3 digits) +
      *    account number(13 chars).
      *
      * DE (22 chars): header(DE + 2 digits) + bank code(8 digits) +
      *    account number(10 digits).
      *
      * BE (16 chars): header(BE + 2 digits) + bank code(3 digits) +
      *    account number(7 digits) + national key BBAN(2 digits).
      *
      *-------------------------------------------------------------
      *
       01 WS-BANK.
         05 WS-FINAL-IBAN         PIC X(27).
         05 WS-BANK-CODE          PIC 9(05).
         05 WS-AGENCY-CODE        PIC 9(05).
         05 WS-BANK-ACCOUNT       PIC 9(11).
         05 WS-FULL-RIB           PIC 9(15).
         05 WS-CODE-VAL           PIC 9(06).
         05 WS-IBAN-KEY           PIC 9(02).
         05 WS-RIB-KEY            PIC 9(02).
      *
         05 WS-DE-FINAL-IBAN      PIC X(22).
         05 WS-DE-BLZ             PIC 9(08).
         05 WS-DE-ACCOUNT         PIC 9(10).
      *
         05 WS-LU-FINAL-IBAN      PIC X(20).
         05 WS-LU-BANK            PIC 9(03).
         05 WS-LU-ACCOUNT         PIC 9(13).
      *
         05 WS-BE-FINAL-IBAN      PIC X(16).
         05 WS-BE-BASE-10         PIC 9(10).
         05 WS-BE-BANK            PIC 9(03).
         05 WS-BE-ACCOUNT         PIC 9(07).
         05 WS-BE-KEY             PIC 9(02).
      *
       01 WS-COUNTRY-CODE.
         05 WS-CODE-ALPHA                      PIC A(02).
         05 WS-CODE-NUM-GROUP.
           10 WS-CODE OCCURS 2 TIMES           PIC A(01).
         05 WS-CONVERTED-CODE-GROUP.
           10 WS-CONVERTED-CODE OCCURS 2 TIMES PIC 9(02).
         05 WS-CODE-NUM REDEFINES WS-CONVERTED-CODE-GROUP PIC 9(04).
      *
       01 WS-COUNTRY-BBAN.
         05 WS-FR-BBAN-STR       PIC X(29).
         05 WS-LU-BBAN-STR       PIC X(22).
         05 WS-DE-BBAN-STR       PIC X(24).
         05 WS-BE-BBAN-STR       PIC X(18).
      *
       01 WS-CALCULATION.
         05 WS-LEN              PIC 9(02) COMP.
         05 WS-I                PIC 9(02) COMP.
         05 WS-DIGIT            PIC 9(01) VALUE ZERO.
         05 WS-REM              PIC 9(04) COMP VALUE ZERO.
         05 WS-QUOTIENT         PIC 9(15) COMP VALUE ZERO.
         05 WS-PTR              PIC 9(02) VALUE 1.
      *   05 WS-RESTE             PIC 9(02).
      *
       01 WS-CONVERSION.
           05  WS-CHAR             PIC X(01).
           05  WS-NUM-VAL          PIC 9(02).
      *
       01 WS-RETURN          PIC 9(08) VALUE 0.
       01 WS-MAX             PIC 9(03) VALUE 3.
       01 WS-MAX-AGENCY      PIC 9(03) VALUE 99.
       01 WS-MAX-ACC-NBR     PIC 9(01) VALUE 9.
       01 WS-TEMP            PIC 9(01).
      *

      *
       01 WS-ALPHA-EBCDIC   PIC X(62) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZa
      -    "bcdefghijklmnopqrstuvwxyz0123456789".
       01 WS-ALPHA-ASCII    PIC X(62) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZa
      -    "bcdefghijklmnopqrstuvwxyz0123456789".
       01 WS-COUNT           PIC 9(02).
      *------------------
       PROCEDURE DIVISION.
      *------------------
      *
      *INFO: FOR EVERY BANK AGENCY/CODE GENERATION OF FIRST '0',
      *      IMPOSSIBLE BY CONCEPTION.
      *
      *TODO: FACTORIZATION
      *
       000-MAIN.
           PERFORM 1000-IBAN-FR.
           PERFORM 2000-IBAN-DE.
           PERFORM 3000-IBAN-LU.
           PERFORM 4000-IBAN-BE.
           GOBACK.
      *
       1000-IBAN-FR.
           MOVE "FR" TO WS-CODE-ALPHA.
           CALL 'RANDSUB' USING BY CONTENT "FR", "INIT",
      -                         BY REFERENCE WS-MAX, WS-RETURN
           MOVE WS-RETURN(4:5) TO WS-BANK-CODE
           DISPLAY 'BANK CODE: ' WS-BANK-CODE.
      *
           PERFORM UNTIL WS-AGENCY-CODE IS NOT EQUAL TO ZERO
              CALL 'RANDSUB' USING BY CONTENT " ", "NEXT",
      -                            BY REFERENCE WS-MAX-AGENCY, WS-RETURN
              MOVE WS-RETURN(4:5) TO WS-AGENCY-CODE
           END-PERFORM.
           DISPLAY 'BANK AGENCY: ' WS-AGENCY-CODE.
      *    Calling 11 times RANDSUB for the 11 digits in the account nbr
           MOVE 11 TO WS-COUNT.
           PERFORM UNTIL WS-COUNT <= 0
              CALL 'RANDSUB' USING BY CONTENT " ", "NEXT",
      -                         BY REFERENCE WS-MAX-ACC-NBR, WS-RETURN
              MOVE WS-RETURN(7:1) TO WS-BANK-ACCOUNT(WS-COUNT:1)
              DISPLAY 'ACCOUNT NUMBER: ' WS-BANK-ACCOUNT
           SUBTRACT 1 FROM WS-COUNT
           END-PERFORM.
      *    calculation of RIB KEY:
      *    97 - ((89 * BANK CODE / 15 * AGENCY CODE / 3 * ACC) MOD 97)
           COMPUTE WS-FULL-RIB = (89 * WS-BANK-CODE)
                                + (15 * WS-AGENCY-CODE)
                                + (3  * WS-BANK-ACCOUNT);
      *
           DIVIDE WS-FULL-RIB BY 97
               GIVING    WS-QUOTIENT
               REMAINDER WS-REM.
      *
           COMPUTE WS-RIB-KEY = 97 - WS-REM
      *
           DISPLAY 'RIB-KEY: ' WS-RIB-KEY.
      *    RESET of WS-REM
           MOVE 0 TO WS-REM.
      *    Country code conversion
           MOVE 'F' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(1).
           MOVE 'R' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(2).
      *
           DISPLAY 'CONVERTED CODE: ' WS-CODE-NUM.
      *
           STRING WS-BANK-CODE    DELIMITED BY SIZE
                  WS-AGENCY-CODE  DELIMITED BY SIZE
                  WS-BANK-ACCOUNT DELIMITED BY SIZE
                  WS-RIB-KEY      DELIMITED BY SIZE
                  WS-CODE-NUM     DELIMITED BY SIZE
                  INTO WS-FR-BBAN-STR
                  WITH POINTER WS-PTR
           END-STRING.
      *
           STRING '00' DELIMITED BY SIZE
                 INTO WS-FR-BBAN-STR
                 WITH POINTER WS-PTR
           END-STRING.
           DISPLAY 'BBAN STR: ' WS-FR-BBAN-STR.
      *    IBAN KEY calculation
           COMPUTE WS-LEN = FUNCTION LENGTH (WS-FR-BBAN-STR).
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
               MOVE WS-FR-BBAN-STR(WS-I:1) TO WS-DIGIT
               COMPUTE WS-REM = WS-REM * 10 + WS-DIGIT
               DIVIDE WS-REM BY 97
                    GIVING WS-QUOTIENT
                    REMAINDER WS-REM
               DISPLAY 'REM: ' WS-REM
           END-PERFORM.
      *
           COMPUTE WS-IBAN-KEY = 98 - WS-REM.
           DISPLAY 'IBAN KEY: ' WS-IBAN-KEY.
           STRING WS-CODE-ALPHA   DELIMITED BY SIZE
                  WS-IBAN-KEY     DELIMITED BY SIZE
                  WS-BANK-CODE    DELIMITED BY SIZE
                  WS-AGENCY-CODE  DELIMITED BY SIZE
                  WS-BANK-ACCOUNT DELIMITED BY SIZE
                  WS-RIB-KEY      DELIMITED BY SIZE
                  INTO WS-FINAL-IBAN
           END-STRING.
           DISPLAY 'FINAL IBAN: ' WS-FINAL-IBAN.
      *
       2000-IBAN-DE.
           DISPLAY '--------------------------------------------------'
      *    Reset WS value used in the previous paragraph
           INITIALIZE WS-BANK.
           INITIALIZE WS-COUNTRY-CODE.
           INITIALIZE WS-CALCULATION.
      *    INITIALIZE reset 0 to the PTR or it needs to be at 1
           MOVE 1 TO WS-PTR IN WS-CALCULATION.
           MOVE 0 TO WS-RETURN.
           INITIALIZE WS-CONVERSION.
           MOVE "DE" TO WS-CODE-ALPHA.
                 CALL 'RANDSUB' USING BY CONTENT "DE", "NEXT",
      -                               BY REFERENCE WS-MAX, WS-RETURN
                 MOVE WS-RETURN(1:8) TO WS-DE-BLZ
           DISPLAY 'BANK CODE: ' WS-DE-BLZ.
      *    Calling 10 times RANDSUB for the 10 digits in the account nbr
           MOVE 10 TO WS-COUNT.
           PERFORM UNTIL WS-COUNT <= 0
              CALL 'RANDSUB' USING BY CONTENT " ", "NEXT",
      -                         BY REFERENCE WS-MAX-ACC-NBR, WS-RETURN
              MOVE WS-RETURN(7:1) TO WS-DE-ACCOUNT (WS-COUNT:1)
              DISPLAY 'ACCOUNT NUMBER: ' WS-DE-ACCOUNT
           SUBTRACT 1 FROM WS-COUNT
           END-PERFORM.
      *    RESET of WS-REM
           MOVE 0 TO WS-REM.
      *    Country code conversion
           MOVE 'D' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(1).
           MOVE 'E' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(2).
      *
           DISPLAY 'CONVERTED CODE: ' WS-CODE-NUM.
      *
           STRING WS-DE-BLZ       DELIMITED BY SIZE
                  WS-DE-ACCOUNT   DELIMITED BY SIZE
                  WS-CODE-NUM     DELIMITED BY SIZE
                  INTO WS-DE-BBAN-STR
                  WITH POINTER WS-PTR
           END-STRING.
      *
           STRING '00' DELIMITED BY SIZE
                 INTO WS-DE-BBAN-STR
                 WITH POINTER WS-PTR
           END-STRING.
           DISPLAY 'BBAN STR: ' WS-DE-BBAN-STR.
      *    IBAN KEY calculation
           COMPUTE WS-LEN = FUNCTION LENGTH (WS-DE-BBAN-STR).
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
               MOVE WS-DE-BBAN-STR(WS-I:1) TO WS-DIGIT
               COMPUTE WS-REM = WS-REM * 10 + WS-DIGIT
               DIVIDE WS-REM BY 97
                    GIVING WS-QUOTIENT
                    REMAINDER WS-REM
               DISPLAY 'REM: ' WS-REM
           END-PERFORM.
      *
           COMPUTE WS-IBAN-KEY = 98 - WS-REM.
           DISPLAY 'IBAN KEY: ' WS-IBAN-KEY.
           STRING WS-CODE-ALPHA   DELIMITED BY SIZE
                  WS-IBAN-KEY     DELIMITED BY SIZE
                  WS-DE-BLZ       DELIMITED BY SIZE
                  WS-DE-ACCOUNT   DELIMITED BY SIZE
                  INTO WS-DE-FINAL-IBAN
           END-STRING.
           DISPLAY 'FINAL IBAN: ' WS-DE-FINAL-IBAN.

       3000-IBAN-LU.
           DISPLAY '--------------------------------------------------'
      *    Reset WS value used in the previous paragraph
           INITIALIZE WS-BANK.
           INITIALIZE WS-COUNTRY-CODE.
           INITIALIZE WS-CALCULATION.
      *    INITIALIZE reset 0 to the PTR or it needs to be at 1
           MOVE 1 TO WS-PTR IN WS-CALCULATION.
           MOVE 0 TO WS-RETURN.
           INITIALIZE WS-CONVERSION.
           MOVE "LU" TO WS-CODE-ALPHA.
                 CALL 'RANDSUB' USING BY CONTENT "LU", "NEXT",
      -                               BY REFERENCE WS-MAX, WS-RETURN.
                 MOVE WS-RETURN(6:3) TO WS-LU-BANK.
           DISPLAY 'BANK CODE: ' WS-LU-BANK.
      *    Calling 13 times RANDSUB for the 13 digits in the account nbr
           MOVE 13 TO WS-COUNT.
           PERFORM UNTIL WS-COUNT <= 0
              CALL 'RANDSUB' USING BY CONTENT " ", "NEXT",
      -                         BY REFERENCE WS-MAX-ACC-NBR, WS-RETURN
              MOVE WS-RETURN(7:1) TO WS-LU-ACCOUNT (WS-COUNT:1)
              DISPLAY 'ACCOUNT NUMBER: ' WS-LU-ACCOUNT
           SUBTRACT 1 FROM WS-COUNT
           END-PERFORM.
      *    RESET of WS-REM
           MOVE 0 TO WS-REM.
      *    Country code conversion
           MOVE 'L' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(1).
           MOVE 'U' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(2).
      *
           DISPLAY 'CONVERTED CODE: ' WS-CODE-NUM.
      *
           STRING WS-LU-BANK      DELIMITED BY SIZE
                  WS-LU-ACCOUNT   DELIMITED BY SIZE
                  WS-CODE-NUM     DELIMITED BY SIZE
                  INTO WS-LU-BBAN-STR
                  WITH POINTER WS-PTR
           END-STRING.
      *
           STRING '00' DELIMITED BY SIZE
                 INTO WS-LU-BBAN-STR
                 WITH POINTER WS-PTR
           END-STRING.
           DISPLAY 'BBAN STR: ' WS-LU-BBAN-STR.
      *    IBAN KEY calculation
           COMPUTE WS-LEN = FUNCTION LENGTH (WS-LU-BBAN-STR).
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
               MOVE WS-LU-BBAN-STR(WS-I:1) TO WS-DIGIT
               COMPUTE WS-REM = WS-REM * 10 + WS-DIGIT
               DIVIDE WS-REM BY 97
                    GIVING WS-QUOTIENT
                    REMAINDER WS-REM
               DISPLAY 'REM: ' WS-REM
           END-PERFORM.
      *
           COMPUTE WS-IBAN-KEY = 98 - WS-REM.
           DISPLAY 'IBAN KEY: ' WS-IBAN-KEY.
           STRING WS-CODE-ALPHA   DELIMITED BY SIZE
                  WS-IBAN-KEY     DELIMITED BY SIZE
                  WS-LU-BANK      DELIMITED BY SIZE
                  WS-LU-ACCOUNT   DELIMITED BY SIZE
                  INTO WS-LU-FINAL-IBAN
           END-STRING.
           DISPLAY 'FINAL IBAN: ' WS-LU-FINAL-IBAN.
       4000-IBAN-BE.
           DISPLAY '--------------------------------------------------'
      *    Reset WS value used in the previous paragraph
           INITIALIZE WS-BANK.
           INITIALIZE WS-COUNTRY-CODE.
           INITIALIZE WS-CALCULATION.
      *    INITIALIZE reset 0 to the PTR or it needs to be at 1
           MOVE 1 TO WS-PTR IN WS-CALCULATION.
           MOVE 0 TO WS-RETURN.
           INITIALIZE WS-CONVERSION.
           MOVE "BE" TO WS-CODE-ALPHA.
              CALL 'RANDSUB' USING BY CONTENT "BE", "NEXT",
      -                            BY REFERENCE WS-MAX, WS-RETURN.
           MOVE WS-RETURN(6:3) TO WS-BE-BANK.
           DISPLAY 'BANK CODE: ' WS-BE-BANK.
      *    Calling 7 times RANDSUB for the 7 digits in the account nbr
           MOVE 7 TO WS-COUNT.
           PERFORM UNTIL WS-COUNT <= 0
              CALL 'RANDSUB' USING BY CONTENT " ", "NEXT",
      -                         BY REFERENCE WS-MAX-ACC-NBR, WS-RETURN
              MOVE WS-RETURN(7:1) TO WS-BE-ACCOUNT (WS-COUNT:1)
              DISPLAY 'ACCOUNT NUMBER: ' WS-BE-ACCOUNT
           SUBTRACT 1 FROM WS-COUNT
           END-PERFORM.
      *    RESET of WS-REM
           MOVE 0 TO WS-REM.
      *    Country code conversion
           MOVE 'B' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(1).
           MOVE 'E' TO WS-CHAR.
           PERFORM CONVERSION.
           MOVE WS-NUM-VAL TO WS-CONVERTED-CODE(2).
           DISPLAY 'CONVERTED CODE: ' WS-CODE-NUM.
      *
           STRING WS-BE-BANK DELIMITED BY SIZE
                  WS-BE-ACCOUNT DELIMITED BY SIZE
                  INTO WS-BE-BASE-10
           END-STRING.
      *
           DIVIDE WS-BE-BASE-10 BY 97
               GIVING WS-QUOTIENT
               REMAINDER WS-BE-KEY
           MOVE 0 TO WS-QUOTIENT.
           IF WS-BE-KEY = ZERO
               MOVE 97 TO WS-BE-KEY
           END-IF.
           DISPLAY 'BBAN KEY: ' WS-BE-KEY.
      *
           STRING WS-BE-BANK      DELIMITED BY SIZE
                  WS-BE-ACCOUNT   DELIMITED BY SIZE
                  WS-BE-KEY       DELIMITED BY SIZE
                  WS-CODE-NUM     DELIMITED BY SIZE
                  '00'            DELIMITED BY SIZE
                  INTO WS-BE-BBAN-STR
                  WITH POINTER WS-PTR
           END-STRING.
      *
           DISPLAY 'BBAN STR: ' WS-BE-BBAN-STR.
      *    IBAN KEY calculation
           COMPUTE WS-LEN = FUNCTION LENGTH (WS-BE-BBAN-STR).
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
               MOVE WS-BE-BBAN-STR(WS-I:1) TO WS-DIGIT
               COMPUTE WS-REM = WS-REM * 10 + WS-DIGIT
               DIVIDE WS-REM BY 97
                    GIVING WS-QUOTIENT
                    REMAINDER WS-REM
               DISPLAY 'REM: ' WS-REM
           END-PERFORM.
      *
           COMPUTE WS-IBAN-KEY = 98 - WS-REM.
           DISPLAY 'IBAN KEY: ' WS-IBAN-KEY.
           STRING WS-CODE-ALPHA   DELIMITED BY SIZE
                  WS-IBAN-KEY     DELIMITED BY SIZE
                  WS-BE-BANK      DELIMITED BY SIZE
                  WS-BE-ACCOUNT   DELIMITED BY SIZE
                  WS-BE-KEY       DELIMITED BY SIZE
                  INTO WS-BE-FINAL-IBAN
           END-STRING.
           DISPLAY 'FINAL IBAN: ' WS-BE-FINAL-IBAN.
      *
       CONVERSION.
           EVALUATE WS-CHAR
                 WHEN 'A' THRU 'I'
                     COMPUTE WS-NUM-VAL =
                         FUNCTION ORD(WS-CHAR) - FUNCTION ORD('A') + 10
                 WHEN 'J' THRU 'R'
                     COMPUTE WS-NUM-VAL =
                         FUNCTION ORD(WS-CHAR) - FUNCTION ORD('J') + 19
                 WHEN 'S' THRU 'Z'
                     COMPUTE WS-NUM-VAL =
                         FUNCTION ORD(WS-CHAR) - FUNCTION ORD('S') + 28
           END-EVALUATE.
      * WRITE-RECORD.
      *     OPEN OUTPUT IBAN-FILE.
      *     WRITE REC-IBAN.
      *     CLOSE IBAN-FILE.
