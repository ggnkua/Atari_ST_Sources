REM $include G:\turtle\turtle.bas

' here comes the fun
' recursion can be a headache
' this procedure will run until a math overflow

SUB poly(side,angle)
STATIC i
fwd side
right angle
poly side,angle
END SUB

' spirals give us a chance to control the recursion
' therefore preventing errors

SUB polyspi(side,angle)
IF side>150 THEN EXIT SUB
fwd side
right angle
polyspi side+5,angle
END SUB

' polyspi 10,144
' try different values for the second parameter

' another example of recursion is a binary tree
' where a tree like structure is made by recursive calls
' to a procedure called branch

SUB branch(length,level)
IF level=0 THEN EXIT SUB
fwd length
left 45
branch length/2,level-1
right 90
branch length/2,level-1
left 45
back length
END SUB

' left 90
' cury=120
' branch 50,5

' or for a more realistic tree try this

SUB branch1(length,level)
IF level=0 THEN EXIT SUB
fwd length
left 30
branch1 length/3,level-1
right 40
branch1 length/2,level-1
right 50
branch1 length/1.5,level-1
left 60
back length
END SUB

' left 90
' cury=120
' branch1 50,5


' you may like to try adding a random number element
' which would produce variation in the tree
