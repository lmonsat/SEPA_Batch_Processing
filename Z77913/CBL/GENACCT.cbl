      *-----------------------
       IDENTIFICATION DIVISION.
      *-----------------------
       PROGRAM-ID.    GENACCT
       AUTHOR.        Monsat Lilian
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *     SELECT IBAN-FILE    ASSIGN TO IBANLIST
      *                         ORGANIZATION IS SEQUENTIAL
      *                         ACCESS MODE  IS SEQUENTIAL.
      *
      *     SELECT ACCOUNT-FILE ASSIGN TO ACCTLIST
      *                         ORGANIZATION IS SEQUENTIAL
      *                         ACCESS MODE  IS SEQUENTIAL.
      *-------------
       DATA DIVISION.
      *-------------
       FILE SECTION.
      * FD  IBAN-FILE     RECORDING MODE F
      *                   BLOCK CONTAINS 0 RECORDS
      *                   RECORD CONTAINS 120 CHARACTERS.
      * 01  REC-IBAN.
      *   05 IBAN       PIC X(27).
      *   05 FILLER     PIC X(93).
      *
      * FD  ACCOUNT-FILE  RECORDING MODE F
      *                   BLOCK CONTAINS 0 RECORDS
      *                   RECORD CONTAINS 120 CHARACTERS.
      * 01  REC-ACCOUNT.
      *   05 ACC-IBAN             PIC X(34).
      *   05 ACC-CLIENT-ID        PIC X(10).
      *   05 ACC-CURRENCY         PIC X(03).
      *   05 ACC-BALANCE          PIC S9(11)V99 COMP-3.
      *   05 ACC-STATUS           PIC X(01).
      *   05 ACC-LAST-DATE        PIC X(10).
      *   05 FILLER               PIC X(54).
      *
       WORKING-STORAGE SECTION.
      *
       01  WS-ACCOUNT.
         05 WS-ACC-IBAN             PIC X(34).
         05 WS-ACC-CLIENT-ID        PIC X(10).
         05 WS-ACC-CURRENCY         PIC X(03).
         05 WS-ACC-BALANCE          PIC S9(11)V99 COMP-3.
         05 WS-ACC-STATUS           PIC X(01).
         05 WS-ACC-LAST-DATE        PIC X(10).

      *------------------
       PROCEDURE DIVISION.
      *------------------
      *
       0000-MAIN.

           GOBACK.
