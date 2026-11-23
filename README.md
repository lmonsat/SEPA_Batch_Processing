# SEPA Batch Processing (z/OS)

> **Status:** Work in Progress

An end-to-end mainframe banking batch processing pipeline developed on **IBM z/OS** using **COBOL**, **JCL**, **REXX**, **VSAM**, and **DB2**. This project simulates a nightly interbank SEPA clearing cycle using synthetically generated test data spanning initial data provisioning, multi-tier storage management, balance reconciliation, and regulatory audit reporting.

## Data Architecture

The pipeline uses a hybrid storage model reflecting enterprise mainframe banking architectures, linking relational customer records in **DB2** with high-speed indexed accounts in **VSAM** via a shared `CLIENT_ID` key:

| Dataset / Table | Storage Type | Key / Structure | Role in Pipeline |
| :--- | :--- | :--- | :--- |
| **`TB_CLIENT`** | **DB2 Table** | Primary Key: `CLIENT_ID` | Relational customer master (identity, country, KYC compliance status). |
| **`ACCOUNT`** | **VSAM KSDS** | Primary Key: `IBAN` | Operational account master (`CLIENT_ID`, currency, `COMP-3` balance, status) for direct random-access updates. |
| **`TRANSACTIONS`** | **Sequential (`PS`)** | `RECFM=FB` | Daily incoming batch of inter-account SEPA credit transfers and edge cases. |
| **`LISTIBAN`** | **Sequential (`PS`)** | `RECFM=FB` | Reference list of generated IBANs consumed by the REXX transaction generator. |
| **`TB_MVT_SEPA`** | **DB2 Table** | PK: `TX_ID` / `BATCH_ID` | Persistent audit trail logging settled transactions and ISO 20022 reject codes (`AC01`, `AM04`, `RR04`). |

---

## Architecture & Workflow

1. **Synthetic Master Data Generation (`COBOL`)**
   - Generates customer profiles (`CLIENT_ID`, KYC status) and valid European IBANs (`FR`, `DE`, `LU`, `BE` with Modulo 97 check digits), outputting fixed-width sequential staging files for both clients and accounts.
2. **Infrastructure & Storage Provisioning (`JCL` / `IDCAMS` / `DFSORT` / `DB2`)**
   - **DB2 Setup:** Creates `TB_CLIENT` and `TB_MVT_SEPA` tables via DDL, generates COBOL host variable copybooks via `DCLGEN`, and bulk-loads initial customer records using the DB2 `LOAD` utility.
   - **VSAM Setup:** Sorts initial account records by IBAN via `DFSORT`, defines the `ACCOUNT` **VSAM KSDS** cluster (`DEFINE CLUSTER`), and populates it using `IDCAMS REPRO`.
3. **SEPA Transaction Generation (`REXX`)**
   - Reads `LISTIBAN` to produce realistic batches of SEPA credit transfers, including nominal transfers, unknown IBANs, insufficient funds, and blocked KYC accounts formatted as fixed-width records.
4. **Batch Clearing & Reconciliation (`COBOL` + `VSAM` + `Embedded SQL`)**
   - Reads incoming `TRANSACTIONS` sequentially while performing random-access lookups (`READ` / `REWRITE`) against the `ACCOUNT` KSDS and compliance checks (`SELECT`) against `TB_CLIENT`.
   - Logs every processed or rejected transfer into `TB_MVT_SEPA` with periodic `EXEC SQL COMMIT` checkpoints and standard `FILE STATUS` / `SQLCA` (`SQLCODE`) error handling.
5. **Audit & Post-Processing Reporting (`COBOL` / `DB2` / `IDCAMS`)**
   - Queries `TB_MVT_SEPA` via DB2 SQL cursors to generate a daily clearing summary (volume by country, settlement rate, and rejection breakdown) alongside `IDCAMS LISTCAT` cluster health metrics.
6. **Job Orchestration (`JCL`)**
   - Automates dataset allocation, DB2 precompile/compile/link-edit/bind (`DSNHPC`, `IKJEFT01`), step sequencing, and return-code (`MAXCC`) control across the entire batch chain.

---

## Tech Stack
- **Environment:** IBM z/OS (TSO/ISPF, SDSF, Zowe / VS Code)
- **Languages:** Enterprise COBOL, SQL (Embedded SQL), REXX, JCL
- **Databases & Access Methods:** DB2 for z/OS, VSAM (`KSDS`), QSAM (`PS`)
- **Mainframe Utilities:** 
   - `IDCAMS` (Data and storage management)
   - `DFSORT` (High-speed dataset sorting)
   - `IKJEFT01` (Run DB2 programs)
   - `DSNHPC` (DB2 precompiler)
   - `DCLGEN` (Declarations generator for SQL)
   - DB2 `LOAD` (Loading large amount of data in DB2)