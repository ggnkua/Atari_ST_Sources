*********************************************
*               Verify a disc               *
*             By Liisa Forstii              *
*         Atari ST User April 1988          *
*                                           *
*             Assemble to disk              *
*       with the filename VERIFY.TOS        *
*                                           *
*********************************************

pstring MACRO
	lea \1(pc),a0
	bsr string
	ENDM

*********************************************
*	       Start of program             *
*********************************************
	move #1,-(a7)  	    Switch cursor off
	move #0,-(a7)
	move #21,-(a7)
	trap #14	     Xbios 21 Curscon
	addq.l #6,a7               Tidy stack
	move #25,-(a7)       Drive A: or B; ?
	trap #1		     Bdos 19 C_Getdrv
	addq.l #2,-(a7)            Tidy stack
	move d0,d6                   D6=drive
	pstring disc            Print message
start	bsr waitkey
	pstring sides
	lea buffer(pc),a6	   a6->buffer
	move #0,d7
	move #1,d5
	move.b $1a(a6),d4     Number of sides
	move d4,-2(a6)
	bsr digit
	pstring crlf
loop	move.l #0,d7		     d7=track
loop1	move.l #1,d5		    d5=sector
loop2	pstring track
	move.l d7,d4	   Print track number
	divs #10,d4
	bsr pnumber
	pstring sector
	move d5,d4	  Print sector number
	bsr digit
	bsr read		  Read sector
	beq ok
	pstring bad		  Bad message
	addq #1,-4(a6)	      Inc bad sectors
	cmpi #9,-4(a6)	       9 bad sectors?
	bne ok
	pstring abort
	bra exit
ok	addq #1,d5		  Next sector
	cmpi #10,d5	    Done all sectors?
	bne loop2
	bsr keyp		 Key pressed?
	bne exit	       End if key hit
	addq #1,d7		   Next track
	cmpi #80,d7	     Done all tracks?
	bne loop1
	sub #1,-2(a6)		  Other side?
exit	pstring key
	bsr waitkey
	move #0,-(a7)	    Bdos 0 P_Term_Old
	trap #1

*********************************************
*      See if key has been pressed          *
*********************************************
keyp	move #11,-(a7)
	trap #1		      Bdos 11 C_Conis
	addq.l #2,a7		   Tidy stack
	tst d0			         0=n0
	rts

*********************************************
*            Read the keyboard              *
*********************************************
readkey	move #8,-(a7)
	trap #1		       Bdos 8 C_Necin
	addq.l #2,a7		   Tidy stack
	rts

*********************************************
*              Print a number               *
*********************************************
pnumber	bsr digit
	swap d4
digit	add #'0',d4	   Print number in d4
	move d4,-(a7)
	move #2,-(a7)
	trap #1
	addq.l #4,a7
	rts

*********************************************
*               Read a sector               *
*********************************************
read	move #1,-(a7)		Read 1 sector
	move #0,-(a7)		       Side 0
	move d7,-(a7)		     Track d7
	move D5,-(a7)		    Sector d5
	move d6,-(a7)		     Drive d6
	move.l #0,-(a7)		     Not used
	move.l a6,-(a7)		       Buffer
	move #8,-(a7)		Verify sector
	trap #14	      Xbios 8 _Floprd
	add.l #20,a7		   Tidy stack
	tst d0
	rts

*********************************************
*             PRINT A STRING		    *
*********************************************
string	move.l a0,-(a7)	       Print a string
	move #9,-(a7)
	trap #1
	add.l #6,a7
	rts

*********************************************
*          Wait for a keypress              *
*********************************************
waitkey	bsr keyp	     Flush buffer 1st
	beq here
	bsr readkey
	bra waitkey
here	bsr readkey		 Now read key
	rts

disc	dc.b "*************************"
	dc.b 13,10
	dc.b "* Insert disc to verify *"
	dc.b 13,10
	dc.b "*   and press RETURN    *"
	dc.b 13,10
	dc.b "*************************"
	dc.b 13,10,0
track	dc.b 13,"Track:",0
sector	dc.b "  Sector:",0
bad	dc.b "...read error",10,0
key	dc.b 13,10,13,10
	dc.b "Press a key...",0
sides	dc.b 13,10,"Sides=",0
crlf	dc.b 13,10,0
abort	dc.b 13,10,"Aborted due to "
	dc.b "multiple errors",0
	even
	dc.w 0		Number of bad sectors
	dc.w 0		      Number of sides
buffer	ds.b 1024