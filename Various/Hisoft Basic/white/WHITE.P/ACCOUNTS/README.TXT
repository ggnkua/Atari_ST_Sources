                      THE HOME ACCOUNTANT

INTRODUCTION

This  BASIC  program  was primarily developed to  help  manage  my 
household  accounts.   It has undergone a number of revisions  and 
enhancements  since  it was originally  conceived.   It  has  been 
stable and under constant use since May 1986.

The  program maintains a date ordered list of transactions for  up 
to  26 accounts in a single random access  file.   Provisions  are 
made  to  be  able to  list,  print,  add,  amend  or  sort  these 
transactions.

Early  use indicated that a number of transactions were  recurring 
every  month  or year.   Facilities have therefore been  added  to 
permit  these  "standing  orders"  to  be  catalogued.   "Standing 
orders" are automatically copied into the transaction file as each 
becomes due.

INSTALLATION

 

Your disk should contain the following file structure:

     \TESTDAT\                empty
     \LIVEDATA\               empty
     ACCOUNTS.BAS                            (13302 bytes)
     CONVERT.BAS                             (2120 bytes)
     README.DOC               this text      (10941 bytes)
     \REPORTS\                empty

If the three empty folders are not present you will need to create
them from the pull-down  File menu.

Two additional files will be created in the \LIVEDATA\ folder when 
the  ACCOUNTS  program is run for the  first  time;   ACCOUNTS.DAT 
which  records  the transactions and STDORDERS.DAT which  keeps  a 
record of the recurring transactions (standing orders).

USERS GUIDE

The operation of the program may be considered in two parts

a) maintenance and use of the transaction file, and
b) maintenance and use of the standing order file.

Each time the program is run, it will prompt for todays date.  The 
program  expects  the date to be supplied in the  form  DD/MMM/YY.  
You  should respond to this prompt and all subsequent  prompts  in 
UPPER CASE.

The menu will then be displayed.   The bottom line of the menu  is 
reserved  for  a  message line.   The format of  the  menu  is  as 
follows:

DD/MMM/YY                                         \LIVE DATA\
                      THE HOME ACCOUNTANT

     1.  Add a transaction         11.  Add a standing order
     2.  Update a transaction      12.  Update a standing order
     3.  List transactions         13.  List standing orders
     4.  Print transactions        14.  Print standing orders
     5.  Sort                      15.  Include standing orders
     6.  List balances             99.  Exit

                    Enter option:

     (message line)

The various options open to you will now be discussed in detail.

OPTION 1 - ADD A TRANSACTION  

This  option  is  used  to add  transactions  to  the  transaction 
database. You enter the following data for each transaction.

a)  Transaction "DATE" in DD/MMM/YY format.   If this is the first 
transaction  entered  then  todays  date will  be  supplied  as  a 
possible default.  If you specify a different date, then this date 
will be supplied as a default for subsequent entries.   To  return 
to the menu from the ADD TRANSACTION option,  reply to this prompt 
with EXIT.

b)   "ACCOUNT"   -   use this field to indicate which  of  the  26 
accounts, A to Z, this transaction belongs.

c)   "REASON"  -  this is a free form field that  you  may  use  to 
annotate  each transaction.   10 characters have been reserved  in 
the transaction file for this.

d)   "AMOUNT"   -  you enter the size of the transaction  in  this 
field.  By convention,  you represent income as a negative number, 
while outgoings are represented by positive numbers.

e)  "REFNO"  -  this is a free form field that you may additonally 
use to annotate a transaction.   By convention, you might use this 
field to record a cheque number etc.

f)   "PROCESSED?"   -   reply to this prompt with "Y"  or  "N"  to 
indicate  that this transaction has "been  processed",  that  is, 
appears  on  a statement for that  account.   Unless  you  specify 
otherwise,  all  new transactions that you add will be  marked  as 
though they have not been processed.

OPTION 2 - UPDATE TRANSACTION

This  option  is  used  to alter the  fields  of  records  in  the 
transaction file.   First,  the program will prompt for the record 
number  of  the record to be changed.   You may alter  any  field, 
however,  if you alter the date field, the file will probably need 
to be sorted.

In order to specify a record to be altered,  you will need to know 
its  record  number.   This  may be achieved  by  using  the  LIST 
TRANSACTIONS option.

OPTION 3 - LIST TRANSACTIONS
OPTION 4 - PRINT TRANSACTIONS

These  options are used to display all of,  or a  subset  of,  the 
records in the transaction file.   The "List Transactions"  option 
displays the records on the screen whilst the "Print Transactions" 
option sends the listing to a file for subsequent printing.

The  program will prompt you for the range of dates between  which 
records  will  be  selected and a list of  those  accounts  to  be 
considered.  An empty list of accounts will list all accounts.

A  by-product  of these two options is that the balances  for  all 
accounts  will be calculated.   Use the "List Balances" option  to 
see the results of these calculations.

OPTION 5 - SORT TRANSACTIONS

Ideally,  the  records in the transaction file should be  in  date 
order.   This  order  may  not be reserved if the  date  field  of 
existing  transactions  are  altered  or  new  records  are  added 
to other than the end of the database.

The  "SORT" option will place the transactions in increasing  date 
order.   Note  that the sort technique used is a modified form  of 
"bubble sort".   This technique is painfully slow if the order  of 
many records needs to be rearranged.   This is often the case when 
you are populating the transaction file for the first time.   Once 
you  have successfully balanced your accounts for the first  time, 
subsequent sort operations take a more reasonable amount of time.

OPTION 6 - LIST BALANCES

You  use this option to display the current status of all of  your 
accounts.   The  option  is only available to you after  you  have 
listed or printed your accounts.   You might elect to list a  non-
existant account to save time accumulating these totals.

The results are displayed in three colums and as many rows as  you 
have accounts.  

The first column lists the totals of those transactions that  have 
been  processed for that account.   For your cheque book  account, 
for instance, this would indicate how much money should be in your 
account.   This  number should,  therefore,  agree with the  total 
shown on your bank statement.   The second column indicates  those 
transactions  that  have  not  yet  reached  your  account.    For 
instance,  cheques that you have written but have not been cleared 
(i.e.  processed) by your bankers.  The third column is the sum of 
the   first  and  second  and  indicates  your  true  assetts   or 
liabilities  for  that  account.    For  your  bank  account,  for 
instance, this would indicate how much would be in your account if 
all cheques had been cleared.

The  total  shown  under the third column  represents  your  total 
assetts  or liabilities.   The process of paying off  your  credit 
card  debts by writing a cheque would alter the balances for  your 
individual accounts but would not affect this "bottom line" total.  
Moving cash around does not (unfortunately) affect your assets  or 
your liabilities!

Options  1  through 6 above are sufficient to enable you  to  keep 
control  over your accounts.   Options 11 through 15 may save  you 
work in the long term.

Options  11 - 15 enable the system to automatically add  recurring 
transactions  to your database on the date that they  become  due.  
Before  this  process  can begin,  you must  define  all  of  your 
recurring transactions and their due dates.

OPTION 11 - ADD A STANDING ORDER

You  define recurring transactions to the system in the  same  way 
that  you add transactions (c.f.  option 1) with the exception  of 
the date field (further described below) and the "processed" field 
which  is  unused.   (Auto  added  transactions  are  never   auto 
confirmed).

The  date  field  for recurring transactions  has  a  format  that 
permits  you to delcare that they become due on any or every  day, 
on any or every month,  on any or every year,  or any  combination 
thereof.

Again, the date is specified in the format DD/MMM/YY.  You specify 
date field that represent "any" by using asterisks (*) as a  place 
holder.  Consider the following by way of examples:

1.  27/***/** Would represent a transaction that would be due  on 
              the 27th of every month of every year (perhaps your 
              salary).

2.  15/***/87 Would   represent  a  transaction  that  would   be 
              included  on  the  15th of  every  month  in  1987, 
              (perhaps a loan repayment).

3.  01/JAN/** Would  represent a transction due on the first  day 
              of   every  year  (perhaps  an   insurance   policy 
              premium).

It  is  possible (though not particularly useful) to  be  able  to 
specify  "every  day".   Similarly,  it is possible to  specify  a 
single non-recurring transaction in this file, perhaps to be added 
to  the  transaction  file at  some  future  time.   In  practice, 
however,  there  is nothing to prevent you from specifying  future 
transactions  in  the  transaction  file using  option  1  -  such 
transactions would not be included in the balances shown on option 
6 until such time as the transaction date arrives.

OPTION 12 - UPDATE A STANDING ORDER
OPTION 13 - LIST STANDING ORDERS
OPTION 14 - PRINT STANDING ORDERS

The  use of these options exactly parallels those of  options  2,3 
and  4 except that they are applied to the  recurring  transaction 
file.

OPTION 15 - INCLUDE STANDING ORDERS

Use  of  this  option causes the program  to  scan  the  recurring 
transaction  file for any transactions which may have  become  due 
since this option was last used.  For each such transaction, a new 
record  will be added to the transaction file.   The records  that 
are added are an exact copy of those in the recurring  transaction 
file except that the date field will have been "filled in".

The  program  uses the first record in the  recurring  transaction 
file  to  record  the last date on which this option  was  used  - 
change it at your peril!

ENDS


