#NO_APP
.text
LC0:
	.ascii "Archive truncated in file %s\12\0"
LC1:
	.ascii "Testing file: %-12s  \0"
LC2:
	.ascii "okay\12\0"
LC3:
	.ascii "No errors detected\12\0"
LC4:
	.ascii "One error detected\12\0"
LC5:
	.ascii "%d errors detected\12\0"
	.even
.globl _tstarc
_tstarc:
	link a6,#-28
	moveml #0x3020,sp@-
	clrw sp@-
	jbsr _openarc
	movew #2,sp@-
	clrl sp@-
	movel _arc,sp@-
	lea _fseek,a2
	jbsr a2@
	movel _arc,sp@-
	jbsr _ftell
	movel d0,d3
	clrw sp@-
	clrl sp@-
	movel _arc,sp@-
	jbsr a2@
	addw #26,sp
	moveq #-28,d2
	addl a6,d2
	jra L2
L8:
	movel _arc,sp@-
	jbsr _ftell
	addl a6@(-14),d0
	addqw #4,sp
	cmpl d0,d3
	jge L4
	movel d2,sp@-
	pea LC0
	jbsr _printf
	addqw #1,_nerrs
	addqw #8,sp
	jra L3
L4:
	movel d2,sp@-
	pea LC1
	jbsr _printf
	movel __io_table+4,sp@-
	jbsr _fflush
	movel d2,sp@-
	clrw sp@-
	movel _arc,sp@-
	jbsr _unpack
	addw #22,sp
	tstw d0
	jeq L6
	addqw #1,_nerrs
	jra L2
L6:
	pea LC2
	jbsr _printf
	addqw #4,sp
L2:
	movel _arc,sp@-
	movel d2,sp@-
	jbsr _readhdr
	addqw #8,sp
	tstw d0
	jne L8
L3:
	tstw _nerrs
	jgt L9
	pea LC3
	jbsr _printf
	jra L10
L9:
	cmpw #1,_nerrs
	jne L11
	pea LC4
	jbsr _printf
	jra L10
L11:
	movew _nerrs,sp@-
	pea LC5
	jbsr _printf
L10:
	moveml a6@(-40),#0x40c
	unlk a6
	rts
