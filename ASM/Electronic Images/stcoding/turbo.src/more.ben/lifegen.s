;
; Ben's LIFE...
;

;#########
	section	text
low	equ	0
med	equ	1
hi	equ	2	
;##########################
rez	equ	low ;********* CHANGE REZ CORRECT *****
;##########################
	ifeq	rez-low
voff    equ     160
mr	equ	8
rt	equ	1
wcount  equ     (4000-voff)-1
bits	equ	15
vln	equ	8
	endc
	ifeq	rez-med
voff    equ     160
mr	equ	4
rt	equ	1
wcount  equ     (8000-voff)-1
bits	equ	15
vln	equ	4
	endc
	ifeq	rez-hi
voff    equ     80
mr	equ	4
rt	equ	3
wcount  equ	(8000-voff)-1
bits	equ	31
vln	equ	4
	endc
;#########
lt	equ	-(mr-rt)
tl	equ	-voff+lt
bl	equ	 voff+lt
tr	equ	-voff+mr
br	equ	 voff+mr
;##########
moven	macro 
	ifeq	rez-hi
	move.l  \1,\2
	endc
	ifeq	rez-med
	move.w	\1,\2
	endc
	ifeq	rez-low
	move.w  \1,\2
        endm
;##########
tstn	macro 
	ifeq	rez-hi
	tst.l  \1
	endc
	ifeq	rez-med
	tst.w	\1
	endc
	ifeq	rez-low
	tst.w  \1
        endm
;##########
main	bsr	init
loop	bsr	life
	bsr	move
	move.w	#$00ff,-(sp)	;check for any key press..
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	beq.s	loop
exit	
	move.w	#1,-(sp)		;go back to med. rez
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#0,-(sp)
	trap	#1
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
init
	clr.w	-(sp)		;go to lo-rez
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#27,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	move.w	#'f',-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a1
	move.l	a1,oscrp
	lea	scrn1,a0
	move.l	a0,scrnp
	move.w	#7999,d0
clslp	clr.l	(a1)+
	clr.l	(a0)+
	dbra	d0,clslp
	
;############# input data
	bsr	input
	rts
;~~~~~~~~~	
move	move.w	#7999,d0
	move.l	oscrp,a1
	move.l	scrnp,a0
mvlp	move.l	(a0)+,(a1)+
	dbra	d0,mvlp
	rts
;#############################################################
life	move.l	scrnp,a0	;destination
	move.w 	#7999,d7	;long  count
cllp	clr.l	(a0)+
	dbra	d7,cllp
	move.l	scrnp,a0	;destination
	move.l	oscrp,a1	;source
	lea	voff(a0),a0
	lea	voff(a1),a1	;not top line!!
	move.w	#wcount,d7
lvrt	
	moven	-voff(a1),d1	;top    long
	moven	0(a1),d2	;centre long
	moven	voff(a1),d3  	;bottom long
	move.l	#bits,d6        ;15 for low/med, 31 for high..
	tstn	d1
	bne	normal          ;bits set in top
	tstn	d2
	bne	normal		;bits set in current
	tstn	d3
	bne	normal		;bits set below..
;#######################
faster				;to get here, just test edges..
	moveq.l	#0,d0
	btst	#0,tl(a1)	;test top left
	beq.s	s1
	addq.l	#1,d0
s1	btst	#0,lt(a1)	;test mid left
	beq.s	s2
	addq.l	#1,d0
s2	btst	#0,bl(a1)	;test bot left
	beq.s	s3
	addq.l	#1,d0	
s3	cmp.b	#3,d0
	bne.s	nohi
	move.b	(a0),d0
	bset	#7,d0
	move.b	d0,(a0)
nohi
	moveq.l	#0,d0
	btst	#7,tr(a1)	;test top right
	beq.s	s4
	addq.l	#1,d0
s4	btst	#7,mr(a1)	;test mid right
	beq.s	s5
	addq.l	#1,d0
s5	btst	#7,br(a1)	;test bot right
	beq.s	s6
	addq.l	#1,d0	
s6	cmp.b	#3,d0
	bne.s	nolo
	move.b	rt(a0),d0
	bset	#0,d0
	move.b	d0,rt(a0)
nolo	bra	wdfin
;#######################
;first bit special case..
normal
	moveq.l	#0,d0
	moveq.l	#0,d4
	btst	#0,tl(a1)	;test top left
	beq.s	f1
	addq.l	#1,d0
f1	btst	#0,lt(a1)	;test mid left
	beq.s	f2
	addq.l	#1,d0
f2	btst	#0,bl(a1)	;test bot left
	beq.s	f3
	addq.l	#1,d0	
f3	btst	d6,d1	;test top
	beq.s	f4
	addq.l	#1,d0
f4	btst	d6,d2	;test current
	beq.s	f5
	moveq.l	#1,d4
f5	btst	d6,d3	;test bottom
	beq.s	f6
	addq.l	#1,d0
f6	subq.l	#1,d6
	btst	d6,d1	;test top right
	beq.s	f7
	addq.l	#1,d0
f7	btst	d6,d2	;test mid right
	beq.s	f8
	addq.l	#1,d0
f8	btst	d6,d3	;test bot right
	beq.s	f9
	addq.l	#1,d0
f9	addq.l	#1,d6		;back to 15 or 31
	cmp.b	#2,d0
	blt.s	fdone		;alive?
	cmp.b	#3,d0
	bgt.s	fdone
	beq.s	fbirt
fcont	tst.b	d4
	beq.s	fdone
fbirt	moven	(a0),d4
	bset	d6,d4		;give birth		
	moven	d4,(a0)
fdone				;bit 31 done..
;#######################
central	moveq.l #0,d0
	moveq.l	#0,d4
	btst	d6,d1	;test top left
	beq.s	n1
	addq.l	#1,d0
n1	btst	d6,d2	;mid left
	beq.s	n2
	addq.l	#1,d0
n2	btst	d6,d3	;bot left
	beq.s	n3
	addq.l	#1,d0
n3	subq.l	#1,d6	;bit count down 1
	btst	d6,d1	;test top 
	beq.s	n4
	addq.l	#1,d0
n4	btst	d6,d2	;current
	beq.s	n5
	addq.l	#1,d4
n5	btst	d6,d3	;test bot 
	beq.s	n6
	addq.l	#1,d0
n6	subq.l	#1,d6	;bit count down 1
	btst	d6,d1	;test top left
	beq.s	n7
	addq.l	#1,d0
n7	btst	d6,d2	;mid left
	beq.s	n8
	addq.l	#1,d0
n8	btst	d6,d3	;bot left
	beq.s	n9
	addq.l	#1,d0
n9	addq.l	#1,d6	;bit count up 1 for next test
	cmp.b	#2,d0
	blt.s	ndone
	cmp.b	#3,d0
	bgt.s	ndone
	beq.s	nbirt
ncont	tst.b	d4
	beq.s	ndone
nbirt	moven	(a0),d4
	bset	d6,d4
	moven	d4,(a0) ;born
ndone	cmp.w	#1,d6    
	bgt.s	central	;do next bit..
;#######
;last bit is special case too..
	moveq.l	#0,d0
	moveq.l	#0,d4
	btst	#7,tr(a1)	;test top right
	beq.s	l1
	addq.l	#1,d0
l1	btst	#7,mr(a1)	;test mid right
	beq.s	l2
	addq.l	#1,d0
l2	btst	#7,br(a1)	;test bot right
	beq.s	l3
	addq.l	#1,d0	
l3	btst	#0,d1		;test top
	beq.s	l4
	addq.l	#1,d0
l4	btst	#0,d2		;test current
	beq.s	l5
	addq.l	#1,d4
l5	btst	#0,d3		;test bottom
	beq.s	l6
	addq.l	#1,d0
l6	btst	#1,d1		;test top left
	beq.s	l7
	addq.l	#1,d0
l7	btst	#1,d2		;test mid left
	beq.s	l8
	addq.l	#1,d0
l8	btst	#1,d3		;test bot left
	beq.s	l9
	addq.l	#1,d0
l9	cmp.b	#2,d0		;alive?
	blt.s	ldone
	cmp.b	#3,d0
	bgt.s	ldone
	beq.s	lbirt
lcont	tst.b	d4
	beq.s	ldone
lbirt	moven	(a0),d4
	bset	#0,d4	;born
	moven	d4,(a0)
ldone
;#######################	
wdfin	addq.l	#vln,a0
	addq.l	#vln,a1
	dbra	d7,lvrt
	rts
;###########################################################
input
	move.l	oscrp,a2
	add.l	off1,a2
	jsr	locomotive
	rts
;###########################################################
locomotive
	lea	Ggun,a0
	move.l	a2,a1
	add.l	(a0)+,a1
	move.l	(a0)+,d0
inlp1	
        ifeq	rez-hi
	move.l	(a0)+,(a1)
	endc
	ifeq	rez-med
	move.w	(a0)+,(a1)
	move.w  (a0)+,4(a1)
	endc
	ifeq	rez-low
	move.w	(a0)+,(a1)
	move.w  (a0)+,8(a1)
	endc
	lea	voff(a1),a1
	dbra	d0,inlp1
	rts
;#############

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section	data
off1	dc.l	12000
;Glider gun from 13 gliders
Ggun	dc.l	80,41		;offset & no. of lines
	dc.l	%00000000000000000011100000000000
	dc.l	%00000000000000000010000000000000
	dc.l	%00000000000000011001000000000000
	dc.l	%00000000000000101000000000000000
	dc.l	%00000000000000001000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000110000000000000
	dc.l	%00000000000011101100000000000000
	dc.l	%00000000000000100010000000000000
	dc.l	%00000000000001000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000110000000000000000000
	dc.l	%00000000000011000000000000000000
	dc.l	%00000000000100000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000001110000000000000000000
	dc.l	%00000000000010000000000000000000
	dc.l	%00000000000100000001100000000000
	dc.l	%00000000000000111011000000000000
	dc.l	%00000000000000001000100000000000
	dc.l	%00000000000000010000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00011000000001100000000000000000
	dc.l	%00101000000000110000000000000000
	dc.l	%00001000000001000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000 
	dc.l	%00000000000000000000011100000000 
	dc.l	%00000000000000000000010000000000
	dc.l	%00000000000000000011001000000000
	dc.l	%00000000000000000101000000000000
	dc.l	%00000000000000000001000000000000
	dc.l	%00000001110000000000000000000000
	dc.l	%00000000010000000000000000000000
	dc.l	%00000000100000000000000000000000
	dc.l	%00000000000000000000000000000000

section	bss
scrnp   ds.l    1
oscrp   ds.l    1
scrn1	ds.l	8000
	end 