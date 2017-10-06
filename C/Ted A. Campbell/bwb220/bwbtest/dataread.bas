10 rem DATAREAD.BAS -- Test DATA, READ, and RESTORE Statements 
20 print "DATAREAD.BAS -- Test DATA, READ, and RESTORE Statements" 
30 DATA "Ted", 56.789 
40 REM just to see if it advances correctly 
50 DATA "Dale", 45.678 
	60 READ N$, NUMBER, ANOTHER$ 
	70 READ ANUMBER 
	80 PRINT "Data read: ";N$;" ";NUMBER;" ";ANOTHER$;" ";ANUMBER 
90 RESTORE 30 
	100 READ ANOTHER$ 
	110 READ ANUMBER, N$,NUMBER 
	120 PRINT "After RESTORE:" 
	130 PRINT "Data read: ";ANOTHER$;" ";ANUMBER;" ";N$;" ";NUMBER 
140 END 
