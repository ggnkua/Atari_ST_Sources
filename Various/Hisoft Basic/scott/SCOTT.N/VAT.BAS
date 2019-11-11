REM       VAT.BAS   Calculates VAT at 17.5%  Any resolution.
REM Set variables to Zero
V=0
S=0
T=0
PRINT  "              VAT at 17.5% "  ' Title; adjust amount in Editor.
PRINT
PRINT
INPUT "Initial sum in œ";S            ' type in initial sum.
v=1.175                               ' adjust if needed
T=S*V                                 ' Total will be Sum*VAT factor.
Print "Extra due to VAT = œ";T-S
PRINT
PRINT "Total including VAT œ";T
 
