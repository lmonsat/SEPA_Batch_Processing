//REXXJCL       JOB 1,NOTIFY=&SYSUID
//*----+----1----+----2----+----3----+----4----+----5----+----6----+----7--
//***********************************************/
//* Ordre d'execution :
//* 1. Premier programme COBOL generations d'IBAN
//* 2. Premier programme REXX generation de transaction SEPA
//* 3. Dernier programme REXX generation de compte client
//* 4. Dernier programme COBOL de calcul de solde
//***********************************************/
//* Execution of the COBOL program /
//CBL     EXEC PGM=GENIBAN
//STEPLIB      DD DSN=&SYSUID..LOAD,DISP=SHR
//* Adding the output file used to print IBAN /
//IBANLIST     DD DSN=&SYSUID..ACCOUNT,DISP=SHR
//PRTLINE      DD SYSOUT=*,OUTLIM=1000
//SYSOUT       DD SYSOUT=*,OUTLIM=1000
//CEEDUMP      DD DUMMY
//SYSUDUMP     DD DUMMY
//*
//* Delete the TRX file if already created
//* And set the CC=0 to avoid getting cc=0008,
//* If TRX has not been created
//DELTRX  EXEC PGM=IDCAMS
//SYSPRINT     DD SYSOUT=*
//PDS          DD DSN=&SYSUID..SEPA,
//             DISP=SHR
//SYSIN        DD *
  DELETE 'Z77913.SEPA(TRX)' FILE(PDS)
  IF LASTCC = 8 THEN SET MAXCC = 0
/*
//* Execution of the REXX script to generate SEPA transaction /
//REXX1   EXEC PGM=IRXJCL,PARM='GENSEPA'
//SYSEXEC      DD DSN=&SYSUID..REXX,DISP=SHR
//SEPAIN       DD DSN=&SYSUID..SEPA(TRX),DISP=MOD
//LISTACC      DD DSN=&SYSUID..ACCOUNT(IBANLIST),DISP=MOD
//SYSTSPRT     DD SYSOUT=*,OUTLIM=1000
//SYSOUT       DD SYSOUT=*,OUTLIM=1000
//SYSIN        DD DUMMY
//***********************************************/
//* IF RC = 0 THEN
//* Execution of the REXX script to generate Clients accounts */
//*
//* ELSE
//* ENDIF
//***************************************************/
//* CREER Z77913.SEPA, DELETE ET RECREER SEULEMENT TRX
//* CELA REGLERA PROBLEME DATASET HAVE NOT SPACE SPECIFIED
