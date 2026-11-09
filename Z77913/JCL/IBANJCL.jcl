//IBANJCL       JOB 1,NOTIFY=&SYSUID
//***************************************************/
//* Running with the 'IGYCRCTL' compiler */
//STEP1  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(RANDSUB),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(RANDSUB),DISP=SHR
//*
//STEP2  EXEC IGYWCL
//*
//* Path of COBOL PGM */
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(GENIBAN),DISP=SHR
//*
//* Path of the binary execution file */
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(GENIBAN),DISP=SHR
//LKED.SYSLIB   DD
//              DD DSN=CEE.SCEELKED,DISP=SHR
//              DD DSN=&SYSUID..LOAD,DISP=SHR
