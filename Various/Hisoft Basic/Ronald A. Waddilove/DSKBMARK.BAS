REM Disk drive benchmarks

?:? " Calculating disk benchmarks...":?

REM ----- Write 500k block -----
DIM a%(260000)
t! = TIMER
BSAVE "test.dat",VARPTR(a%(0)),512000
t! = TIMER - t!
? " Time to write 500k =";t!;"s"

REM ----- Read 500k block -----
t! = TIMER
BLOAD "test.dat",VARPTR(a%(0))
t! = TIMER - t!
? " Time to read 500k =";t!;"s"

REM ----- Write 30,000 bytes forwards -----
t! = TIMER
OPEN "R",#1,"test.dat",1
FIELD #1,1 AS buffer$
LSET buffer$ = CHR$(0)
FOR i% = 1 TO 30000
	PUT #1
NEXT
CLOSE #1
t! = TIMER - t!
? " Time to write 30,000 bytes forwards =";t!;"s"

REM ----- Read 30,000 bytes forwards -----
t! = TIMER
OPEN "R",#2,"test.dat",1
FIELD #2,1 AS buffer$
FOR i% = 1 TO 30000
	GET #2
NEXT
CLOSE #2
t! = TIMER - t!
? " Time to read 30,000 bytes forwards =";t!;"s"

REM ----- Write 30,000 bytes backwards -----
t! = TIMER
OPEN "R",#3,"test.dat",1
FIELD #3,1 AS buffer$
LSET buffer$ = CHR$(0)
FOR i% = 30000 TO 1 STEP -1
	PUT #3,i%
NEXT
CLOSE #3
t! = TIMER - t!
? " Time to write 30,000 bytes backwards =";t!;"s"

REM ----- Read 30,000 bytes backwards -----
t! = TIMER
OPEN "R",#4,"test.dat",1
FIELD #4,1 AS buffer$
FOR i% = 30000 TO 1 STEP -1
	GET #4,i%
NEXT
CLOSE #4
t! = TIMER - t!
? " Time to read 30,000 bytes backwards =";t!;"s"

REM ----- Seek test reading 30,000 bytes -----
t! = TIMER
OPEN "R",#5,"test.dat",1
FIELD #5,1 AS buffer$
FOR i% = 1 TO 29999
	GET #5,i%
	GET #5,30000-i%
NEXT
CLOSE #5
t! = TIMER - t!
? " Time for seek test =";t!;"s"

END
