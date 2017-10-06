LIBRARY "gemdos"
DEFINT a-z

a$=BIN$(tgetdate)
PRINT "HBASIC date:"+DATE$
PRINT "The REAL date is:"

day=VAL("&B"+MID$(a$,LEN(a$)-4,5))
month=VAL("&B"+MID$(a$,LEN(a$)-8,4))
l=LEN(a$)-9
year=VAL("&B"+MID$(a$,1,l))
PRINT day;"/";month;"/";1980+year
