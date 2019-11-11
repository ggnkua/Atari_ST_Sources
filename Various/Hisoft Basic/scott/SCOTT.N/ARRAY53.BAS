rem       ARRAY53.BAS  displays 3 column table of results, for 5 people.
'
DIM a$(5,3)
for b%=1 to 5
for c%=1 to 3
read a$(b%,c%)
next c%
next b%
'
Print
Print "    ";"Name,     Mark,       Grade."
print
for a%=1 to 5
print "    ";a$(a%,1), a$(a%,2), a$(a%,3)
next a%
data  John,37,B,Mike,24,C,Mary,29,C,Bill,13,D,Henry,44,A
