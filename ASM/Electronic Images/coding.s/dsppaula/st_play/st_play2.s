
	opt	c-

;	include	Runback.i

;task_name
;	dc.b	"ST Sound chip emulator",0
;	even

	section	STemu,Code_c

;	move.l	param,a0

	Include	Custom.i

*****************************************************************************
* EXECUTE SEQUENCE				    			    *
*****************************************************************************

	bsr	Loadfile
	moveq	#103,d0		;No free memory
	cmpi.w	#2,d2
	beq.s	QuitNoMem
	move.l	#205,d0		;Object not found
	cmpi.w	#1,d2
	beq.s	QuitFreeMem
	Getcustombase	a5
	bsr 	SetUp
	move.w	tunenumber,d0
	move.l	muz,a0
	jsr	(a0)
	moveq	#5,d0
	lea	Intblock,a1
	move.l	4.w,a6
	jsr	-168(a6)
Self
	btst	#7,$bfe001
	bne.s	Self
	moveq	#5,d0
	lea	Intblock,a1
	jsr	-174(a6)
	Getcustombase	a5
	bclr	#1,$bfe001
	move	#0,aud0+ac_vol(a5)
	move	#0,aud1+ac_vol(a5)
	move	#0,aud2+ac_vol(a5)
	move	#0,aud3+ac_vol(a5)
	moveq	#0,d0		;Successful execution
QuitFreeMem
	move.l	d0,-(sp)
	bsr	Releasememory
	move.l	(sp)+,d0
QuitNoMem
	rts

******************************************************************************
* Sound playing **************************************************************
SP_Volume	dc.w	0	;Volume (0-64)
SP_Period	dc.w	0	;Period	(minimum 124)
				;20 Khz = 179
;Period formula is: (1000000/samples per second)/0.279365
Soundinit	Macro
	jsr	SP_Setup
	EndM
Soundoff	Macro
	jsr	SP_Off
	EndM

SP_Setup
	bset	#1,$bfe001
	move.l	#Blanksp,aud0(a5)
	move.l	#Blanksp,aud1(a5)
	move.l	#Blanksp,aud2(a5)
	move.l	#Blanksp,aud3(a5)
	move	#2,aud0+ac_len(a5)
	move	#2,aud1+ac_len(a5)
	move	#2,aud2+ac_len(a5)
	move	#2,aud3+ac_len(a5)
	move	#124,aud0+ac_per(a5)
	move	#124,aud1+ac_per(a5)
	move	#124,aud2+ac_per(a5)
	move	#124,aud3+ac_per(a5)
	rts

SP_Off	bclr	#1,$bfe001
	move	#0,aud0+ac_vol(a5)
	move	#0,aud1+ac_vol(a5)
	move	#0,aud2+ac_vol(a5)
	move	#0,aud3+ac_vol(a5)
	rts

Blanksp	dc.w	0,0

*****************************************************************************
* SET UP SOUND ETC.			            			    *
*****************************************************************************

SetUp
        move.l  4.w,a6
        sub.l   a1,a1	            ; Zero - Find current task
        jsr     -294(a6)

        move.l  d0,a1
        moveq   #-127,d0		 ; task priority
        jsr     -300(a6)

	move.w	#$f,dmacon(a5)
	Soundinit
	move.w	#%1000001111001111,dmacon(a5)
	rts
 
*****************************************************************************
* MAIN					    				    *
*****************************************************************************

Main
	movem.l	d0-d7/a0-a6,-(sp)
	Getcustombase a5
	bsr	ST_music
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*****************************************************************************
* SOUND-CHIP EMULATOR			    				    *
*****************************************************************************

ST_Music
	move.l	muz,a0
	jsr	8(a0)
	Getcustombase a5
	lea	logtable(pc),a3

	lsl.l	#8,d1
	move.w	d0,d1
	lsr.l	#4,d1
	move.w	d1,aud0+ac_per(a5)
	move.w	a0,d0
	lsr.w	#6,d0

	btst	#8,d7
	beq.s	tone0
	move.w	#0,aud0+ac_vol(a5)
	bra.s	tone0off
tone0
	btst	#6,d0
	beq.s	noenv0
	move.l	#EnvelopeA,aud0+ac_ptr(a5)
	move.w	#Envlength,aud0+ac_len(a5)
	move.w	#63,d0
	lsr.w	#1,d1
	move.w	d1,aud0+ac_per(a5)
	bra.s	env0
noenv0
	move.l	#SquareWave,aud0+ac_ptr(a5)
	move.w	#$1,aud0+ac_len(a5)
env0
	or.w	#3,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	move.w	d0,aud0+ac_vol(a5)
tone0off

	lsl.l	#8,d3
	move.w	d2,d3
	lsr.l	#4,d3
	move.w	d3,aud1+ac_per(a5)
	move.w	a1,d1
	lsr.w	#6,d1

	btst	#9,d7
	beq.s	tone1
	move.w	#0,aud1+ac_vol(a5)
	bra.s	tone1off
tone1
	btst	#6,d1
	beq.s	noenv1
	move.l	#EnvelopeA,aud1+ac_ptr(a5)
	move.w	#Envlength,aud1+ac_len(a5)
	move.w	#63,d1
	lsr.w	#1,d3
	move.w	d3,aud1+ac_per(a5)
	bra.s	env1
noenv1
	move.l	#SquareWave,aud1+ac_ptr(a5)
	move.w	#$1,aud1+ac_len(a5)
env1
	or.w	#3,d1
	add.w	d1,d1
	move.w	(a3,d1.w),d1
	move.w	d1,aud1+ac_vol(a5)
tone1off

	lsl.l	#8,d5
	move.w	d4,d5
	lsr.l	#4,d5
	move.w	d5,aud2+ac_per(a5)
	move.w	a2,d2
	lsr.w	#6,d2

	btst	#10,d7
	beq.s	tone2
	move.w	#0,aud2+ac_vol(a5)
	bra.s	tone2off
tone2
	btst	#6,d2
	beq.s	noenv2
	move.l	#EnvelopeA,aud2+ac_ptr(a5)
	move.w	#Envlength,aud2+ac_len(a5)
	move.w	#63,d2
	lsr.w	#1,d5
	move.w	d5,aud2+ac_per(a5)
	bra.s	env2
noenv2
	move.l	#SquareWave,aud2+ac_ptr(a5)
	move.w	#$1,aud2+ac_len(a5)
env2
	or.w	#3,d2
	add.w	d2,d2
	move.w	(a3,d2.w),d2
	move.w	d2,aud2+ac_vol(a5)
tone2off

	btst	#11,d7
	beq.s	noise0
	moveq.w	#0,d0
noise0
	btst	#12,d7
	beq.s	noise1
	moveq.w	#0,d1
noise1
	btst	#13,d7
	beq.s	noise2
	moveq.w	#0,d2
noise2

	cmp.w	d0,d1
	blt.s	d1notlessthan
	exg	d1,d0
d1notlessthan
	cmp.w	d0,d2
	blt.s	d2notlessthan
	exg	d2,d0
d2notlessthan

	btst	#11,d7
	beq.s	Noiseon
	btst	#12,d7
	beq.s	Noiseon
	btst	#13,d7
	beq.s	Noiseon
	move.w	#0,aud3+ac_vol(a5)
Noisereturn
	rts

Noiseon
	move.l	#Noise+8,aud3+ac_ptr(a5)
	move.w	#3500,aud3+ac_len(a5)
	lsr.w	#8,d6
	add.w	#128,d6
	move.w	d6,aud3+ac_per(a5)
	add.w	d1,d0
	add.w	d2,d0
	ext.l	d0
	divu	#3,d0
	move.w	d0,aud3+ac_vol(a5)
	bra.s	Noisereturn

Squarewave	dc.w	$7fff
Envlength	equ	2
EnvelopeA
	dc.w	$7f00,$ff00
Noise
	incbin	df1:NOISE.SAM
logtable
	dc.w	0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3
	dc.w	3,3,3,3,4,4,4,4,5,5,5,6,6,7,7,7
	dc.w	8,9,9,10,10,11,12,13,13,14,15,16,17,19,20,21
	dc.w	23,24,26,27,29,31,33,36,38,41,43,46,49,53,56,60
	dc.w	64

*****************************************************************************
* LOAD MUSIC INTO MEMORY			    			    *
*****************************************************************************

	include	DOSroutines.i

Filenameaddress
	dc.l	0

Loadfile
	moveq	#2,d2
	move.l	a0,Filenameaddress
	beq	Nofile

	move.b	(a0)+,d0
	subi.b	#$30,d0
	blt.s	Loopfindendstring
	cmpi.b	#10,d0
	bge.s	Loopfindendstring

	cmpi.w	#1,d0
	bne.s	testforspace
	move.b	(a0),d1
	subi.b	#$30,d1
	blt.s	testforspace
	cmpi.b	#10,d1
	bge.s	Loopfindendstring
	addi.b	#10,d1
	cmpi.b	#" ",1(a0)
	bne.s	Loopfindendstring
	ext.w	d1
	move.w	d1,tunenumber
	addq.l	#3,Filenameaddress
	bra.s	Loopfindendstring

testforspace
	cmpi.b	#" ",(a0)+
	bne.s	Loopfindendstring
	ext.w	d0
	move.w	d0,tunenumber
	addq.l	#2,Filenameaddress

Loopfindendstring
	cmpi.b	#$a,(a0)+
	bne.s	Loopfindendstring
	clr.b	-1(a0)

	bsr	Claimmemory
	moveq	#2,d2
	tst.l	d0
	beq.s	Nofile
	bsr	F_OpenDOS
	move.l	Filenameaddress,d1
	move.l	#1005,d2
	bsr	F_Open
	moveq	#1,d2
	tst.l	d1
	beq.s	Nofile
	move.l	muz,d2
	move.l	#Memorysize,d3
	bsr	F_Read
	bsr	F_Close
	moveq	#0,d2
	rts
Nofile
	rts

*****************************************************************************
* Memory claiming routines						    *
*****************************************************************************

Claimmemory
	move.l	4.w,a6
	move.l	#Memorysize,d0
	move.l	#$10002,d1
	jsr	-198(a6)
	move.l	d0,muz
	rts

Releasememory
	move.l	4.w,a6
	move.l	muz,a1
	move.l	#Memorysize,d0
	jsr	-210(a6)
	rts

Memorysize	=	$4000

muz	dc.l	0
tunenumber
	dc.w	1

Intblock
	dc.l	0,0
	dc.b	2,-128
	dc.l	IntTitle
	dc.l	0,Main
IntTitle
	dc.b	"ST chip emulator interrupt",0
