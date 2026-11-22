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
       01 WS-COUNTRY-CODE.
         05 WS-CODE-ALPHA       PIC A(02).
         05 WS-CODE-NUM-GROUP.
           10 WS-CODE OCCURS 2 TIMES PIC A(01).
         05 WS-CONVERTED-CODE-GROUP.
           10 WS-CONVERTED-CODE OCCURS 2 TIMES PIC 9(02).
         05 WS-CODE-NUM REDEFINES WS-CONVERTED-CODE-GROUP PIC 9(04).
      *
       01 WS-FR-BANK.
         05 WS-FINAL-IBAN         PIC X(27).
         05 WS-BANK-CODE          PIC 9(05).
         05 WS-AGENCY-CODE        PIC 9(05).
         05 WS-BANK-ACCOUNT       PIC 9(11).
         05 WS-FULL-RIB           PIC 9(15).
         05 WS-CODE-VAL           PIC 9(06).
         05 WS-IBAN-KEY           PIC 9(02).
         05 WS-RIB-KEY            PIC 9(02).
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
       01 WS-DE-BANK.
         05 WS-BANK-DB          PIC 9(08) VALUE 10070000.
         05 WS-BANK-CB          PIC 9(08) VALUE 50040000.
         05 WS-BANK-PB          PIC 9(08) VALUE 20010020.
      *
       01 WS-LU-BANK.
         05 WS-BANK-SGL         PIC 9(03) VALUE 061.
         05 WS-BANK-BIL         PIC 9(03) VALUE 002.
         05 WS-BANK-AVZ         PIC 9(03) VALUE 344.
      *
       01 WS-BE-BANK.
         05 WS-BANK-BF          PIC 9(03) VALUE 050.
         05 WS-BANK-CBC         PIC 9(03) VALUE 190.
         05 WS-BANK-KBC         PIC 9(03) VALUE 733.
      *
       01 WS-RETURN          PIC 9(08).
       01 WS-MAX             PIC 9(03) VALUE 3.
       01 WS-MAX-AGENCY      PIC 9(03) VALUE 99.
       01 WS-MAX-ACC-NBR     PIC 9(01) VALUE 9.
       01 WS-TEMP            PIC 9(01).
      *
       01 WS-COUNTRY-BBAN.
         05 WS-FR-BBAN-STR       PIC X(29).
         05 WS-LU-BBAN-STR       PIC X(16).
         05 WS-DE-BBAN-STR       PIC 9(18).
         05 WS-BE-BBAN-STR       PIC 9(12).
      *
       01 WS-ALPHA-EBCDIC   PIC X(62) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZa
      -    "bcdefghijklmnopqrstuvwxyz0123456789".
       01 WS-ALPHA-ASCII    PIC X(62) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZa
      -    "bcdefghijklmnopqrstuvwxyz0123456789".
       01 WS-COUNT           PIC 9(02).
      *------------------
       PROCEDURE DIVISION.
      *------------------
       0000-IBAN-FR.
           MOVE "FR" TO WS-CODE-ALPHA.
           CALL 'RANDSUB' USING BY CONTENT "FR", "INIT",
      -                         BY REFERENCE WS-MAX, WS-RETURN.
           MOVE WS-RETURN(4:5) TO WS-BANK-CODE.
           DISPLAY 'BANK CODE: ' WS-BANK-CODE.
      *
           CALL 'RANDSUB' USING BY CONTENT " ", "NEXT",
      -                         BY REFERENCE WS-MAX-AGENCY, WS-RETURN.
           MOVE WS-RETURN(4:5) TO WS-AGENCY-CODE.
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
           GOBACK.
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
