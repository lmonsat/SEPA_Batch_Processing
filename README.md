# SEPA Batch Processing (z/OS)

> **Status:** Work in Progress

An end-to-end mainframe banking batch processing pipeline developed on **IBM z/OS** using **COBOL**, **JCL**, and **REXX**. This project simulates a nightly banking clearing cycle using synthetically generated test data, from account creation to balance reconciliation and reporting.

## Architecture & Workflow

1. **Synthetic Account & IBAN Generation (`COBOL`)**
   - Generates valid European IBANs (Modulo 97 check) and initializes customer bank accounts with client IDs, account metadata, and opening balances.
2. **SEPA Transaction Generation (`REXX`)**
   - Produces realistic batches of inter-account SEPA credit transfers and edge-case transactions using fixed-width records.
3. **Batch Clearing, Reconciliation & Reporting (`COBOL`)**
   - Parses incoming SEPA transaction files, validates and processes debits/credits against customer accounts, recalculates updated balances, and generates an execution/audit report.
4. **Job Orchestration (`JCL`)**
   - Automates dataset allocation, step sequencing, and return-code (`MAXCC`) handling across the entire batch chain.

## Tech Stack
- **Environment:** IBM z/OS (TSO/ISPF, SDSF)
- **Languages:** Enterprise COBOL, REXX, JCL
- **Data Management:** Sequential Datasets (`PS`) / VSAM