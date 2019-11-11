
REM Convert text to XOR command!

a$="This is an example of XOR"
p$="This is the password!"

FOR a=1 TO LEN(a$)
b$=MID$(a$,a,1)
b=ASC(b$)
FOR c=1 TO LEN(p$)
b=b XOR ASC(MID$(p$,c,1))
NEXT c
c$=c$+CHR$(b)
NEXT a

PRINT "'"+a$+"' becomes..."
PRINT "'"+c$+"' when using the password"