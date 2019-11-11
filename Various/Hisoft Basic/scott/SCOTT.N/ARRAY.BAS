rem          ARRAY.BAS  displays a table of results, for 3 people.
'
DIM a$(3,2)
for b%=1 to 3
for c%=1 to 2
read a$(b%,c%)
next c%
next b%
'
for a%=1 to 3
print a$(a%,1), a$(a%,2)
next a%
data  John,37,Mike,24,Mary,29
