numflares:	EQU	1
flareradius:	EQU	56
flarelines:	EQU	3
flarecenter:	EQU	(flareradius*2*flareradius)+flareradius


	COMMENT	HEAD=%111

	bra	START

	INCLUDE	IO.S
	TEXT

START:	
	lea	flarefield_buf,a0
	bsr	MAKE_LENSFLAREBUF

	lea	flarename_txt,a0
	lea	flarefield_buf,a1
	move.l	#flareradius*2*flareradius*2,d0
	bsr	save

	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

* Very fast and accurate squareroot algorithm.
* Quite lengthy, though: 64 bytes.
* INPUT: d1.l: value to calculate the squareroot of (integer)
* OUTPUT: d0.l: squareroot of value (16.16 fixed point)
CALC_SQUAREROOT:
	moveq	#1,d2
	ror.l	#2,d2
	moveq	#$F,d3
.loop1:	cmp.l	d2,d1
	bgt.s	.endloop1
	add.l	d1,d1
	lsr.l	#1,d2
	dbf	d3,.loop1
	bra.s	.end
.endloop1:

	sub.l	d2,d1
	move.l	d2,d0
	lsr.l	#1,d2
.loop2:	lsr.l	#1,d2
	add.l	d2,d0
	cmp.l	d0,d1
	bgt.s	.endloop2
	sub.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2
	bra.s	.end
.endloop2:

	sub.l	d0,d1
	add.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2

.end:	add.l	d0,d0
	addi.l	#$00008000,d0
	rts

* Routine that calculates bandlimited noise.
* Each integer has a different random value.
* INPUT: d0.l: 16.16 fixed point number x
* OUTPUT: d0.l 16.16 fixed point limited random number
CALC_NOISE1D:
	move.w	random,d2

	move.l	d0,d4
	sub.w	d0,d0				* i:=floor(x)
	sub.l	d0,d4				* f:=x-i
	swap	d0

	move.w	d0,d1

	rol.w	d0,d0
	eor.w	d2,d0
	eor.w	d1,d0

	addq.w	#1,d1

	move.w	d1,d3

	rol.w	d1,d1
	eor.w	d2,d1
	eor.w	d3,d1

* d0.w: n0:=rand(i)
* d1.w: n1:=rand(i+1)
	sub.w	d0,d1				* n1-n0
	muls.w	d1,d4				* (n1-n0)*f
	add.l	d4,d4
	swap	d4
	add.w	d4,d0				* n0 + (n1-n0)*f
	rts

* INPUT: a0: address of destination heightfieldbuffer
MAKE_LENSFLAREBUF:
	move.w	#-flareradius+1,d7

.yloop:	move.w	#-flareradius+1,d6

.xloop:	move.w	d6,d0
	move.w	d7,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1				* dsqr:=dx*dx+dy*dy
	fmove.l	d1,fp0
	fsqrt	fp0				* d:=sqrt(dsqr)
	fmul.s	#1.0,fp0			* d:=d*flarediameter

	fmove	fp0,fp1
	fneg	fp1
	fmove	fp1,fp2
	fmul	fp0,fp1				* /
	fmul.s	#0.006,fp1			* \ fp1:=-d*d*gauss
	fetox	fp1				* /
	fmul.s	#0.5,fp1			* \ fp1:=exp(-d*d*gauss)*mix
	fmul.s	#0.03,fp2			* /
	fetox	fp2				* | fp2:=exp(-d*linear)*(1-mix)
	fmul.s	#0.5,fp2			* \ 
	fadd	fp1,fp2				* a:=fp1+fp2

	fcmp.s	#43.4,fp0			* /
	fble	.endcalcring			* | if d < rmin or d > rmax
	fcmp.s	#46.6,fp0			* | then
	fble	.calcring			* \
	fmove.s	#0,fp4				* ring:=0
	bra.s	.endcalcring
.calcring:
	fmove	fp0,fp3				* /
	fsub.s	#45,fp3				* | ring:=fabs(d-rmid)/rwid
	fabs	fp3				* |
	fdiv.s	#1.6,fp3			* \
	fmove	fp3,fp4				* /
	fadd	fp3,fp4				* |
	fsub.s	#3,fp4				* |
	fneg	fp4				* | ring:=1-ring*ring*(3-2*ring)
	fmul	fp3,fp4				* |
	fmul	fp3,fp4				* |
	fneg	fp4				* |
	fadd.s	#1,fp4				* \
	fmul.s	#0.1,fp4			* ring:=ring*0.10
	fadd	fp4,fp2				* a:=a+ring
.endcalcring:

.dolines:
;	fmove.w	d6,fp5				* /
;	fdiv.w	d7,fp5				* | v:=fatan(x/y)+pi
;	fatan	fp5				* |
;	fadd.s	#3.141562,fp5			* \
;	fmove	fp5,fp6				* /
;	fmul.s	#655360,fp5			* |
;	fmove.l	fp5,d0				* |
;	bsr	CALC_NOISE1D			* |
;	fmove.l	d0,fp5				* |
;	fdiv.s	#65536,fp5			* | v:=(fmod(v/pi*17 +1.0+Noise1D(v*10), 1) - 0.5)*2
;	fadd.s	#1,fp5				* |
;	fdiv.s	#3.141562,fp6			* |
;	fmul.s	#17,fp6				* |
;	fadd	fp5,fp6				* |
;	fmod.s	#1.0,fp6			* |
;	fsub.s	#0.5,fp6			* |
;	fadd	fp6,fp6				* \
;	fabs	fp6				* v:=|v|
;	fmove	fp6,fp7				* /
;	fmul	fp6,fp6				* |
;	fmul	fp6,fp6				* | v:=v^5
;	fmul	fp7,fp6				* \

;	fmul.s	#0.1,fp6			* /
;	fmul.s	#0.1,fp0			* |
;	fadd.s	#1,fp0				* | a:= a + (0.1*v / (1 + d*0.1))
;	fdiv	fp0,fp6				* |
;	fadd	fp6,fp2				* \

	fcmp.s	#1,fp2				* /
	fble	.notclipped			* \ if a > 1 then
	fmove.s	#1,fp2				* a:=1
.notclipped:
	fmul.s	#255,fp2
	fmove.w	fp2,d0
	move.b	d0,(a0)+
	
	addq.w	#1,d6
	cmpi.w	#flareradius+1,d6
	bne	.xloop

	addq.w	#1,d7
	cmpi.w	#flareradius+1,d7
	bne	.yloop
	rts

******** DATA AND INCLUDES ********

	DATA

flareflow_tbl:
	DC.W	20
	DC.W	4
	DC.L	$00000000	;DC.L	$00000000
	DC.L	$00000000	;DC.L	$003f0000
	DC.L	$3f000000	;DC.L	$007f0000
	DC.L	$7f000000	;DC.L	$3fdf0000
	DC.L	$bf1f0000	;DC.L	$7fff0000
	DC.L	$ff3f0000	;DC.L	$dfff0000
	DC.L	$ff7f0000	;DC.L	$ffff0000
	DC.L	$ffbf0000	;DC.L	$ffff003f
	DC.L	$ffff0000	;DC.L	$ffff007f
	DC.L	$ffff001f	;DC.L	$ffff00bf
	DC.L	$ffff003f	;DC.L	$ffff00ff
	DC.L	$ffff007f	;DC.L	$ffff00ff
	DC.L	$ffff00bf	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff

flarename_txt:
	DC.B	"FLARE.DAT",0
flarepicname_txt:
	DC.B	"FLARE.RAW",0

	EVEN

******** RESERVES ********

	BSS

random:	DS.L	1
flarefield_buf:
	DS.B	flareradius*2*flareradius*2
