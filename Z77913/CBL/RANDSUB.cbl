      *-----------------------
       IDENTIFICATION DIVISION.
      *-----------------------
       PROGRAM-ID.    RANDSUB
       AUTHOR.        Monsat Lilian
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------

      *-------------
       DATA DIVISION.
      *-------------
       WORKING-STORAGE SECTION.
      *
       01 WS-FR-BANK.
      *  Societe General
         05 WS-BANK-SG          PIC 9(05) VALUE 30003.
      *  Credit Agricole (Paris)
         05 WS-BANK-CA          PIC 9(05) VALUE 18206.
      *  Caisse d'Epargne (Paris)
         05 WS-BANK-CE          PIC 9(05) VALUE 17515.
       01 WS-FR-BANK-TABLE REDEFINES WS-FR-BANK.
           05 WS-FR-BANK-CODE       PIC 9(05) OCCURS 3 TIMES.
      *
       01 WS-DE-BANK.
      *  Deutsche Bank (Berlin)
         05 WS-BANK-DB          PIC 9(08) VALUE 10070000.
      *  CommerzBank (Francfort)
         05 WS-BANK-CB          PIC 9(08) VALUE 50040000.
      *  PostBank (Hambourg)
         05 WS-BANK-PB          PIC 9(08) VALUE 20010020.
       01 WS-DE-BANK-TABLE REDEFINES WS-DE-BANK.
           05 WS-DE-BANK-CODE       PIC 9(08) OCCURS 3 TIMES.
      *
       01 WS-LU-BANK.
      *  Societe General Luxembourg
         05 WS-BANK-SGL         PIC 9(03) VALUE 061.
      *  BIL
         05 WS-BANK-BIL         PIC 9(03) VALUE 002.
      *  Advanzia Bank
         05 WS-BANK-AVZ         PIC 9(03) VALUE 344.
       01 WS-LU-BANK-TABLE REDEFINES WS-LU-BANK.
           05 WS-LU-BANK-CODE       PIC 9(03) OCCURS 3 TIMES.
      *
       01 WS-BE-BANK.
      *  Belfius
         05 WS-BANK-BF          PIC 9(03) VALUE 050.
      *  CBC Bank
         05 WS-BANK-CBC         PIC 9(03) VALUE 190.
      *  KBC Bank
         05 WS-BANK-KBC         PIC 9(03) VALUE 733.
       01 WS-BE-BANK-TABLE REDEFINES WS-BE-BANK.
           05 WS-BE-BANK-CODE       PIC 9(03) OCCURS 3 TIMES.
      *
       01 WS-SEED           PIC 9(08).
       01 WS-RANDOM-VAL     PIC 9(03)V9(05).
       01 WS-VAL            PIC 9(02).
       LINKAGE SECTION.
      *
       01 LK-COUNTRY-CODE       PIC A(02).
       01 LK-MAX                PIC 9(03).
       01 LK-RETURN             PIC 9(08).
      *------------------
       PROCEDURE DIVISION USING LK-COUNTRY-CODE, LK-MAX, LK-RETURN.
      *------------------
       GEN-IBAN.
      *    Getting current-date 'HHMMSSDD'
           MOVE FUNCTION CURRENT-DATE (9:8) TO WS-SEED.
      *    Randomizing nbr using the seed
           COMPUTE WS-RANDOM-VAL = FUNCTION RANDOM (WS-SEED).
      *    Between 1 and LK-MAX
           COMPUTE WS-VAL = FUNCTION INTEGER
      -                                    (WS-RANDOM-VAL * LK-MAX) + 1.
           EVALUATE LK-COUNTRY-CODE
              WHEN "FR"
                 MOVE WS-FR-BANK-CODE (WS-VAL) TO LK-RETURN
              WHEN "LU"
                 MOVE WS-LU-BANK-CODE (WS-VAL) TO LK-RETURN
              WHEN "DE"
                 MOVE WS-DE-BANK-CODE (WS-VAL) TO LK-RETURN
              WHEN "BE"
                 MOVE WS-BE-BANK-CODE (WS-VAL) TO LK-RETURN
              WHEN OTHER
                 MOVE WS-VAL TO LK-RETURN
           END-EVALUATE.
           GOBACK.
