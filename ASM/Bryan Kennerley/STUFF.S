** GENERAL SUBROUTINES (STUFF)
** Include file for scroller.s source file.

*****************************************************************
savestk		ds.l 1
physstore	ds.l 1
logstore	ds.l 1
rezstore	ds.w 1

syspal	ds.w 16

temp	dc.l 0
temp2	dc.l 0

blanklongs
	dc.l 0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0

*****************************************************************
savesysscreen
	move #2,-(sp)			save system physbase
	trap #14
	addq #2,sp
	move.l D0,physstore

	move #3,-(sp)			save system logbase
	trap #14
	addq #2,sp
	move.l D0,logstore

	move #4,-(sp)			save system rez
	trap #14
	addq #2,sp
	move D0,rezstore
	rts

************
setlowrez
	clr -(sp)			set screen
	move.l currphysbase,-(sp)
	move.l #-1,-(sp)
	move #5,-(sp)
	trap #14
	add #12,sp
	rts
	
************
restoresysscreen
	move rezstore,-(sp)		restore system screen
	move.l physstore,-(sp)
	move.l logstore,-(sp)
	move #5,-(sp)
	trap #14
	add #12,sp
	rts

************
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

*****************************************************************
decomppc1			;A0=pc1 src, A1=32000 temp buff
	moveq #0,D2
	movem.l A0-A1,-(sp)

**************
** DECOMPACTION RESULTS IN PLANE BY PLANE, LINE BY LINE DATA

gb1	moveq #0,D1
	move.b (A0)+,D1			get byte
	tst.b D1
	bpl cd1

	neg.b D1			copy batch
	add D1,D2
	addq #1,D2
	move.b (A0)+,D0
cbl1	move.b D0,(A1)+
	dbra D1,cbl1
	bra echk1

cd1	add D1,D2			copy direct
	addq #1,D2
cdl1	move.b (A0)+,(A1)+
	dbra D1,cdl1

echk1	cmp #32000,D2
	blo gb1

********************************
** MERGE 4 PLANES BACK TOGETHER IN ORIGINAL BUFFER SPACE

	movem.l (sp)+,A0-A1
	move #199,temp2 		200 lines
crscr2	move #4,temp			5 * 4 chunks per line
	move.l A1,A2

crscr1	movem.w (A2),D0/D2/D4/D6	get plane 1
	swap D0
	swap D2
	swap D4
	swap D6
	move 40(A2),D0			then plane 2
	move 42(A2),D2
	move 44(A2),D4
	move 46(A2),D6
	movem.w 80(A2),D1/D3/D5/D7	get plane 3
	swap D1
	swap D3
	swap D5
	swap D7
	move 120(A2),D1			then plane 4
	move 122(A2),D3
	move 124(A2),D5
	move 126(A2),D7
	movem.l D0-D7,(A0)		save the lot
	lea 32(A0),A0
	lea 8(A2),A2
	subq #1,temp
	bcc crscr1

	lea 160(A1),A1
	subq #1,temp2
	bcc crscr2
	rts

*****************************************************************
gen3screens
	move.l #thing,D0		gen 3 screen bases
	and.l #$FFFF00,D0
	add.l #256,D0
	lea screenbases,A0
	move.l D0,(A0)+
	add.l #32000,D0
	move.l D0,(A0)+
	add.l #32000,D0
	move.l D0,(A0)+

	move.l screenbases,A0		wipe 3 screens
	bsr clearscreen
	move.l screenbases+4,A0
	bsr clearscreen
	move.l screenbases+8,A0
	bsr clearscreen
	rts

*****************************************************************

