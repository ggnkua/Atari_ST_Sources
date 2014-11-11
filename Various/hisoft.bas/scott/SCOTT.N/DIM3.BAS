rem      DIM3.BAS   see also ARRAY53,array demo, 3 columns of 4 entries
'
Dim a$(4),b$(4),n$(4)           ' adjust the '4' for the number of entries.
Print "Enter Name, Initial, and Phone Number"
for n%=1 to 4                   ' adjust the 4
Input "Name ";a$(n%)
Input "Initial ";b$(n%)
Input "Number ";n%(n%)
next n%
cls
'
for n%=1 to 4                    ' adjust the 4
print;tab(5)a$(n%);tab(15)b$(n%);tab(25)n%(n%)
next n%


