### Santiago Verdu


### This is the line to execute in the psql app that will remove the TransactionsAssignment / transactionsassignment databases before starting.
DROP DATABASE IF EXISTS TransactionsAssignment;
# just in case psql doesn't want to do case conversion
# May not be necessary but it doesn't hurt.
DROP DATABASE IF EXISTS transactionsassignment;

# 1. These are the sql ddl and dml to create and populate the TransactionsAssignment table.

CREATE DATABASE TransactionsAssignment;

### Then in psql, you need to connect to the database. Use this command: 
### \c transactionsassignment

CREATE TABLE Employee (
	id              serial,
	name            varchar(255) not null,
	birthdate       date not null,
	address         varchar(255) not null,
	salary          real not null,
	PRIMARY KEY(id)
);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Bob', '1980-01-08', 'Georgia', 435000.01);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Bill', '1990-12-10', 'Apple St', 85000.22);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Sue', '1975-09-28', 'Arkansas', 65000.33);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Mary', '1968-04-04', 'Michigan St', 75000.42);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Carl', '1996-06-16', 'Millennium Dr.', 95000.64);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Tom', '1999-02-28', 'Apple St', 105000.98);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Joe', '1981-03-24', 'Acorn St', 25000.56);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Larry', '1977-07-21', 'Butterscotch Dr', 40000.12);

INSERT INTO Employee (name, birthdate, address, salary) 
	VALUES('Jill', '1993-11-11', 'Quebec', 50000.44);

### To view the contents of the table, use the following query.

SELECT * FROM Employee;

## ==================================================================================

# 2

CREATE TABLE pet (
	id serial primary key,
	name varchar(255) not null,
	owner varchar(255) not null
);

INSERT INTO pet (name, owner) 
	VALUES('fluffy', 'Bob');

INSERT INTO pet (name, owner) 
	VALUES('patches', 'Joe');

INSERT INTO pet (name, owner) 
	VALUES('sandy', 'Bob');

INSERT INTO pet (name, owner) 
	VALUES('mangy', 'Bob');

INSERT INTO pet (name, owner) 
	VALUES('candy', 'Bob');

INSERT INTO pet (name, owner) 
	VALUES('Rex', 'Larry');

INSERT INTO pet (name, owner) 
	VALUES('voldetort', 'Jill');

INSERT INTO pet (name, owner) 
	VALUES('brownie', 'Bob');

INSERT INTO pet (name, owner) 
	VALUES('blackie', 'Bob');

BEGIN;

	INSERT INTO pet (name, owner)
		VALUES('fdjxxzcrffdsfa', 'Bob');

	DROP TABLE pet;

ROLLBACK TRANSACTION;

### The table still exists after the rollback. The last row inserted does not appear in the table.
### This is so because everything in the transaction is undone when you use the rollback query.

## ==================================================================================

# 3

BEGIN;

	INSERT INTO Employee (name, birthdate, address, salary) VALUES('Bob's Mom, '1993-11-11', 'Quebec', 50000.44);

	INSERT INTO Employee (name, birthdate, address, salary) VALUES('Bobs Mom', '1993-11-11', 'Quebec', 50000.44);

END;

### When I enter the correct version of the query, the database says that the transaction has been aborted.
### This means that the second query is entered, it is ignored.
### It reacts in this manner becuase this will protect the program from breaking.
### The transaction would be aborted and the program could continue on to handle the Rollback error.
### When you enter END; the database does a ROLLBACK. This is to protect the program from unexpected errors.

## ==================================================================================

# 4. The insert functions like it would normally in any other transaction. 

### The drop table instance is just waiting. Nothing is happening and it will not allow me to type anything else into the terminal. 
### It responds this way because there is a hold on that part of the database; it is locked.
### When I commit the insert transaction, the insert goes through. The other transaction in the other window immediately processed the query and states DROP TABLE.
### When I commit the second transaction, the transaction ends and is committed. 
### This happens because the other transaction has finished, the DROP TABLE transaction can go through and drop the table.

### 5. The first select statement gets all of the information about the database you are connected to. 
### It grabs the schema which is public for everything in this case, the relation name (employee) and displays it under Name, 
### the kind of relation (table or sequence) and displays it under type, and finally the relation owner and displays it under owner.
### The FROM section of the query is grabbing all of the necessary information from the pg_namespace and pg_class relations that will contain the information necessary to make the display. 
### It joins the two tables only on viewable options.
### The results are ordered lexicographically by the first column and then the second column if the first column values are the same.

## ==================================================================================

# 6. Deadlock example

CREATE TABLE dtest ( col int );
INSERT INTO dtest SELECT 1;

CREATE TABLE dtest2 ( col int );
INSERT INTO dtest2 SELECT 1;

## In the first instance of psql :
BEGIN;
update dtest set col = 1;

## In the second instance of psql :
BEGIN;
update dtest2 set col = 1;
update dtest set col = 1;
# at this point this psql instance should be locked and waiting.

## In the first instance of psql :
BEGIN;
update dtest2 set col = 1;
# Then there will be a deadlock. psql will void the transactions for both instances and will rollback once you end them.
