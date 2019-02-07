rem order hinzulinken
m2 /l order+%1, %1.app /m/c
cd c:\tsm2_1\work
del %1.exe
rem min heap = 65536, max heap = 131072
setheaps %1.app 1000 2000
