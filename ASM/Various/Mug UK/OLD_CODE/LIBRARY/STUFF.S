** GENERAL SUBROUTINES (STUFF)

savestk		dc.l 0
physstore	dc.l 0
logstore	dc.l 0
rezstore	dc.w 0

syskeyhand	dc.l 0
systimerC	dc.l 0
sysvbi		dc.l 0
sysnvbls	dc.w 0
sysvblqueue	dc.l 0

sysBcount	dc.l 0
oldstacktop	dc.l 0

halfmegflag	dc.b 0
maxmem		dc.l 0
memtop		dc.l 0
progend		dc.l 0

syspal		ds.w 16

*************************
** MISC VARS
temp	dc.l 0				general temp vars
temp2	dc.l 0

itemp	dc.l 0				interrupt temp vars
itemp2	dc.l 0

mousecount	dc.w 0			mouse erased counter for GEMCLONE
cmousecount	dc.w 0

blanklongs
	dc.l 0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0

neglongs
	dc.l -1,-1,-1,-1,-1,-1,-1,-1
	dc.l -1,-1,-1,-1,-1,-1,-1,-1

hyphens	dc.b "--------",0
	even
toff	dc.b "OFF",0
ton	dc.b "ON ",0
	even
*************************
** VARS FOR DISK ACCESS
filehandle	dc.w 0
iostatus	dc.l 0

diskerrno	dc.b 0
derrflag	dc.b 0
	even
*************************
** VARS FOR MFP SAVING
old07	dc.b 0
old09	dc.b 0
old11	dc.b 0
old13	dc.b 0
old15	dc.b 0
old17	dc.b 0
old19	dc.b 0
old1B	dc.b 0
old1D	dc.b 0
old1F	dc.b 0
old21	dc.b 0
old23	dc.b 0
old25	dc.b 0
	even
*************************
** VARS FOR SOUND ROUTINES
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
*************************
** VARS FOR TEXT HANDLER
currtextrout	dc.l 0
stringstatus	dc.w 0		0=init, 1=ok, 2=update, 3=done
tinplen		dc.w 0
tinpoff		dc.w 0
textheight	dc.w 0
textinpxpos	dc.w 0
textinpypos	dc.b 0
	even
textinptc	dc.b 0
textinpbc	dc.b 0
	even
*****************************************************************
waitvblank
	move #$25,-(sp)			wait for vblank
	trap #14
	addq.l #2,sp
	rts

************
savesysscreen
	move #2,-(sp)			save system physbase
	trap #14
	addq.l #2,sp
	move.l D0,physstore

	move #3,-(sp)			save system logbase
	trap #14
	addq.l #2,sp
	move.l D0,logstore

	move #4,-(sp)			save system rez
	trap #14
	addq.l #2,sp
	move D0,rezstore
	rts

************
setlowrez
	clr -(sp)			set screen
	move.l currphysbase,-(sp)
	move.l #-1,-(sp)
	move #5,-(sp)
	trap #14
	lea 12(sp),sp
	rts
	
************
restoresysscreen
	move rezstore,-(sp)		restore system screen
	move.l physstore,-(sp)
	move.l logstore,-(sp)
	move #5,-(sp)
	trap #14
	lea 12(sp),sp
	rts

************
initmemstats
	lea thing,A0			allow for half meg machines
	sf halfmegflag
	move.l $42E.w,D0
	move.l D0,maxmem
	cmp.l #$100000,D0
	bhs.s ok1
	st halfmegflag
ok1	move.l A0,progend
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
clearlines1	;D0=start line, D1=no. lines, A0=screenbase
	add D1,D0
	add D0,D0
	lea lineofftab,A1
	move 0(A1,D0.w),D0
	add #160,D0
	ext.l D0
	add.l D0,A0
	subq #1,D1

	movem.l blanklongs,D0/D2-D7/A1-A6
wpipl2	movem.l D0/D2-D7/A1-A6,-(A0)		zero 156 bytes
	movem.l D0/D2-D7/A1-A6,-(A0)
	movem.l D0/D2-D7/A1-A6,-(A0)
	move.l D0,-(A0)				zero 4 bytes
	dbra D1,wpipl2
	rts

************
clearlines2	;D1=no. lines, A0=wipebase
	move D1,D0
	lsl D0
	lea lineofftab,A1
	move 0(A1,D0.w),D0
	lea 0(A0,D0.w),A0
	subq #1,D1

	movem.l blanklongs,D0/D2-D7/A1-A6
wpipl3	movem.l D0/D2-D7/A1-A6,-(A0)		zero 156 bytes
	movem.l D0/D2-D7/A1-A6,-(A0)
	movem.l D0/D2-D7/A1-A6,-(A0)
	move.l D0,-(A0)				zero 4 bytes
	dbra D1,wpipl3
	rts

************
copyscreen		;A0=src, A1=dest
	move #132,D7			copy 31920 bytes
csl0	movem.l (A0)+,D0-D6/A2-A6
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
	dbra D7,csl0

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
	addq.l #6,sp
	move.l D0,savestk
	rts

************
gouser	move.l savestk,-(sp)		return to user mode
	move #$20,-(sp)
	trap #1
	addq.l #6,sp
	rts	

************
testskey
	move #11,-(sp)			test for key pressed
	trap #1
	addq.l #2,sp
	rts

************
getskey	move #7,-(sp)			get key press
	trap #1
	addq.l #2,sp
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
gb1	moveq #0,D1
	move.b (A0)+,D1			get byte
	bpl.s cd1

	neg.b D1			copy batch
	add D1,D2
	addq #1,D2
	move.b (A0)+,D0
cbl1	move.b D0,(A1)+
	dbra D1,cbl1
	bra.s echk1

cd1	add D1,D2			copy direct
	addq #1,D2
cdl1	move.b (A0)+,(A1)+
	dbra D1,cdl1

echk1	cmp #32000,D2
	blo gb1

********************************
	movem.l (sp)+,A0-A1
	move #199,temp2 		200 lines
crscr2	move #4,temp			5 * 4 chunks
	move.l A1,A2

crscr1	movem.w (A2),D0/D2/D4/D6
	swap D0
	swap D2
	swap D4
	swap D6
	move 40(A2),D0
	move 42(A2),D2
	move 44(A2),D4
	move 46(A2),D6
	movem.w 80(A2),D1/D3/D5/D7
	swap D1
	swap D3
	swap D5
	swap D7
	move 120(A2),D1
	move 122(A2),D3
	move 124(A2),D5
	move 126(A2),D7
	movem.l D0-D7,(A0)
	lea 32(A0),A0
	addq.l #8,A2
	subq #1,temp
	bcc crscr1

	lea 160(A1),A1
	subq #1,temp2
	bcc crscr2
	rts

*****************************************************************
gen3screens
	move.l progend,D0		gen 3 screen bases
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

************
gen2screens
	move.l progend,D0		gen 2 screen bases
	and.l #$FFFF00,D0
	add.l #256,D0
	lea screenbases,A0
	move.l D0,(A0)+
	add.l #32000,D0
	move.l D0,(A0)+

	move.l screenbases,A0		wipe 2 screens
	bsr clearscreen
	move.l screenbases+4,A0
	bsr clearscreen
	rts

************
gen1screen
	move.l progend,D0		gen 1 screen base
	and.l #$FFFF00,D0
	add.l #256,D0
	lea screenbases,A0
	move.l D0,(A0)+

	move.l screenbases,A0		wipe 1 screens
	bsr clearscreen
	rts

*****************************************************************
gen3hiscreens
	move.l memtop,D0		gen 3 screen bases
	sub.l #32000,D0
	lea screenbases,A0
	move.l D0,8(A0)
	sub.l #32000,D0
	move.l D0,4(A0)
	sub.l #32000,D0
	move.l D0,(A0)

	move.l screenbases,A0		wipe 3 screens
	bsr clearscreen
	move.l screenbases+4,A0
	bsr clearscreen
	move.l screenbases+8,A0
	bsr clearscreen
	rts

************
gen2hiscreens
	move.l memtop,D0		gen 2 screen bases
	sub.l #32000,D0
	lea screenbases,A0
	move.l D0,(A0)+
	sub.l #32000,D0
	move.l D0,(A0)+

	move.l screenbases,A0		wipe 2 screens
	bsr clearscreen
	move.l screenbases+4,A0
	bsr clearscreen
	rts

************
gen1hiscreen
	move.l memtop,D0		gen 1 screen base
	sub.l #32000,D0
	move.l D0,screenbases

	move.l D0,A0			wipe 1 screen
	bsr clearscreen
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
	move.l #-1,iostatus
	rts

********
dload1	move filehandle,-(sp)		load the file
	move #$3F,-(sp)
	trap #1
	lea 12(sp),sp
	move.l D0,iostatus

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
	move.l #-1,iostatus
	rts

********
dsave1	move filehandle,-(sp)		load the file
	move #$40,-(sp)
	trap #1
	lea 12(sp),sp

	move.l D0,iostatus

	move filehandle,-(sp)		close file
	move #$3E,-(sp)
	trap #1
	addq.l #4,sp
	rts

*****************************************************************
plotpoint	;A0=screenbase, D0=xpos, D1=ypos, D2=color
	lea lineofftab,A2
	add D1,D1
	move 0(A2,D1.w),D1
	lea 0(A0,D1.w),A0	point to right line

	move D0,D1
	lsr D1
	and #$FFF8,D1
	lea 0(A0,D1.w),A0	point to right chunk

	and #15,D0		generate masks
	move #$8000,D6
	lsr D0,D6
	move D6,D5
	not D5

	moveq #3,D1
ps1	lsr.b D2
	bcc.s clbit
	or D6,(A0)+
	dbra D1,ps1
	rts

clbit	and D5,(A0)+
	dbra D1,ps1
	rts

*****************************************************************
plotpointb	;A0/A1=screenbases, D0=xpos, D1=ypos, D2=color
	lea lineofftab,A2
	add D1,D1
	move 0(A2,D1.w),D1
	lea 0(A0,D1.w),A0	point to right line
	lea 0(A1,D1.w),A1

	move D0,D1
	lsr D1
	and #$FFF8,D1
	lea 0(A0,D1.w),A0	point to right chunk
	lea 0(A1,D1.w),A1

	and #15,D0		generate masks
	move #$8000,D6
	lsr D0,D6
	move D6,D5
	not D5

	moveq #3,D1
ps1b	lsr.b D2
	bcc.s clbitb
	or D6,(A0)+
	or D6,(A1)+
	dbra D1,ps1b
	rts

clbitb	and D5,(A0)+
	and D5,(A1)+
	dbra D1,ps1b
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

************
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

*****************************************************************
genlineofftab
	lea lineofftab,A0
	moveq #0,D0
	move #199,D1
genl1	move D0,(A0)+
	add #160,D0
	dbra D1,genl1
	rts

************
LEDoff	move.b #14,$FFFF8800.w
	move.b $FFFF8800.w,D0
	and.b #$F8,D0
	or.b #7,D0
	move.b D0,$FFFF8802.w
	rts

************
setnewstack	;raise stack to top of memory
	move.l sp,D0			get stack top
	add.l #512,D0
	and.l #$FFFFFE00,D0
	move.l D0,oldstacktop

	move.l maxmem,A0		copy 512 bytes
	move.l D0,A1
	moveq #127,D0
csl1	move.l -(A1),-(A0)
	dbra D0,csl1

	move.l A0,memtop

	move.l maxmem,D0		set new stack pointer
	sub.l oldstacktop,D0
	add.l D0,sp
	rts

************
restoreoldstack	;copy stack back to original place
	move.l oldstacktop,A0		copy 512 bytes
	move.l maxmem,A1
	moveq #127,D0
csl2	move.l -(A1),-(A0)
	dbra D0,csl2

	move.l maxmem,D0		reset stack pointer
	sub.l oldstacktop,D0
	sub.l D0,sp
	rts
