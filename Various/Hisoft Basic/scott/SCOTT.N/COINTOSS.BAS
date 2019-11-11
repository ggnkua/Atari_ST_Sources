rem         COINTOSS. BAS   Random generator.Any ST or Falcon Resolution.
'
Print "Enter any different number for 'Seed'."
' 
Randomize
'
Print "Type your choice using Capital letter H or T." 
x=rnd
roll$="T"
if x>.5 then roll$="Heads"
input "Heads or Tails ? ",r$
if r$=roll$ then print "You win !" else print "You lose !"
print
print

Print "Run again ? "
