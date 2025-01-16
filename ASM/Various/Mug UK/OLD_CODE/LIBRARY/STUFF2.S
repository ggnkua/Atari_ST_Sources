** GENERAL SUBROUTINES (STUFF2)
** Without custom graphics support.

savestk		ds.l 1
physstore	ds.l 1
logstore	ds.l 1
rezstore	ds.w 1
syskeyhand	ds.l 1
sysvbi		dc.l 0
sysBcount	dc.l 0

currtextrout	dc.l 0

syspal	ds.w 16

temp	dc.l 0
temp2	dc.l 0

blanklongs
	dc.l 0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0

neglongs
	dc.l -1,-1,-1,-1,-1,-1,-1,-1
	dc.l -1,-1,-1,-1,-1,-1,-1,-1

filehandle	dc.w 0
iostatus	dc.l 0

old07	dc.b 0
old09	dc.b 0
old11	dc.b 0
old13	dc.b 0
old15	dc.b 0
old17	dc.b 0
old19	dc.b 0
old1B	dc.b 0
old1D	dc.b 0

	even
chiptab
pitch0	dc.w	0
pitch1	dc.w	0
pitch2	dc.w	0
noise	dc.b	0
mixer	dc.b	$F8
vol0	dc.b	0
vol1	dc.b	0
vol2	dc.b	0

	even
*****************************************************************
clearscreen
	lea 32000(A0),A0
	move #122,D7			zero 31980 bytes
	movem.l blanklongs,D0-D6/A1-A6
wpipl0	movem.l D0-D6/A1-A6,-(A0)
	movem.l D0-D6/A1-A6,-(A0)
	movem.l D0-D6/A1-A6,-(A0)
	movem.l D0-D6/A1-A6,-(A0)
	movem.l D0-D6/A1-A6,-(A0)
	dbra D7,wpipl0 
	movem.l D0-D4,-(A0)		zero 20 bytes
	rts

************
copyscreen		;A0=src, A1=dest
	move #132,D7			copy 31920 bytes
csl1	movem.l (A0)+,D0-D6/A2-A6
	movem.l D0-D6/A2-A6,(A1)
	lea 48(A1),A1
	movem.l (A0)+,D0-D6/A2-A6
	movem.l D0-D6/A2-A6,(A1)
	lea 48(A1),A1
	movem.l (A0)+,D0-D6/A2-A6
	movem.l D0-D6/A2-A6,(A1)
	lea 48(A1),A1
	movem.l (A0)+,D0-D6/A2-A6
	movem.l D0-D6/A2-A6,(A1)
	lea 48(A1),A1
	movem.l (A0)+,D0-D6/A2-A6
	movem.l D0-D6/A2-A6,(A1)
	lea 48(A1),A1
	dbra D7,csl1

	movem.l (A0)+,D0-D6/A2-A6	copy 80 bytes
	movem.l D0-D6/A2-A6,(A1)
	lea 48(A1),A1
	movem.l (A0)+,D0-D6/A2
	movem.l D0-D6/A2,(A1)
	rts

************
gosuper	clr.l -(sp)			go supervisor mode
	move #$20,-(sp)
	trap #1
	addq #6,sp
	move.l D0,savestk
	rts

************
gouser	move.l savestk,-(sp)		return to user mode
	move #$20,-(sp)
	trap #1
	addq #6,sp
	rts	

************
testskey
	move #11,-(sp)			test for key pressed
	trap #1
	addq #2,sp
	rts

************
getskey	move #7,-(sp)			get key press
	trap #1
	addq #2,sp
	rts

************
mouseon	move #8,-(sp)			enable mouse reporting
	move #4,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp
	dc.w $A009			Line-A show mouse
	rts

************
mouseoff
	move #$12,-(sp)			disable mouse reporting
	move #4,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp
	dc.w $A00A			Line-A hide mouse
	rts

************
stickson
	move #$14,-(sp)			enable joystick reporting
	move #4,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp
	rts

************
sticksoff
	move #$1A,-(sp)			disable joystick reporting
	move #4,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp
	rts

*****************************************************************
loadfile		;A0=pathname, A1=address, D0=amount
	move.l A1,-(sp)			load address
	move.l D0,-(sp)			load amount

	move #0,-(sp)			open file
	move.l A0,-(sp)
	move #$3D,-(sp)
	trap #1
	addq.l #8,sp

	move D0,filehandle
	tst.l D0			process errors
	bpl.s dload1

	addq.l #8,sp
dlerr1	move.l #-1,iostatus
	rts

********
dload1	move filehandle,-(sp)		load the file
	move #$3F,-(sp)
	trap #1
	lea 12(sp),sp
	move.l D0,iostatus
	tst.l D0
	bmi dlerr1

	move filehandle,-(sp)		close file
	move #$3E,-(sp)
	trap #1
	addq.l #4,sp
	rts

*****************************************************************
savefile		;A0=pathname, A1=address, D0=amount
	move.l A1,-(sp)			save address
	move.l D0,-(sp)			save amount

	move #0,-(sp)			create file
	move.l A0,-(sp)
	move #$3C,-(sp)
	trap #1
	addq.l #8,sp

	move D0,filehandle
	tst.l D0			process errors
	bpl.s dsave1

	addq.l #8,sp
dserr1	move.l #-1,iostatus
	rts

********
dsave1	move filehandle,-(sp)		load the file
	move #$40,-(sp)
	trap #1
	lea 12(sp),sp
	move.l D0,iostatus
	tst.l D0
	bmi dserr1

	move filehandle,-(sp)		close file
	move #$3E,-(sp)
	trap #1
	addq.l #4,sp
	rts

*****************************************************************
printhexlong
	moveq #7,D7
L46	move.l D0,D1		put each nybble on stack
	and.l #$F,D1
	move D1,-(sp)
	lsr.l #4,D0
	dbra D7,L46

	moveq #7,D7		retrieve nybbles in reverse
L47	move (sp)+,D0		order and print them
	bsr.s printhexdigit
	dbra D7,L47
	rts

************
printhexbyte
	moveq #1,D7
L46b	move.l D0,D1		put each nybble on stack
	and.l #$F,D1
	move D1,-(sp)
	lsr.l #4,D0
	dbra D7,L46b

	moveq #1,D7		retrieve nybbles in reverse
L47b	move (sp)+,D0		order and print them
	bsr.s printhexdigit
	dbra D7,L47b
	rts

************
printhexdigit
	and #$FF,D0
	cmp #$A,D0		check for hex char
	blo.s decd
	addq #7,D0
decd	add #48,D0
	move D0,-(sp)
	move #2,-(sp)
	trap #1
	addq #4,sp
	rts

************
printchar
	move D0,-(sp)
	move #2,-(sp)
	trap #1
	addq #4,sp
	rts

************
printnextline
	move.l #nextline,-(sp)
	move #9,-(sp)
	trap #1
	addq #6,sp
	rts

nextline
	dc.b 13,10,0
	even
*****************************************************************
printdeclong
	move.l D0,D4
	lea.l powertab+36,A3
L110	moveq #0,D0
L111	cmp.l (A3),D4
	blo.s j110			no more units
	sub.l (A3),D4
	addq #1,D0
	bra L111

j110	add #48,D0
	bsr printchar			print that digit
	subq.l #4,A3			set for next digit
	cmp.l #powertab,A3		check for end
	bhs L110
	rts

powertab	dc.l 1,10,100,1000,10000,100000,1000000
		dc.l 10000000,100000000,1000000000

*****************************************************************
readsectors		;D0=start, D1=no., A0=address
	move #0,-(sp)			drive no. (A)
	move D0,-(sp)			sector no.
	move D1,-(sp)			no. sectors
	move.l A0,-(sp)			buffer address
	move #2,-(sp)			forced read
	move #4,-(sp)
	trap #13
	lea 14(sp),sp
	rts

*****************************************************************
saveMFP	MOVE.B	$FFFFFA07.w,old07		
	MOVE.B	$FFFFFA09.w,old09
	MOVE.B	$FFFFFA13.w,old13
	MOVE.B	$FFFFFA15.w,old15
;	MOVE.B	$FFFFFA17.w,old17
	MOVE.B	$FFFFFA19.w,old19
	MOVE.B	$FFFFFA1B.w,old1B
	MOVE.B	$FFFFFA1D.w,old1D
	RTS

restoreMFP
	MOVE.B	old1D,$FFFFFA1D.w
	MOVE.B	old1B,$FFFFFA1B.w
	MOVE.B	old19,$FFFFFA19.w
;	MOVE.B	old17,$FFFFFA17.w
	MOVE.B	old15,$FFFFFA15.w
	MOVE.B	old13,$FFFFFA13.w
	MOVE.B	old09,$FFFFFA09.w
	MOVE.B	old07,$FFFFFA07.w
	bset #3,$FFFFFA17.w		enable SEI
	RTS

MFPoff	clr.b $FFFFFA07.w
	clr.b $FFFFFA09.w
	clr.b $FFFFFA13.w
	clr.b $FFFFFA15.w
	clr.b $FFFFFA19.w
	clr.b $FFFFFA1B.w
	clr.b $FFFFFA1D.w
	bclr #3,$FFFFFA17.w		enable AEI
	RTS

*****************************************************************
cleanchiptab
	moveq #$A,D0
	lea chiptab,A0

clrchpl	clr.b (A0)+
	dbra D0,clrchpl

	move.b #$F8,mixer
	rts

*****************************************************************
writechiptab
	MOVE.B	#7,$FFFF8800.w
	MOVE.B	$FFFF8800.w,D0
	AND.B	#$C0,D0			preserve i/o bits
	AND.B	#$3F,mixer		
	OR.B	D0,mixer		combine bits

	lea	chiptab+$B,A0
	MOVEq	#$A,D0			write 12 bytes
wrchipl	MOVE.B	D0,$FFFF8800.w
	MOVE.B	-(A0),$FFFF8802.w
	DBF	D0,wrchipl
	RTS
