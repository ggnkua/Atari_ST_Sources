rem       RAND_GEN.BAS       Random number generator, 1 to 49 inclusive.
'             displays 17 rows of 6 random numbers.
'
t!=timer              ' time in 1/200s of a second since Booting the ST.
randomize t!
for n=1 to 102        ' 6*17=102
x=INT(rnd*49)+1
print x,              ' the comma sets 6 columns.
'LPRINT x,            ' remove  '  for hard copy.
next n
