\cp68 -D%1 %2.c M:\%2.i
\c068 M:\%2.i M:\%2.1 M:\%2.2 M:\%2.3 -f
del M:\%2.i
\c168 M:\%2.1 M:\%2.2 %2.s
del M:\%2.1
del M:\%2.2
oldasm %2.s
del %2.s
