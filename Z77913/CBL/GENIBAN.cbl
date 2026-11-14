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
         05 WS-FR-CODE       PIC A(02) VALUE "FR".
         05 WS-LU-CODE       PIC A(02) VALUE "LU".
         05 WS-DE-CODE       PIC A(02) VALUE "DE".
         05 WS-BE-CODE       PIC A(02) VALUE "BE".
      *
       01 WS-FR-BANK.
         05 WS-BANK-CODE          PIC 9(05).
         05 WS-AGENCY-CODE        PIC 9(05).
         05 WS-BANK-ACCOUNT       PIC X(11).
         05 WS-IBAN-KEY           PIC 9(02).
         05 WS-FULL-RIB           PIC 9(15).
         05 WS-QUOTIENT           PIC 9(15).
         05 WS-RESTE              PIC 9(02).
         05 WS-RIB-KEY            PIC 9(02).
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
      *   05 WS-FR-BBAN       PIC 9(23).
         05 WS-LU-BBAN       PIC X(16).
         05 WS-DE-BBAN       PIC 9(18).
         05 WS-BE-BBAN       PIC 9(12).

       01 WS-ALPHA-EBCDIC   PIC X(62) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZa
      -    "bcdefghijklmnopqrstuvwxyz0123456789".
       01 WS-ALPHA-ASCII    PIC X(62) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZa
      -    "bcdefghijklmnopqrstuvwxyz0123456789".
       01 WS-COUNT           PIC 9(02).

      *------------------
       PROCEDURE DIVISION.
      *------------------
       0000-IBAN-FR.
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

           DIVIDE WS-FULL-RIB BY 97
               GIVING    WS-QUOTIENT
               REMAINDER WS-RESTE.

           COMPUTE WS-RIB-KEY = 97 - WS-RESTE
      *
           GOBACK.
      * CONVERSION.
      *     INSPECT WS-CHAINE-ENTREE
      *         CONVERTING WS-ALPHA-EBCDIC
      *         TO         WS-ALPHA-ASCII.

      * WRITE-RECORD.
      *     OPEN OUTPUT IBAN-FILE.
      *     WRITE REC-IBAN.
      *     CLOSE IBAN-FILE.
