; Version 1.00 Comptage des cycles et incrustation en fullscreen.
;	    Code par Ziggy STARDUST from the Overlanders.
;	    (C) 1er Juillet 1990
;
; Version 1.00 Debugg‚e pour l'instruction Adda.w/.l
;
; Version 1.10 Debugg‚e par Terence from Pendragons
; 	    instructions lsr.x #xx,dn install‚e
; 	    routine de soundtracker install‚e
;	    (Elle buguait ma routine???)
;
; Version 1.11 Hey! Terence, t'a rien modifi‚ a ma routine digit!!!
;	     Qu'est ce que tu raconte?
;
; Version 1.12 Ha bah! si, tu l'a modifie, et maintenant, elle plante!!
;	Enfin... Bugue corrig‚!
;
; Version 1.13 Hey Ziggy tu ne connais pas l'astuce de l'USP , parce que 
; le nombre de cycle de ces instructions deconnaient !! Enfin bug corrig‚...
;
; En prevision:
; Version 2.00	Special TT, si j'ai un jour le courage de le faire...
;		(et un TT a ma disposition, bien sur!)

colonne:	equ	28

	opt	o+,o2+,x+,w-

nnop	macro
	dcb.w	\1,$4e71
	endm
	
Vsync	macro
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	endm
	
print	macro
	pea	\1
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
	
	dc.w	$a00a

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	move.w	#3,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.l	#4,sp

	
	lea	digibord,a0
	lea	prg,a1
	lea	prgi,a2
	
	jsr	incrust_prg
	move.l	a1,fprg
	move	#$4e75,(a1)+

	move.w	#$666,$ffff8246.w
	move.w	#$000,$ffff8240.w
	
	print	ncycle1
	move.l	rcycle,d7
	add.l	d7,d7
	add.l	d7,d7
	bsr	affn
	
	print	ncycle2
	move.l	cycle,d7
	add.l	d7,d7
	add.l	d7,d7
	bsr	affn

	print	ncycle3
	move.l	fcycle,d7
	add.l	d7,d7
	add.l	d7,d7
	bsr	affn
	
	print	pnline
	move.l	rcycle,d7
	addi.l	#127,d7
	divs	#128,d7
	ext.l	d7
	bsr	affn
	
	print	tprg1
	move.l	#fprgi-prgi,d7
	bsr	affn

	print	tprg2
	move.l	fprg,d7
	subi.l	#prg,d7
	bsr	affn
	
	print	percent
	
	move.l	cycle,d0
	move.l	rcycle,d1
	divs	#100,d1
	divs	d1,d0
	ext.l	d0
	subi.w	#100,d0
	neg.w	d0
	move.l	d0,d7
	bsr	affn
	
	print	percent2
	
	move.l	rcycle,d0
	move.l	#160000/4,d1
	divs	#100,d1
	divs	d1,d0
	ext.l	d0
	move.l	d0,d7
	bsr	affn
	
	print	percent3

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
*	jsr	test_full
	
	print	fini
	
	dc.w	$a009
	move.l	#$8000,a0
	move.l	#$8000,a1
	move.l	#$8000,a2
	move.l	#$8000,a3
	move.l	#$8000,a4
	move.l	#$8000,a5
	move.l	#$8000,a6

	move.l	#prg,d0
	move.l	fprg,d1
	sub.l	#1,d1

	illegal

	move.w	#0,-(sp)
	pea	nom
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle
	
	tst.w	d0
	bmi.s	error
	
	pea	prg
	move.l	fprg,a0
	sub.l	#prg,a0
	move.l	a0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	
	tst.w	d0
	bmi.s	error

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi.s	error
	
	clr.w	-(sp)
	trap	#1
	
error	
	print	erreur
	
wait_key	cmp.b	#$39,$fffffc02.w
	bne.s	wait_key

	illegal
erreur	dc.b	"une erreur s'est produite lors de la sauvegarde  !!",10,13
	dc.b	"Presser Espace......",0
	even
handle	ds.w	1
nom	dc.b	"FLL1.S",0
	even
	
affn:
	lea	num,a6
	
affn1:
	divs	#10,d7
	move.w	d7,-(a7)
	swap	d7
	addi.w	#'0',d7
	move.b	d7,-(a6)
	
	move.w	(a7)+,d7
	ext.l	d7
	bne.s	affn1
	
	print	(a6)

	rts
	
test_full:
	cmpi.b	#$39,$fffffc02.w
	beq.s	test_full
	
loopfull:
	Vsync
	
	move	#$2700,sr
	
	lea	prgi,a6
.wspot:
	tst.b	$ffff8209.w
	beq.s	.wspot
	
	moveq	#0,d0
	move.b	$ffff8209.w,d0
	neg	d0
	lsl	d0,d0
	
	not	$ffff8240.w
	
	lea	$ffff820a.w,a0
	lea	$ffff8260.w,a1
	moveq	#0,d0
	
	nnop	27
	jsr	prg
	
	not	$ffff8240.w
	
	move	#$2300,sr
	
	cmpi.b	#$39,$fffffc02.w
	bne	loopfull
	
	move.b	#1,$ffff8260.w
	move.b	#2,$ffff820a.w

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
	rts

incrust:
	add.w	d0,d1
	cmp.w	(a0),d1
	ble.s	oknop
	
	move.l	d2,-(a7)
	sub.w	d0,d1
	move.w	(a0)+,d2
	sub.w	d2,d1
	neg.w	d1
	ext.l	d1
	add.l	d1,fcycle
	add.l	d1,rcycle
	subq.w	#1,d1
	tst.w	d1
	blt.s	noround
	
round:
	move.w	#$4e71,(a1)+
	dbra	d1,round
	
noround:
	move.w	(a0)+,d2
	subq.w	#1,d2
	
copi:
	move.b	(a0)+,(a1)+

	dbra	d2,copi
	
	move.w	(a0)+,d1
	ext.l	d1
	add.l	d1,fcycle
	add.l	d1,rcycle
	move.l	(a0)+,a0
	cmp.l	#bord,a0
	bne.s	noaline
	addq.w	#1,nline
	move	nline(pc),$ffff8240.w
	
noaline:
	bsr.s	incrust

	move.l	(a7)+,d2
oknop:
	rts
	
digibord:
	dc.w	128-17-20,48-12
	
	move.b	d0,(a0)
	move.w	a1,(a0)
	
	move.w	(a6)+,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	$800.l,a0
	adda.w	d0,a0
	move.l	(a0)+,d0
	
	move.w	a1,(a1)
	move.b	#0,(a1)
	
	movep.l	d0,$800-$260(a1)
	lea	$ffff820a.w,a0
	dc.w	31
	dc.l	digibord2
	
digibord2:
	dc.w	34,6
	move	a1,(a1)
	moveq	#0,d0
	move.b	d0,(a1)
	dc.w	5
	dc.l	bord
	
bord:
	dc.w	128-34,4	; Taille en octets
	move.b	d0,(a0)
	move	a1,(a0)
	dc.w	4		; Nombre de nops
	dc.l	borg1
	
borg1:
	dc.w	17,2
	move.w	a1,(a1)
	dc.w	2		
	dc.l	borg2
	
borg2:
	dc.w	3,2
	move.b	d0,(a1)
	dc.w	2
	dc.l	borg3
	
borg3:
	dc.w	14,2
	move.w	a1,(a1)
	dc.w	2
	dc.l	borg4
	
borg4:
	dc.w	3,2
	move.b	d0,(a1)
	dc.w	2
	dc.l	digibord

debut	equ	1356-36-160*4-16*24	* don't touch dis !!

tab230:	ds.l	1
tabpred:	ds.l	1
regscroll:	ds.L	5
bri:	ds.l	1

prgi:

corps:
	movem.l	regscroll,d4/a2-a5

	lea	bri,a7
	moveq	#7,d5

	rept	colonne

	moveq	#0,d7		* 4
	move.b	(a2)+,d7		* 8
	lsl.w	d5,d7		* 20
	lea	(a7,d7.w),a4	* 12
	adda.w	d4,a4		*  8 = 52
	
	movem.l	(a4)+,d1-d4	44

	move.l	d1,(a3)+		12
	move.l	d2,(a3)+		12
	move.l	d1,(a4)+		12
	move.l	d2,(a4)+		12
	move.l	d1,(a5)+		12
	move.l	d2,(a5)+		12
	movem.l	d3-d4,230-8(a3)	28
	movem.l	d3-d4,230-8(a4)	28
	movem.l	d4-d4,230-8(a5)	28	200
	endr

fprgi:
	dc.l	-1

	
incrust_prg:
	clr.l	fcycle
	clr.l	rcycle
	clr.l	cycle
	clr.l	nline

	move.w	(a0),d1
loop:
	move.w	(a2),d6
	
	moveq	#-1,d3
	lea	tabinst-10,a6
identinst:
	lea	10(a6),a6
	move	(a6),d4
	cmp	d3,d4
	beq	errorinst
	
	move.w	d6,d5
	and.w	d4,d5
	cmp.w	2(a6),d5
	bne.s	identinst
	
	move.w	6(a6),d0
	move.w	8(a6),d5
	
	move.w	d6,d4
	andi.w	#%111111,d4
	move.w	d4,d3
	lsr.w	#3,d3
	cmpi.w	#6,d3
	ble.s	okreg
	andi.w	#%111,d4
	add.w	d4,d3
	
okreg:
	cmpi.w	#-1,4(a6)
	bne.s	okword
	
	add.w	d3,d3
	add.w	d3,d3
	lea	tword,a4
	add.w	(a4,d3.w),d0
	add.w	2(a4,d3.w),d5
	
	bra.s	oklong
	
okword:
	cmpi.w	#-2,4(a6)
	bne.s	oklong
	
	add.w	d3,d3
	add.w	d3,d3
	lea	tlong,a4
	add.w	(a4,d3.w),d0
	add.w	2(a4,d3.w),d5
	
oklong:
	cmpi.w	#-3,4(a6)
	bne.s	okmovemw
	
	add.w	d3,d3
	add.w	d3,d3
	lea	tword,a4
	add.w	(a4,d3.w),d0
	add.w	2(a4,d3.w),d5
	moveq	#4,d3
	
	bra.s	calcmovem
	
okmovemw:
	cmpi.w	#-4,4(a6)
	bne.s	okmoveml
	
	add.w	d3,d3
	add.w	d3,d3
	lea	tword,a4
	add.w	(a4,d3.w),d0
	add.w	2(a4,d3.w),d5
	moveq	#8,d3
	
calcmovem:
	move.w	2(a2),d4
	moveq	#15,d2
loopcalc:
	btst	d2,d4
	beq.s	noaddcycle
	add.w	d3,d0
	
noaddcycle:
	dbra	d2,loopcalc
	
okmoveml:
	move.w	d0,d2
	lsr.w	#2,d0
	and.w	#3,d2
	beq.s	okroundcycle
	addq.w	#1,d0

okroundcycle:
	ext.l	d0
	add.l	d0,rcycle
	add.l	d0,cycle
	jsr	incrust
	
	subq.w	#1,d5
	
coprg:
	move.w	(a2)+,(a1)+
	dbra	d5,coprg
	
	cmpi.l	#-1,(a2)
	bne	loop
	
	cmpa.l	#bord,a0
	bne.s	nobord
	
.depbord:
	move	#$4e71,(a1)+
	moveq	#1,d0
	jsr	incrust
	
	cmpa.l	#bord,a0
	beq.s	.depbord
	
nobord:
	move	#$4e71,(a1)+
	moveq	#1,d0
	jsr	incrust
	
	cmpa.l	#bord,a0
	bne.s	nobord
	
	rts
	
errorinst:
	clr.w	$ffff8240.w
	illegal
	
fcycle	dc.l	0
rcycle	dc.l	0
cycle	dc.l	0
nline	dc.w	0
	
tword:
	dc.w	0,0
	dc.w	0,0
	dc.w	4,0
	dc.w	4,0
	dc.w	6,0
	dc.w	8,1
	dc.w	10,1
	dc.w	8,1
	dc.w	12,2
	dc.w	8,1
	dc.w	10,1
	dc.w	4,1
	
tlong:
	dc.w	0,0	; Dn
	dc.w	0,0	; An
	dc.w	8,0	; (An)
	dc.w	8,0	; (An)+
	dc.w	10,0	; -(An)
	dc.w	12,1	; d(An)
	dc.w	14,1	; d(An,Dn.x)
	dc.w	12,1	; xxx.w
	dc.w	16,2	; xxxxxx.l
	dc.w	12,1	; d(Pc)
	dc.w	14,1	; d(Pc,Dn.x)
	dc.w	8,2	; #xxxxxx
	
tabinst:

;      fedcba9876543210  fedcba9876543210    9876543210    		; Lsr(l)/Asr/Ror
N	set	0
	rept	8
 dc.w %1111111000000000,%1110000000000000+N*%1000000000,0,6+2*(N),1	Lsr.w
 dc.w %1111111000000000,%1110000000000000+N*%1000000000,0,8+2*(N),1	Lsr.l
N	set	N+1
	endr
;      fedcba9876543210  fedcba9876543210		; Movep
 dc.w %1111000101111000,%0000000100001000,0,16,2	; Movep.w
 dc.w %1111000101111000,%0000000101001000,0,24,2	; Movep.l
 
;      fedcba9876543210  fedcba9876543210		; Operation sur les bits
 dc.w %1111000111000000,%0000000100000000,-1,6,1	; Btst Dx,<Ae>
 dc.w %1111111111000000,%0000100100000000,-1,8,2	; Btst #X,<Ae>
 dc.w %1111000100000000,%0000000100000000,-1,8,1	; Bchg,Bset,etc... Dx,<Ae>
 dc.w %1111111100000000,%0000100000000000,-1,12,2	; Bchg,Bset,etc... #X,<Ae>
 
;      fedcba9876543210  fedcba9876543210		; Cmpi
 dc.w %1111111110111000,%0000110000000000,0,8,2		; Cmpi.w #x,Dn
 dc.w %1111111110000000,%0000110000000000,-1,8,2	; .w #x,M
 dc.w %1111111110111000,%0000110010000000,0,14,3	; .l #x,Dn
 dc.w %1111111110000000,%0000110010000000,-2,12,3	; .l #x,M
 
;      fedcba9876543210  fedcba9876543210		; Addi Ori Andi Eori
 dc.w %1111000010111000,%0000000000000000,0,8,2		; Addi,ori,andi,....w #x,Dn
 dc.w %1111000010000000,%0000000000000000,-1,12,2	; .w #x,M
 dc.w %1111000010111000,%0000000010000000,0,16,3	; .l #x,Dn
 dc.w %1111000010000000,%0000000010000000,-2,20,3	; .l #x,M
 
;      fedcba9876543210  fedcba9876543210		; Move.l
 dc.w %1111000111000000,%0010000000000000,-2,4,1	; Move.l Dn,<Ae>
 dc.w %1111000111000000,%0010000001000000,-2,4,1	; Move.l An,<Ae>
 dc.w %1111000110000000,%0010000010000000,-2,12,1	; Move.l (An)(+),<Ae>
 dc.w %1111000111000000,%0010000100000000,-2,14,1	; Move.l -(an),<Ae>
 dc.w %1111000111000000,%0010000101000000,-2,16,2	; Move.l D(An),<Ae>
 dc.w %1111000111000000,%0010000110000000,-2,18,2	; Move.l D(An,Dx),<Ae>
 dc.w %1111111111000000,%0010000111000000,-2,16,2	; Move.l $xxx.w,<Ae>
 dc.w %1111111111000000,%0010001111000000,-2,20,3	; Move.l $xxx.l,<Ae>
 dc.w %1111111111000000,%0010010111000000,-2,16,2	; Move.l D(Pc),<Ae>
 dc.w %1111111111000000,%0010011111000000,-2,18,2	; Move.l D(Pc,Dx),<Ae>
 dc.w %1111111111000000,%0010100111000000,-2,12,3	; Move.l #xxx,<Ae>
 
;      fedcba9876543210  fedcba9876543210		; Move.w
 dc.w %1101000111000000,%0001000000000000,-1,4,1	; Move.w Dn,<Ae>
 dc.w %1101000111000000,%0001000001000000,-1,4,1	; Move.w An,<Ae>
 dc.w %1101000110000000,%0001000010000000,-1,8,1	; Move.w (An)(+),<Ae>
 dc.w %1101000111000000,%0001000100000000,-1,10,1	; Move.w -(an),<Ae>
 dc.w %1101000111000000,%0001000101000000,-1,12,2	; Move.w D(An),<Ae>
 dc.w %1101000111000000,%0001000110000000,-1,14,2	; Move.w D(An,Dx),<Ae>
 dc.w %1101111111000000,%0001000111000000,-1,12,2	; Move.w $xxx.w,<Ae>
 dc.w %1101111111000000,%0001001111000000,-1,16,3	; Move.w $xxx.l,<Ae>
 dc.w %1101111111000000,%0001010111000000,-1,12,2	; Move.w D(Pc),<Ae>
 dc.w %1101111111000000,%0001011111000000,-1,14,2	; Move.w D(Pc,Dx),<Ae>
 dc.w %1101111111000000,%0001100111000000,-1,8,2	; Move.w #xxx,<Ae>
 
;      fedcba9876543210  fedcba9876543210		; Ext,Tst,Tas
 dc.w %1111111110111000,%0100100010000000,0,4,1		; Ext (.w)(.l)
 dc.w %1111111110000000,%0100101000000000,-1,4,1	; Tst.w <Ae>
 dc.w %1111111110000000,%0100101010000000,-2,4,1	; Tst.l <Ae>
 dc.w %1111111111111000,%0100101011000000,0,4,1		; Tas Dn
 dc.w %1111111111000000,%0100101011000000,-1,10,1	; Tas M

;      fedcba9876543210  fedcba9876543210		; Move Sr Ccr Usp
 dc.w %1111111111110000,%0100111001100000,0,8,1		; Move Usp (-> et <-)
 dc.w %1111110111000000,%0100010011000000,-1,12,1	; Move <Ae>,Ccr ou Sr
 dc.w %1111111111111000,%0100000011000000,0,6,1		; Move Sr,Dn
 dc.w %1111111111000000,%0100000011000000,-1,8,1	; Move Sr,<Ae>
 
;      fedcba9876543210  fedcba9876543210		; Neg(X) Not
 dc.w %1111100110111000,%0100000000000000,0,4,1		; Negx,Neg,Not.w Dn,Dn
 dc.w %1111100110000000,%0100000000000000,-1,8,1	; ...w Dn,M
 dc.w %1111100110111000,%0100000010000000,0,6,1		; ...l Dn,Dn
 dc.w %1111100110000000,%0100000010000000,-1,14,1	; ...l Dn,M

;      fedcba9876543210  fedcba9876543210		; Clr
 dc.w %1111111110111000,%0100001000000000,0,4,1		; Clr.w Dn
 dc.w %1111111110000000,%0100001000000000,-1,8,1	; Clr.w M
 dc.w %1111111110111000,%0100001010000000,0,6,1		; Clr.l Dn
 dc.w %1111111110000000,%0100001010000000,-2,12,1	; Clr.l M
 
;      fedcba9876543210  fedcba9876543210		; Nbcd et Swap
 dc.w %1111111111000000,%0100100000000000,-1,8,1	; Nbcd <Ae>
 dc.w %1111111111111000,%0100100001000000,0,4,1		; Swap R

;      fedcba9876543210  fedcba9876543210		; Movem
 dc.w %1111111111000000,%0100100010000000,-3,4,2	; Movem.w Dx/Ax,<Ae>
 dc.w %1111111111000000,%0100110010000000,-3,8,2	; Movem.w <Ae>,Dx/Ax
 dc.w %1111111111000000,%0100100011000000,-4,4,2	; Movem.l Dx/Ax,<Ae>
 dc.w %1111111111000000,%0100110011000000,-4,8,2	; Movem.l <Ae>,Dx/Ax

;      fedcba9876543210  fedcba9876543210		; Link Unlink
 dc.w %1111111111111000,%0100111001010000,0,16,2	; Link
 dc.w %1111111111111000,%0100111001011000,0,12,1	; Unlnk

; Nop!!
 dc.w $4e71,$4e71,0,4,1
 
;      fedcba9876543210  fedcba9876543210		; Lea Pea
 dc.w %1111111111000000,%0100100001000000,-1,8,1	; Pea 
 dc.w %1111000111000000,%0100000111000000,-1,0,1	; Lea 
 
;      fedcba9876543210  fedcba9876543210		; Addq/Subq
 dc.w %1111000010111000,%0101000000000000,0,4,1		; Addq/Subq.w #x,Dn
 dc.w %1111000010000000,%0101000000000000,-1,8,1	; .w #x,<Ae> - Dn
 dc.w %1111000010110000,%0101000010000000,0,8,1		; .l #x,Dn/An
 dc.w %1111000010000000,%0101000010000000,-2,12,1	; .l #x,<Ae> - Dn/An

;      fedcba9876543210  fedcba9876543210		; Moveq
 dc.w %1111000100000000,%0111000000000000,0,4,1		; Moveq #x,Rn
 
;      fedcba9876543210  fedcba9876543210		; Subx/Addx
 dc.w %1011000110111000,%1001000100000000,0,4,1		; Subx/Addx.w Dn,Dn
 dc.w %1011000110111000,%1001000100001000,0,18,1	; .w M,M
 dc.w %1011000110111000,%1001000110000000,0,8,1		; .l Dn,Dn
 dc.w %1011000110111000,%1001000110001000,0,30,1	; .l M,M
 
;      fedcba9876543210  fedcba9876543210		; Exg
 dc.w %1111000111111000,%1100000101000000,0,6,1		; Exgd Dn,Dn
 dc.w %1111000111111000,%1100000101001000,0,6,1		; Exga An,an
 dc.w %1111000111111000,%1100000110001000,0,6,1		; Exgm Dn,An
 
;      fedcba9876543210  fedcba9876543210		; Cmp/Cmpa
 dc.w %1111000110000000,%1011000010000000,-1,6,1	; Cmpa.w <Ae>,An
 dc.w %1111000110000000,%1011000000000000,-1,4,1	; Cmp.w <Ae>,Dn
 dc.w %1111000111000000,%1011000111000000,-2,6,1	; Cmpa.l <Ae>,An
 dc.w %1111000110000000,%1011000010000000,-2,6,1	; Cmp.l <Ae>,Dn
 
;      fedcba9876543210  fedcba9876543210		; Sbcd/Abcd
 dc.w %1011000111111000,%1000000100000000,0,6,1		; Sbcd/Abcd Dn,Dn
 dc.w %1011000111111000,%1000000100001000,0,18,1	; M,M

;      fedcba9876543210  fedcba9876543210		; Adda/Suba.w
 dc.w %1011000111000000,%1001000011000000,-1,8,1	;Adda/Suba.w <Ae>,An
 dc.w %1011000111000000,%1001000111000000,-2,6,1	;Adda/Suba.l <Ae>,An

;      fedcba9876543210  fedcba9876543210		; Or/Sub/Add/And/Eor
 dc.w %1000000110000000,%1000000000000000,-1,4,1	; Or/Sub/Add/And/Eor.w <Ae>,Dn
 dc.w %1000000110000000,%1000000100000000,-1,8,1	; .w Dn,M
 dc.w %1000000110000000,%1000000010000000,-2,6,1	; .l <Ae>,Dn
 dc.w %1000000110000000,%1000000110000000,-2,12,1	; .l Dn,M
 
	dc.l	-1
	
ncycle1:	dc.b	10,13,"Nombre de cycle totale: ",0
ncycle2:	dc.b	10,13,"Nombre de cycle programme: ",0
ncycle3:	dc.b	10,13,"Nombre de cycle fullscreen: ",0
pnline:	dc.b	10,13,"Nombre de ligne de fullscreen: ",0
tprg1:	dc.b	10,13,10,13,"Taille programme initial: ",0
tprg2:	dc.b	10,13,"Taille programme fullscreen‚: ",0
percent:	dc.b	10,13,10,13,0
percent2:	dc.b	"% pris par le fullscreen.",10,13,10,13,0
percent3:	dc.b	"% de la VBL pris.",10,13,10,13
	dc.b	"Appuyez sur une touche...",0
	
fini:
	dc.b	27,"f"
	dc.b	0
	
	ds.b	100
num:
	dc.b	0

	
	section	bss
tata:
	ds.L	10


ptrestore11:	ds.l	1
ptrestore21:	ds.l	1
ptrestore31:	ds.l	1
ptrestore41:	ds.l	1
ptrestore51:	ds.l	1
ptrestore61:	ds.l	1
ptrestore71:	ds.l	1
ptrestore81:	ds.l	1
ptrestore91:	ds.l	1
ptrestore101:	ds.l	1


posx1:	ds.w	1
posy1:	ds.w	1
posx2:	ds.w	1
posy2:	ds.w	1
posx3:	ds.w	1
posy3:	ds.w	1
posx4:	ds.w	1
posy4:	ds.w	1
posx5:	ds.w	1
posy5:	ds.w	1
posx6:	ds.w	1
posy6:	ds.w	1
posx7:	ds.w	1
posy7:	ds.w	1
posx8:	ds.w	1
posy8:	ds.w	1
posx9:	ds.w	1
posy9:	ds.w	1
posx10:	ds.w	1
posy10:	ds.w	1

ecr1:	ds.l	1

pttabpred1:	ds.l	1
pttabpred2:	ds.l	1
pttabpred3:	ds.l	1
pttabpred4:	ds.l	1
pttabpred5:	ds.l	1
pttabpred6:	ds.l	1
pttabpred7:	ds.l	1
pttabpred8:	ds.l	1
pttabpred9:	ds.l	1
pttabpred10:	ds.l	1
fprg	ds.l	1


prg:
