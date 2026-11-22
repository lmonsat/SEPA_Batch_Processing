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
      * --- Structure for CURRENT-DATE  ---
       01 WS-CURRENT-DATE-DATA.
           02 WS-CURRENT-DATE-21.
              03 WS-DATE.
                 04 WS-YYYY           PIC 9(04).
                 04 WS-MM             PIC 9(02).
                 04 WS-DD             PIC 9(02).
              03 WS-TIME.
                 04 WS-TIME-HH        PIC 9(02).
                 04 WS-TIME-MM        PIC 9(02).
                 04 WS-TIME-SS        PIC 9(02).
                 04 WS-TIME-HUND      PIC 9(02).
              03 WS-DIFF-FROM-GMT.
                 04 WS-DIFF-SIGN      PIC X(01).
                 04 WS-DIFF-HOURS     PIC 9(02).
                 04 WS-DIFF-MINUTES   PIC 9(02).
      *-------------------------------------------
       01 WS-SEED           PIC 9(18).
       01 WS-RANDOM-VAL     PIC 9(18) COMP.
       01 WS-QUOTIENT       PIC 9(18) COMP.
       01 WS-VAL            PIC 9(02).
       01 WS-ACCOUNT-NBR    PIC 9(01).
       LINKAGE SECTION.
      *
       01 LK-FULL-COUNTRY-CODE       PIC A(02).
       01 LK-RAND               PIC A(04).
       01 LK-MAX                PIC 9(03).
       01 LK-RETURN             PIC 9(08).
      *------------------
       PROCEDURE DIVISION USING LK-FULL-COUNTRY-CODE, LK-RAND,
      -                                               LK-MAX, LK-RETURN.
      *------------------
       0000-MAIN.
      *    Getting current-date 'MMSSDD'
      *    INIT FLAG used to generate the seed only once
      *    Instead of current-date, use ACCEPT MVS : (format: 'MMSSDD')
      *    ACCEPT WS-TIME-NOW FROM TIME.
           IF LK-RAND = "INIT"
              MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-21
              STRING WS-TIME-MM DELIMITED BY SIZE
                     WS-TIME-SS DELIMITED BY SIZE
                     WS-TIME-HUND DELIMITED BY SIZE
                     INTO WS-SEED
              END-STRING
              DISPLAY "SEED: " WS-SEED
           END-IF.
           PERFORM 1000-NEXT-RAND.
      *    Between 1 and LK-MAX
           DIVIDE WS-RANDOM-VAL BY LK-MAX
                  GIVING WS-QUOTIENT
                  REMAINDER WS-VAL.
           ADD 1 TO WS-VAL.
           EVALUATE LK-FULL-COUNTRY-CODE
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
      *    LCG Algorithm to generate a random number based on SEED
      *    Seed = (Seed * 1103515245 + 12345) MOD 2147483647
       1000-NEXT-RAND.
              COMPUTE WS-SEED = (WS-SEED * 1103515245 + 12345)
              DIVIDE WS-SEED BY 2147483647
                 GIVING WS-QUOTIENT
                 REMAINDER WS-RANDOM-VAL.
              MOVE WS-RANDOM-VAL TO WS-SEED.
