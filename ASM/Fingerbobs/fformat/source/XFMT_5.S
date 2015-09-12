
	ttl	XFORMAT - Fastload Formatter v0.5

;-------------------------------------------------------------------------------
;
; XFORMAT - Fastload Formatter 
;
; Version 0.5
;
; Written on 4/6/90 by A.J.Buchanan for E.S.D
;
; Reconstructed from compiled version after formatting
; source disk accidentaly!
;
; This program formats a special format fastloading disk.
; The sector numbers are skewed from track to track.
;
; e.g
;
; Track 0 : 1  2  3  4  5  6  7  8  9  10
; Track 1 : 9  10 1  2  3  4  5  6  7  8
; track 2 : 7  8  9  10 1  2  3  4  5  6
;
; Using the fastload format loading 800 sectors, normally
; taking 30 seconds, now takes just 19 seconds!
;
;-------------------------------------------------------------------------------
; 2009/1	AJB		To get this to assemble under the version of Devpac3 I have
;					I had to make edits to both gemmacro.i and vdilib.s
;					I don't know why, but those files were stuffed.
;-------------------------------------------------------------------------------

	include gemmacro.i

DISABLE	equ	$43e

	section text

start	movea.l 4(a7),a3	;
	movea.l #mystack,a7	;
	move.l	$c(a3),d0	;
	add.l	$14(a3),d0	;
	add.l	$1c(a3),d0	;
	addi.l	#$100,d0	;
	move.l	d0,-(a7)	;
	move.l	a3,-(a7)	;
	clr.w	-(a7)		;
	move.w	#$4a,-(a7)	;
	trap	#1		; Shrink Memory
	lea	$c(a7),a7	;

restart form_alert #1,#alert1	; Initial message
	cmp.b	#2,d0		;
	bne.s	.go		;
	form_alert #1,#alert8	; Additional info
	form_alert #1,#alert9	;

.go	form_alert #1,#alert2	; Select drive
	subq.l	#1,d0		;
	move.w	d0,device	;

	form_alert #1,#alert7	; Select format
	move.w	d0,no_of_sides	;
	cmp.b	#3,d0		;
	bne.s	.ask		;
	form_alert #1,#alert10	; Give info about TRACKDISK option
	
.ask	form_alert #1,#alert3	; Sure ?
	cmp.b	#2,d0		;
	beq	exit		;

	bsr	begin		; Format the disk!

	form_alert #1,#alert6	; Again?
	cmp.b	#1,d0		;
	beq	restart		;

exit	clr.w	-(a7)		; Leave program
	move.w	#$4c,-(a7)	;
	trap	#1		;


;
; Error handling routine
;
; d0 = 1 : Write protect
;      2 : Write Error
;
error	cmp.b	#1,d0		; Write protect?
	bne	.two		; no -->

.one	move.l	oldsp,-(a7)	; User mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;

	form_alert #1,#alert4	; Write protect error
	cmp.b	#1,d0		;
	bne	.abort		; 
	lea	4(a7),a7	;
	bra	restart		; restart program

.abort	bra	motoroff	; Finished.

.two	move.l	oldsp,-(a7)	; User mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;

	form_alert #1,#alert5	; Write error

motoroff	
	clr.l	-(a7)		; Super mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;	
	move.l	d0,oldsp	;
	
.on	move.w	$ffff8604.w,d0	;
	btst	#7,d0		; Wait for motor to stop
	bne.s	.on		;
	move.b	#$e,$ffff8800.w	; Deselect drives
	move.b	$ffff8800.w,d0	;
	andi.b	#$f8,d0		;
	ori.b	#7,d0		;
	move.b	d0,$ffff8802.w	;
	
	move.l	oldsp,-(a7)	; Super mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	bra	exit		;

;
; Format control section
;
begin	clr.l	-(a7)		; Super mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move.l	d0,oldsp	;

	moveq	#0,d0		; Jump to format
	move.w	no_of_sides,d0	; routine required.
	subq.w	#1,d0		;
	asl.w	#2,d0		;
	lea	jmptab,a0	;
	movea.l 0(a0,d0.w),a0	;
	jmp	(a0)		;

jmptab	dc.l	single,double,special

single	move.w	#1,no_of_sides	; 
	move.b	#$51,track	; End Track
	move.b	#0,side		; Side 0
	move.l	#table1,skew	;
	bsr	format		;
	bra	bootsector	;
	
double	move.w	#2,no_of_sides	;
	move.b	#$51,track	; End Track
	move.b	#0,side		; Side 0
	move.l	#table2,skew	;
	bsr	format		;
	move.b	#$51,track	; End Track
	move.b	#1,side		; Side 1
	move.l	#table3,skew	;
	bsr	format		;
	bra	bootsector	;
	
special move.w	#2,no_of_sides	;
	move.b	#$51,track	; End Track
	move.b	#0,side		; Side 0
	move.l	#table1,skew	;
	bsr	format		;
	move.b	#$51,track	; End track
	move.b	#1,side		; Side 1
	move.l	#table1,skew	;
	bsr	format		;
	bra	over		; Trackdisk has no bootsector

;
; Create bootsector
;
bootsector	
	lea	buff,a6		; Clear out buffer
	move.w	#$a00,d0	;
	movea.l a6,a5		;
loop1	clr.w	(a5)+		;
	dbf	d0,loop1	;

	move.w	#0,-(a7)	; Non-Executable
	move.w	#2,-(a7)	; 80 track
	move.l	#$1000001,-(a7)	; Random serial number
	move.l	a6,-(a7)	; Buffer
	move.w	#$12,-(a7)	; Protoboot
	trap	#14		;
	adda.l	#$e,a7		;

	move.b	#$a,$18(a6)	; 10 sectors per track
	move.w	#$334,d0	; Number of sectors
	move.w	no_of_sides,d1	;
	mulu	d1,d0		; x no_of_sides
	move.b	d1,$1a(a6)	; No of sides on disk
	move.b	d0,$13(a6)	; No of sectors on disk
	lsr.w	#8,d0		;
	move.b	d0,$14(a6)	;

	lea	mark,a0		; Copy Message to bootsector
	lea	$1e(a6),a1	;
.loop	move.b	(a0)+,(a1)+	;
	tst.b	-1(a1)		;
	bne.s	.loop		;

	move.w	#$a,-(a7)	; Write bootsector & directories
	move.w	#0,-(a7)	; to track 0
	move.w	#0,-(a7)	;
	move.w	#1,-(a7)	;
	move.w	device,-(a7)	;
	move.l	#0,-(a7)	;
	move.l	a6,-(a7)	;
	move.w	#9,-(a7)	;
	trap	#14		;
	adda.l	#$14,a7		;
	cmpi.w	#0,d0		;
	beq	over		;
	
	moveq	#2,d0		; Error!
	bra	error		;

over	move.l	oldsp,-(a7)	; User mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	rts			;

;
; Format the disk!
;
format	bsr	select		; Select drive & Side
	lea	$ffff8606,a6	; DMA Register
	bsr	restore		; Restore to track 0

	move.b	#0,ctrack	; Current track is 0

.next	movea.l skew,a0		; Get entry from
	move.b	(a0)+,d4	; skew table
	move.l	a0,skew		;

	bsr	fmt		; Format the track
	bsr	step_in		; Step in

	addq.b	#1,ctrack	;
	move.b	track,d7	;
	cmp.b	ctrack,d7	;
	bne.s	.next		; Next track

.on	move.w	$ffff8604.w,d0	;
	btst	#7,d0		; Wait for motor to stop
	bne.s	.on		;
	move.b	#$e,$ffff8800.w	; Deselect drives
	move.b	$ffff8800.w,d0	;
	andi.b	#$f8,d0		;
	ori.b	#7,d0		;
	move.b	d0,$ffff8802.w	;
	
	rts			;

;
; Prototype a track and write it to disk
;
fmt	move.b	#1,d3		;
	lea	buff,a2		;
	move.w	#$3b,d1		; Track Header
	move.b	#$4e,d0		; 60 x $4e
	bsr	wmult		;
.next	move.w	#$b,d1		; Gap
	clr.b	d0		; 12 x $00
	bsr	wmult		;
	move.w	#2,d1		;
	move.b	#$f5,d0		; 3 x $f5
	bsr	wmult		;
	move.b	#$fe,(a2)+	; Address mark
	move.b	ctrack,(a2)+	; Track
	move.b	side,(a2)+	; Side
	move.b	d4,(a2)+	; Sector
	move.b	#2,(a2)+	; Sector size = 512 bytes
	move.b	#$f7,(a2)+	; Write Checksum
	move.w	#$15,d1		;
	move.b	#$4e,d0		; 22 x $4e
	bsr	wmult		;
	move.w	#$b,d1		;
	clr.b	d0		; 12 x $00
	bsr	wmult		;
	move.w	#2,d1		;
	move.b	#$f5,d0		; 3 x $f5
	bsr	wmult		;
	move.b	#$fb,(a2)+	; Data Block mark
	move.w	#$ff,d1		;
.virgin move.b	#$e5,(a2)+	; Write initial data
	move.b	#$e5,(a2)+	;
	dbf	d1,.virgin	;
	move.b	#$f7,(a2)+	; Write Checksum
	move.w	#$27,d1		;
	move.b	#$4e,d0		; 40 x $4e
	bsr	wmult		;
	addi.b	#1,d4		; Inc. actual sector number
	cmp.b	#11,d4		; 
	bne	.x1		; ok ->
	move.b	#1,d4		; Wrap sector number
.x1	addi.b	#1,d3		; Inc. count sector number
	cmp.b	#11,d3		;
	bne	.next		; Next sector

	move.w	#$578,d1	; Fill to end of track
	move.b	#$4e,d0		;
	bsr	wmult		;
	
	move.l	#buff,d0	; Set DMA to track buffer
	move.b	d0,$ffff860d	;
	lsr.l	#8,d0		;
	move.b	d0,$ffff860b	;
	lsr.l	#8,d0		;
	move.b	d0,$ffff8609	;
	
	move.w	#1,DISABLE		; Lock Floppies
	
	move.w	#$190,(a6)	;
	move.w	#$90,(a6)	; Set DMA write
	move.w	#$190,(a6)	;
	move.w	#$1f,d7		;
	bsr	w1772		; Sector count = 31
	move.w	#$180,(a6)	;
	move.w	#$f0,d7		; WRITE TRACK
	bsr	w1772		;
	move.l	#$60000,d7	; Time out
.wait	btst	#5,$fffffa01	;
	beq	.ok		; finished ->
	subq.l	#1,d7		; Timeout countdown
	bne	.wait		; continue

	moveq	#2,d0		;
	bra	error		; Error!
	
.ok	move.w	#0,DISABLE	; Unlock floppies
	move.w	#$190,(a6)	;
	move.w	(a6),d0		; d0 = DMA Status
	btst	#0,d0		;
	beq	.err2		; DMA Error ->
	move.w	#$180,(a6)	;
	bsr	r1772		; d7 = FDC Status
	btst	#6,d7		; Write protect
	bne	.err1		;
	rts			;

.err2	moveq	#2,d0		; Write error
	bra	error		;

.err1	moveq	#1,d0		; Write protect
	bra	error		;


;
; Write d0, d1+1 times into buffer at a2
;
wmult	move.b	d0,(a2)+	;
	dbf	d1,wmult	;
	rts			;


;
; Select drive & side
;
select	move.w	device,d5	; Device
	addq.b	#1,d5		;
	lsl.b	#1,d5		;
	move.b	side,d4		; Side
	or.b	d4,d5		;
	eori.b	#7,d5		; Active Low!
	andi.b	#7,d5		;
	move.b	#$e,$ffff8800.w	;
	move.b	$ffff8800.w,d1	;
	andi.b	#$f8,d1		;
	or.b	d5,d1		;
	move.b	d1,$ffff8802.w	;
	rts			;

;
; Seek to track 0
;
restore move.w	#$80,(a6)	; COMMAND REGISTER
	move.w	#0,d7		;
	bsr	w1772		; RESTORE
	bsr	wait		;
	rts			;

;
; Step in a track
;
step_in move.w	#$80,(a6)	; COMMAND REGISTER
	move.w	#$50,d7		;
	bsr	w1772		; STEP-IN
	bsr	wait		;
	rts			;

;
; Wait for FDC command to finish
;
wait	btst	#5,$fffffa01	;
	bne.s	wait		;
	rts			;

;
; Write byte d7 to FDC
;
w1772	bsr	delay		;
	move.w	d7,-2(a6)	;
delay	move.w	#$20,d0		;
.loop	dbf	d0,.loop	;
	rts			;

;
; Read FDC to d7
;
r1772	bsr	.delay		;
	move.w	-2(a6),d7	;
.delay	move.w	#$20,d0		;
.loop	dbf	d0,.loop	;
	rts			;

;
; GEM code
;
	include aeslib.s
	include vdilib.s
	
	section data

;
; Alert Box Data
;
alert1	dc.b	"[0][XFORMAT - Fastload Formatter |"
	dc.b	" |(c)1990 E.S.D |"
	dc.b	"Written by A.J.Buchanan |"
	dc.b	" ][ GO | INFO ]",0
	
	even
	
alert2	dc.b	"[0][Select Drive : |"
	dc.b	" ][ A | B ]",0
	
	even
	
alert3	dc.b	"[1][Are you sure you REALLY |"
	dc.b	"want to do this? ]"
	dc.b	"[ YUP | NOPE ]",0
	
	even
	
alert4	dc.b	"[1][Remove Write Protect! |"
	dc.b	" ][ OK | ABORT ]",0

	even
		
alert5	dc.b	"[1][Write error! |"
	dc.b	" ][ SHIT! ]",0
	
	even
	
alert6	dc.b	"[0][Finished! |"
	dc.b	" ][ Another | Quit ]",0
	
	even
	
alert7	dc.b	"[0][Select Format: |"
	dc.b	" ][ Single | Double | Trackdisk ]",0
	
alert8	dc.b	"[0][Version : 0.5 |"
	dc.b	"This program is PD, and |"
	dc.b	"may be copied freely, but |"
	dc.b	"not sold. |"
	dc.b	"][ Fair Enough ]",0
	
alert9	dc.b	"[0][N.B This might |"
	dc.b	"crash! |"
	dc.b	"][ Well It's Free! ]",0

alert10	dc.b	"[0][TRACKDISK has no |"
	dc.b	"bootsector.|"
	dc.b	"][ Radical! ]",0

	even

mark	dc.b	"Formatted with E.S.D XFORMAT v0.5",0
	
	even

;
; Skew Tables
;
; 1 byte per track = start sector number
;
table1	
	rept	90/5
	dc.b	1
	dc.b	9
	dc.b	7
	dc.b	5
	dc.b	3
	endr
	
table2	
	rept	90/5
	dc.b	1
	dc.b	7
	dc.b	3
	dc.b	9
	dc.b	5
	endr
	
table3	
	rept	90/5
	dc.b	9
	dc.b	5
	dc.b	1
	dc.b	7
	dc.b	3
	endr

	section bss
	
	even

track	ds.w	1
ctrack	ds.w	1
side	ds.w	1
device	ds.w	1
skew	ds.l	1
oldsp	ds.l	1
no_of_sides	ds.w	1

buff	ds.b	13*1024

	ds.l	100
mystack ds.l	1

;
; end
;

