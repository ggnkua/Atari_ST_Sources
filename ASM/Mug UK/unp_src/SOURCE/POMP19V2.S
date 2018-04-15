; To M.U.G UK 17/12/1991 with compliments from Pacman.
;
; **	Depack PROGRAM or DATA files packed with Pompey 1.9a
; 	NOTE:- Compatible with 1.8 through to 2.0
;
; **	To call DEPACK:-
; **	(afile) holds the address of the packed file.
; **	D6 = Size of file (packed).
; **	The depack is then automatic ,ie it will unpack into it's own
; **	space. Who needs buffers!!!  Paranoics do!!  Shit Packers do!!
;
; **	Codes returned by the program are in D0.
;	0	All was ok
;	-1 	Not packed with Pompey Packer
;	-2	File is off a colliding type (retry into a buffer)
;	-3	File has collided during depack (reload and retry).
;
;	Note with the error code -3 you will have to reload the file
;	as the error was not detected until depacking had started. With
;	error code -2 the routs will have detected the COLI and you can
;	then retry into a buffer.  Of course we don't have this trouble!!
;	
; **	To unpack to a FIXED address enter the code at FIXED with
; **	these registers setup:-
; **	A0 - back of the depack data -12 (skip header)
; **	A2 - Fixed addresss to depack to
; **	D6 - length of unpacked file
; **	You should only be using FIXED address depacking for problem
; **	files like COLI's. However there is nothing stopping you from
; **	using the rout ,except the fact that you'll have to do your
; **	file type checking!!!

; **	So to sumup:-
; **	Call DEPACK if it returns zero then everything is OK and the
; **	file is depack into memory where ever it was loaded.
; **	If negative codes are returned from DEPACK then do as follows
; **	IF -1 give the user some verbals for mucking about!!
; **	If -2 re-enter the code at FIXED with registers setup correctly.
; **	IF -3 reload the file and re-enter at FIXED with appropriate
; **	registers setup.

; Hokay ,whoever is reading this GOOD LUCK!!  I haven't actually
; tried this code out yet but everything should function as expected!
; (i'm just so good it's unreal). No you can't have depacks for versions
; greater than v1.9a ,since those versions are not released and the only
; possible reason for wanting them would be to pull stuff from our menu's!!
; TUT TUT!!  As if you would!! Har Har.
; 

depack	move.l	afile(pc),a0		Get file start
	moveq	#0,d0
	moveq	#0,d1
	add.l	d6,a0
	subq.l	#4,a0
	movea.l	a0,a4
	movep.w	0(a0),d0
	movep.w	1(a0),d1
	add.l	d0,d1
	cmpi.w	#$9f99,d1
	beq.s	goforit			YEP, it's ours
	cmpi.w	#$9295,d1
	beq	colliding		It's ours also ,but bad!!

; **	Now check for executable files.

	subq.l	#4,a0
	movea.l	a0,a4
	movep.w	0(a0),d0
	movep.w	1(a0),d1
	add.l	d0,d1
	cmpi.w	#$9f99,d1
	beq.s	goforit			YEP ,it's ours
	cmpi.w	#$9295,d1
	beq	colliding		It's ours too but bad!!	
	moveq	#-1,d0			Not packed with v1.9a
	rts
goforit	bsr	undoit
duff	rts

; **	This file will collide during depack.
; **	Depack the file into a buffer.

colliding
	moveq	#-2,d0
	rts
				
; **	If everything went okay D0 = 0 on exit.

undoit	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	movea.l	a4,a0			Start of packed file
	movea.l	a4,a2
	addq.l	#4,a2
	move.l	-(a0),d6		OLDSIZE
	move.l	-(a0),d2		NEWSIZE
	
	sub.l	d2,a2			subtract the NEWSIZE.
fixed	movea.l	a2,a4			Copy for later (finish address)
	add.l	d6,a2			Start of unpack area
	moveq	#0,d0
	moveq	#0,d5
	lea	$ffff8240.w,a6
	move.w	(a6),d7			Save color
		
.liz	move.b	-(a0),d0
	beq.s	.liz
.diane	moveq	#0,d2
	cmpa.l	a2,a0			Test collision
	bgt	overun

	bsr	.shit_a_bit
	bcs.s	.carol

.4	move.b	-(a0),d2
.linda	move.b	d2,-(a2)
	bra.s	.ecxit

.mona	moveq	#15,d4
	moveq	#2,d3
	bsr	.sharon
	bne.s	.rloop
	move.w	d4,d2
	bra.s	.linda
		
.carol	bsr.s	.shit_a_bit
	bcc.s	.rosemary
	bsr.s	.shit_a_bit
	bcc.s	.mona
	bsr.s	.shit_a_bit
	bcs.s	.mandy
.kathy	
	moveq	#2,d1
	bsr	.n34
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	.linda
	
.mandy	bsr.s	.shit_a_bit
	bcc.s	.t5
	moveq	#15,d4
	moveq	#3,d3
	bsr.s	.sharon
	bne.s	.rloop
	move.b	(a2),-(a2)

.ecxit	neg.w	(a6)			the exciting bit!!!
	move.w	d7,(a6)
	cmpa.l	a2,a4
	blt.s	.diane
	trap	#1
	addq.l	#6,sp
	moveq	#0,d0			All ok
	rts
	
.t5	moveq	#4,d3
	bra.s	.r12345

.rosemary	
	bsr.s	.shit_a_bit
	bcs.s	.tracy
	moveq	#1,d1
.1	lsr.b	#1,d0
	bne.s	.2
	move.b	-(a0),d0
	roxr.b	#1,d0
.2	addx.w	d2,d2
	dbf	d1,.1
	
	move.w	d2,d1
	beq.s	.gina
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	.n34
	move.w	d2,d3
.r12345	bsr.s	.l1
.rloop	movea.l	a2,a1
	add.l	d2,a1
.zoe	move.b	-(a1),-(a2)
	dbf	d3,.zoe
	bra.s	.ecxit

.shit_a_bit
	lsr.b	#1,d0
	bne.s	.noz
	move.b	-(a0),d0
	roxr.b	#1,d0
.noz	rts

.l1	moveq	#0,d4
.sharon	moveq	#1,d1

	moveq	#0,d2
.n1	lsr.b	#1,d0
	bne.s	.n2
	move.b	-(a0),d0
	roxr.b	#1,d0
.n2	addx.w	d2,d2
	dbf	d1,.n1

	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	.n34
	rts	
.n34	moveq	#0,d2
.nlp	lsr.b	#1,d0
	bne.s	.nlp1
	move.b	-(a0),d0
	roxr.b	#1,d0
.nlp1	addx.w	d2,d2
	dbf	d1,.nlp
	rts
.gina	bsr.s	.l1
	move.w	d2,d3
	moveq	#1,d2
	bra.s	.rloop
.tracy	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	.rloop

; **	This file was packed okay but doesn't collide until
; **	depacking has started.
; **	Depack into a safe buffer.

overun	moveq	#-3,d0
	rts
afile				;remove this line later!	