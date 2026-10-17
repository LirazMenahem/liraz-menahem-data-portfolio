--Project 1
--Table Design & Creation

CREATE DATABASE bankLoan 

CREATE TABLE clients
(
ClientID INT IDENTITY (10000,1),
ClientName VARCHAR (255),
Account INT NOT NULL,
Branch INT NOT NULL,
City VARCHAR (255),
BankingType VARCHAR (255)
CONSTRAINT pk_clients PRIMARY KEY (clientID),
CONSTRAINT uq_cAccount_clients UNIQUE(Account),
CONSTRAINT ck_cBranch_clients CHECK (Branch BETWEEN 100 AND 999),
CONSTRAINT ck_cBkTyp CHECK (BankingType IN ('VIP', 'Business', 'Retail', 'Private'))
)
--This table stores profiles of bank customers and contains customer information:
--ID, customer name, account number and branch ((And they have been defined as fields that must be entered), 
--city of residence and banking type from 4 options (detailed in the bankingTypes table).
--The ClientID serves as the Primary Key, auto-incrementing to uniquely identify each client.
--The account column is enforced using a unique constraint so that no two customers can share the same account number.
--Additionally, CHECK constraints are implemented to validate that branch numbers are exactly 3 digits (BETWEEN 100 AND 999).
--The BankingType is limited to only predefined 4 banking types (VIP, Business, Retail, Private) to avoid typing errors.

CREATE TABLE bankers
(
bankerID INT IDENTITY (2000,10),
BankerName VARCHAR (255),
Branch INT NOT NULL,
CONSTRAINT pk_bankers PRIMARY KEY (bankerID),
CONSTRAINT ck_bBranch_bankers CHECK (Branch BETWEEN 100 AND 999)
)

--This table maintains the records of all internal bank bankers:
--banker ID number, his/her name and branch number to which the employee belongs (which defined as a field that must be entered):
--Each banker is associated with one branch.
--It utilizes bankerID as the Primary Key to uniquely identify each banker within the system.
--Similar to the clients table, it includes a CHECK constraint on the Branch column
--to ensure that bankers are assigned only to valid, standardized 3-digit branch numbers.

CREATE TABLE bankingTypes
(
bankingTypeID INT IDENTITY (101,2),
ClientID INT,
bankerID INT,
BankingType VARCHAR (255),
CONSTRAINT pk_bankingTypes PRIMARY KEY (bankingTypeID),
CONSTRAINT ck_bBkTyp CHECK (BankingType IN ('VIP', 'Business', 'Retail', 'Private')),
CONSTRAINT fk_bBkTyp_clients FOREIGN KEY (ClientID) REFERENCES clients(ClientID),
CONSTRAINT fk_bBkTyp_bankers FOREIGN KEY (bankerID) REFERENCES bankers(bankerID)
)

--This table connects each client to their specific banker, shows what type of banking tier applies to their relationship and contains:
--bankingType ID number, Client ID number, banker ID number and there are 4 types of banking to which a customer belongs:
--VIP, Business, Retail, Private.
--Each banker belongs to only one banking type, but the same banker can be associated with multiple customers.
--The table utilizes bankingTypeID as the Primary Key to uniquely identify each bankingType.
--There are 2 foreign key constraints on ClientID and bankerID to link them to the previous tables.
--It also contains a CHECK constraint to validate the specific operational from what is written above.

CREATE TABLE loans
(
loanID INT IDENTITY (500,5),
ClientID INT,
Principal INT NOT NULL,
Interest INT NOT NULL,
CreditScore INT NOT NULL,
CONSTRAINT pk_loans PRIMARY KEY (loanID),
CONSTRAINT ck_Principal CHECK (Principal > 0),
CONSTRAINT ck_Interest CHECK (Interest >= 0),
CONSTRAINT ck_lCreSco CHECK (CreditScore BETWEEN 300 AND 850),
CONSTRAINT fk_loans_clients FOREIGN KEY (ClientID) REFERENCES clients(ClientID)
)

--This table manages the records of financial loans issued by the bank to its borrowers and contains:
--Loan ID number, Client ID number, loan amount divided into principal and interest,
--and CreditScore according to the customer's credit report (defined as values ​​that must be entered).
--In the data file, the Interest rate is displayed as a round number (not a decimal/Float).
--A primary key has been defined for loanID that distinguishes each record from another record.
--A primary key has been defined for the ClientID of the customer from the customer table.
--A single customer can take out several separate loans over time, but each loan is associated only with one specific customer.
--The table enforces critical financial business logic using CHECK constraints:
--The loan principal must be greater than 0 (a positive number), the interest rate cannot be negative but can be equal to 0
-- (because there are interest-free loans for the purpose of customer recruitment/retention).
--And the CreditScore must fall within the standard credit risk spectrum (300 to 850).

CREATE TABLE loanPayments
(
paymentID INT IDENTITY (1,20),
loanID INT,
MonthlyPayment FLOAT NOT NULL,
StartDate DATETIME,
EndDate DATETIME,
CONSTRAINT pk_loanPayments PRIMARY KEY (paymentID),
CONSTRAINT ck_MPayment CHECK (MonthlyPayment > 0),
CONSTRAINT ck_Dates CHECK (EndDate > StartDate),
CONSTRAINT fk_loPay_loans FOREIGN KEY (loanID) REFERENCES loans(loanID)
)

--This table tracks individual monthly repayment installments linked to active loans and contains:
--Payment ID number, loan ID number, average monthly repayment amount in decimal, and loan payment start and end dates.
--A primary key has been defined for paymentID to distinguish each payment from another for each loan.
--A foreign key has been defined that links loanID to the table before it (the loans table),
--as a single loan is paid off via multiple scheduled installments.
--It enforces strict chronological integrity using a CHECK constraint ensuring that
--the loan's maturity/payment EndDate always succeeds the StartDate,
--while also ensuring that the MonthlyPayment amount is strictly greater than 0.


--Inserting records into tables:
INSERT INTO bankers (BankerName,Branch)
SELECT DISTINCT BankerName,Branch
FROM [bank Loan]

INSERT INTO clients (ClientName,Account,Branch,City,BankingType)
SELECT DISTINCT ClientName,Account,Branch,City,BankingType
FROM [bank Loan]

INSERT INTO bankingTypes (ClientID,bankerID,BankingType)
SELECT DISTINCT c.ClientID, b.bankerID, bl.BankingType
FROM [bank Loan] bl JOIN clients c
ON bl.Account=c.Account
JOIN bankers b
ON bl.BankerName=b.BankerName

INSERT INTO loans (ClientID,Principal,Interest,CreditScore)
SELECT c.ClientID, bl.Principal, bl.Interest, bl.CreditScore
FROM [bank Loan] bl JOIN clients c
ON bl.Account = c.Account

INSERT INTO loanPayments (loanID,MonthlyPayment,StartDate,EndDate)
SELECT l.loanID, bl.MonthlyPayment, bl.StartDate, bl.EndDate
FROM [bank Loan] bl JOIN clients c
ON bl.Account = c.Account
JOIN loans l
ON c.ClientID = l.ClientID

--I wanted to remove the Banking Type column from the clients table because
--I realized it creates duplication of information:
ALTER TABLE clients
DROP CONSTRAINT ck_cBkTyp

ALTER TABLE clients
DROP COLUMN BankingType

--NOTE:
--At first, I wanted to create a Foreign Key on the Branch column to link clients and bankers directly.
--However, a Foreign Key must point to a Unique or Primary Key. Since a branch number appears multiple times in 
--both tables (many clients and many bankers share the same branch), this direct link was not possible.
--Instead, the tables are already connected through the bankingTypes relationship table, which maps
--each client to their specific banker within the same branch.