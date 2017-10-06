;
;	Schleuder erzeugt immer wieder Abk”mmlinge von sich,
;	und zwar im Abstand der Fibonaccschen Zahlen
;

	JMP	main

dest	DAT	0		; hierhin wird kopiert
src	DAT	0		; von dort wird kopiert
length	DAT	0		; die Programml„nge

start:
fibsum	DAT	377		; hier steht dann das neue Programm
fib1	DAT	233		; die letzte Fibonaccsche Zahl
fib2	DAT	144		; die vorletzte

	proglen = progend-start ; Programml„nge

main:
	MOV	#start-src,src
	MOV	#proglen,length
	MOV	fibsum,dest
loop	MOV	src>,dest>
	DJN	loop,length

	SPL	@fibsum

	MOV	fib1,fib2
	MOV	fibsum,fib1
	ADD	fib2,fibsum
	JMP	main
progend:

