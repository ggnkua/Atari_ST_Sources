rem      LOTTERY.BAS  displays 6 random numbers, 1 to 49
'
t!=timer              ' time in 1/200s of a second since Booting the ST.
randomize t!          ' creates a random time figure.
for n=1 to 6
x=(rnd*49)+1
Print INT(x)
'Lprint INT(x)        ' remove  '  for hardcopy
next n