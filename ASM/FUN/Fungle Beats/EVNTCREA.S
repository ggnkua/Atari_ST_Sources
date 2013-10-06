* Creates an eventlist-file from a protracker module.
* This eventlist is assemblable.

* Eventlist format:
* 
* 0: timepoint in 200Hz ticks (timer C)
* 4: eventnumber
* 6: timepoint ..
* 10: eventnumber
* 12: timepoint ..
* 16: ...
* 18: ..

	OUTPUT	C:\CODING\FUNGLE\EVNTCREA.TTP

	OPT	D-

Cconws	MACRO
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

Fseek	MACRO
	move.w	\1,-(sp)			* Mode
	move.w	\2,-(sp)			* Handle
	move.l	\3,-(sp)			* Offset
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

START	move.l	4(a7),a5
	lea	$80(a5),a5
	moveq	#0,d0
	move.b	(a5)+,d0
	bne.s	.doshit
	pea	noinput_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	OUT
.doshit:
	cmpi.b	#4,d0
	bhi.s	.on
	pea	noinput_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra.s	OUT
.on:	lea	filename_txt(pc),a0
	lea	(a0),a6
	subq.w	#1,d0
.movlp:	move.b	(a5)+,(a0)+
	dbra	d0,.movlp
	clr.b	(a0)
	lea	(a6),a1
	lea	mod_buf(pc),a0
	move.l	#$438,d0
	bsr	LOAD_FILE
	tst.l	d0
	bmi.s	OUT
	lea	mod_buf+$3b8(pc),a0
	moveq	#128-1,d7
	moveq	#0,d0
.findloop:
	cmp.b	(a0)+,d0
	bhs.s	.nope
	move.b	-1(a0),d0
.nope:	dbra	d7,.findloop
	addq.w	#1,d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	addi.l	#$43c,d0
	lea	filename_txt(pc),a1
	lea	mod_buf(pc),a0
	bsr	LOAD_FILE
	lea	mod_buf(pc),a1
	bsr	OUTPUT_EVENTLIST

OUT:	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

* INPUT: a0: address of buffer to load to
*        a1: address of filename
*        d0.l: number of bytes to load (-1= entire file!)
* OUPUT: d0.l: number of bytes loaded (negative= error!)
LOAD_FILE:
	move.l	d0,.loadsize
	move.l	a0,-(sp)
	clr.w	-(sp)				* Fopen
	move.l	a1,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,.filehandle
	bpl.s	.load
	addq	#4,sp
	rts
.load:	move.l	.loadsize(pc),-(sp)		* Fread
	move.w	d0,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	d0,-(sp)
	move.w	.filehandle(pc),-(sp)		* Fclose
	move.w	#62,-(sp)
	trap	#1
	addq	#4,sp
	move.l	(sp)+,d0
	rts

.filehandle:
	DC.W	0
.loadsize:
	DC.L	0

* INPUT: a0: destination string
*        a1: source string (null terminated)
* OUTPUT: a0: address of last character in destination string
*         a1: end of source string
COPY_STRING:
.loop:	move.b	(a1)+,(a0)+
	bne.s	.loop
	subq	#1,a0
	rts

COPY_PSTRING:
.loop:	move.b	(a1)+,(a0)+
	dbeq	d0,.loop
	tst.b	-1(a0)
	bne.s	.clr
	subq	#1,a0
	rts
.clr:	clr.b	(a0)
	rts

WRITE_LONGTODECSTRING:
	moveq	#-1,d7
.loop:	moveq	#0,d1
	divu.l	#10,d1:d0
	add.b	#"0",d1
	move.b	d1,-(sp)
	addq.w	#1,d7
	tst.l	d0
	bne.s	.loop
.loop2:	move.b	(sp)+,(a0)+
	dbra	d7,.loop2
	clr.b	(a0)
	rts

* INPUT: a1: address of modulebuffer
OUTPUT_EVENTLIST
	move.l	a1,-(sp)			* Save moduleaddress.

* Create a new file..
	move.w	#0,-(sp)			* Fcreate
	pea	.listname_txt(pc)
	move.w	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,.filehandle
* ..and redirect standard output to it.
	move.w	d0,-(sp)			* Fforce
	move.w	#1,-(sp)
	move.w	#$46,-(sp)
	trap	#1
	addq	#6,sp

	movea.l	(sp)+,a1			* Restore moduleaddress.
	moveq	#0,d7
	move.b	$3b6(a1),d7
	subq.b	#1,d7
	lea	$3b8(a1),a2			* a2:= start of positionlist
	lea	$43c(a1),a3			* a3:= start of patternarray
	lea	$14(a1),a1			* a1:= start of samplename list
	moveq	#0,d5				* d5:= starttime
	moveq	#4*6,d4				* d4:= standard tickinterval

.posloop:
	moveq	#0,d0
	move.b	(a2)+,d0
	lsl.l	#8,d0
	lea	(a3,d0.l*4),a4			* a4:= address of current pattern
	moveq	#64-1,d6
.noteloop:	
	moveq	#4-1,d3
.chanloop:
	move.l	(a4)+,d0
	lsr.l	#8,d0
	lsr.l	#4,d0
	move.l	d0,d1
	andi.w	#$000f,d0
	swap	d1
	andi.w	#$000f,d1
	lsl.w	#4,d1
	or.w	d1,d0				* d0:= samplenumber
	beq.s	.checkspecial
	move.w	d0,d2
	subq.w	#1,d0
	mulu.w	#$1e,d0
	lea	(a1,d0.l),a5			* a5:= address of samplename
	
	movem.l	d0-a6,-(sp)
	lea	.line_txt(pc),a0
	lea	.ticksline_txt(pc),a1
	bsr	COPY_STRING
	move.l	d5,d0
	bsr	WRITE_LONGTODECSTRING
	lea	.comment_txt(pc),a1
	bsr	COPY_STRING
	moveq	#0,d0
	move.w	d2,d0
	bsr	WRITE_LONGTODECSTRING
	move.w	#": ",(a0)+
	lea	(a5),a1
	moveq	#$15-1,d0
	bsr	COPY_PSTRING
	move.w	#$0d0a,(a0)+
	lea	.eventline_txt(pc),a1
	bsr	COPY_STRING
	move.w	#$0d0a,(a0)+
	clr.b	(a0)
	Cconws	.line_txt(pc)
	Fseek	#1,.filehandle(pc),#-1
	movem.l	(sp)+,d0-a6
	
.checkspecial:
	move.w	-2(a4),d0
	move.w	d0,d1
	andi.w	#$0f00,d0
	cmpi.w	#$0f00,d0
	bne.s	.suck
	andi.w	#$000f,d1
	lsl.w	#2,d1
	move.w	d1,d4				* New time-interval.
	bra.s	.nxtchn
.suck:	cmpi.w	#$0d00,d0
	bne.s	.nxtchn
	add.l	d4,d5				* Update time.
	bra.s	.nxtpos				* Goto next position.
.nxtchn:
	dbra	d3,.chanloop
	add.l	d4,d5				* Update time.
	dbra	d6,.noteloop
.nxtpos:
	dbra	d7,.posloop

* Close the file after operations.
	move.w	.filehandle(pc),-(sp)		* Fclose
	move.w	#62,-(sp)
	trap	#1
	addq	#4,sp
	rts

.filehandle:
	DC.W	0
.listname_txt:
	DC.B	"LIST.S",0
.ticksline_txt:
	DC.B	"	DC.L	",0
.eventline_txt:
	DC.B	"	DC.W	0",0
.comment_txt:
	DC.B	$09,$09,$09,$09,"* ",0
.line_txt:
	DS.B	128

	EVEN

******** GLOBAL DATA ********

	DATA

noinput_txt:
	dc.b	"Error: no file was specified!",$d,$a,0

********* RESERVED MEMORY ********

	BSS

	EVEN

filename_txt:
	ds.b	128
mod_buf:
	ds.b	128*1024+$43c