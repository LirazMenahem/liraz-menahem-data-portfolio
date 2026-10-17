# Project 1: Table Design & Creation (SQL Server)

> Project page: [PUT-YOUR-HTML-LINK-HERE](PUT-YOUR-HTML-LINK-HERE)

## Overview
Design and build of a relational database (`bankLoan`) for a bank's loan portfolio,
starting from a single flat spreadsheet and normalizing it into five related tables.

## Database structure
| Table | Purpose |
|-------|---------|
| `clients` | Client profile: name, account, branch, city |
| `bankers` | Bank employees and their branch |
| `bankingTypes` | Links each client to a banker and a banking tier (VIP, Business, Retail, Private) |
| `loans` | Loan principal, interest and client credit score |
| `loanPayments` | Monthly payment and loan start / end dates |

## Design decisions
- **Primary keys** with `IDENTITY` on every table, and a `UNIQUE` constraint on account number.
- **Foreign keys** connecting clients, bankers, loans and payments.
- **CHECK constraints** that enforce business rules:
  - branch number must be 3 digits (100-999)
  - banking type limited to 4 allowed values
  - principal > 0, interest >= 0, credit score between 300 and 850
  - loan end date must be later than start date
- **Normalization:** the `BankingType` column was removed from `clients` to avoid duplicated information (it lives in `bankingTypes`).

## Files
- `Table_Design_Creation.sql` - table creation, data insertion and schema changes
- `data/` - the source spreadsheet loaded into the tables

## How to run
1. Import the spreadsheet into SQL Server as a table named `[bank Loan]`.
2. Run `Table_Design_Creation.sql`.

## Skills demonstrated
`CREATE TABLE` · keys and constraints · normalization · `INSERT ... SELECT` · `ALTER TABLE`
