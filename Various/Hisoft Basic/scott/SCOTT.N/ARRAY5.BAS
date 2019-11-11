rem          ARRAY5.BAS  displays a table of results, for 5 people.
'
DIM a$(5,2)
for b%=1 to 5
for c%=1 to 2
read a$(b%,c%)
next c%
next b%
'
for a%=1 to 5
print a$(a%,1), a$(a%,2)
next a%
data  John,37,Mike,24,Mary,29,Bill,13,Henry,44
