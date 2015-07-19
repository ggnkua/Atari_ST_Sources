	opt	o+,ow-
;
CPU	EQU	1		;0=CHANGE COULEUR BORDURE
;
	section	text
;
; programme de saisie de FSEL
;
	move.l	4(a7),a3		base page
	lea	pile(pc),sp
	move.l	sp,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,ecran1
	add.l	#32000,d0
	move.l	d0,ecran2

	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	pea	(a3)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp
;
; APPL_INIT
;
	lea	control(pc),a1
	move.w	#10,(a1)+			store the op code
	clr.w	(a1)+			do control1
	move.w	#1,(a1)+		and control2
	clr.w	(a1)+			and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1
	move.w	#200,d0			function number
	trap	#2
;
; MESSAGE
;
	dc.w	$a00a
	pea	message(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	dc.w	$a009
;
; FSEL_INPUT
;
	move	#$19,-(sp)
	trap	#1		;GET DISK
	addq	#2,sp
	add	#'A',d0
	move.b	d0,path
	move.b	#":",path+1

	clr	-(sp)
	pea	path+2(pc)
	move	#$47,-(sp)
	trap	#1		;GET CURRENT DIR
	addq	#8,sp
	tst	d0
	bne	quit2		;erreur

	lea	path(pc),a1
pafin1	tst.b	(a1)+
	bne.s	pafin1
	subq	#1,a1
	move.b	#'*',(a1)+
	move.b	#'.',(a1)+
	move.b	#'P',(a1)+
	move.b	#'I',(a1)+
	move.b	#'1',(a1)+
	clr.b	(a1)

	move.l	#path,addr_in
	move.l	#filename,addr_in+4
	moveq	#90,d0
	lea	control(PC),a1
	move.w	#90,(a1)+		store the op code
	clr.w	(a1)+			do control1
	move.w	#2,(a1)+		and control2
	move.w	#2,(a1)+		and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1
	move.w	#200,d0			function number
	trap	#2
	move.w	int_out,d0		usually a returned value
	move	int_out+2,d1

	tst	d1
	beq	quit		;ANNULER ?
	tst	d0
	beq	quit		;ERREUR

	MOVE	#$2F,-(SP)
	trap	#1			;GETDTA
	addq	#2,sp
	move.l	d0,savdta
;
; reprend le CHDIR
;
	lea	path(pc),a1
pafin	tst.b	(a1)+
	bne.s	pafin
setoi	cmp.b	#'.',-(a1)
	bne.s	setoi
	addq	#1,a1
	move.b	#'P',(a1)+
	move.b	#'I',(a1)+
	move.b	#'1',(a1)+
	clr.b	(a1)
;
; effectue le DIRECTORY
;
	pea	dta(pc)
	move	#$1a,-(sp)
	trap	#1			;SETDTA
	addq	#6,sp

	lea	dir(pc),a5
	move.l	a5,a6
	move	#$27,-(sp)	;cherche tous les fichiers
	pea	path(pc)
	move	#$4e,-(sp)
	trap	#1			;SEARCH FIRST
	addq	#8,sp
	tst	d0
	bne	quit2
nxtdir
	lea	triname(pc),a1
	move.l	#'    ',d0
	move.l	d0,(a1)
	move.l	d0,4(a1)
	move.l	d0,8(a1)
	lea	dta+30(pc),a0
	moveq	#7,d1
file1	move.b	(a0)+,d0		;on prend le pr‚fixe
	beq.s	nxtfile
	cmp.b	#'.',d0
	beq.s	file2
	move.b	d0,(a1)+
	dbra	d1,file1
	cmp.b	#'.',(a0)+
	bne.s	nxtfile
file2
	lea	triname+8(pc),a1
	move.b	#'.',(a1)+
	moveq	#2,d1
file3	move.b	(a0)+,d0
	beq.s	nxtfile
	move.b	d0,(a1)+
	dbra	d1,file3
nxtfile
	move.l	dta+26(pc),triname+12		;nb octets du fichier
;
; ici on insŠre triname
;  dans dir
;
	lea	triname(pc),a0
	cmp.l	a6,a5
	beq.s	inserename	;si 1 seul nom-> on insŠre
;
; tri par l'extension puis le nom
;
	move.l	a5,a1
comp2
	move.l	a1,a2
	lea	triname(pc),a0
	move.l	8(a0),d0
	cmp.l	8(a2),d0
	blo.s	insere
	bne.s	comp4
	cmp.l	(a2)+,(a0)+
	blo.s	insere
	bne.s	comp4
	cmp.l	(a2)+,(a0)+
	blo.s	insere
comp4
	lea	16(a1),a1
	cmp.l	a6,a1
	blo.s	comp2
inserename
	move.l	a6,a1
	bra.s	noins
insere
	move.l	a6,a0
insj	move.l	-(a0),16(a0)
	cmp.l	a1,a0
	bne.s	insj
noins
	lea	triname(pc),a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	16(a6),a6

	move	#$37,-(sp)
	pea	path(pc)
	move	#$4f,-(sp)
	trap	#1		;SEARCH NEXT
	addq	#8,sp
	tst	d0
	beq	nxtdir
;
; LOAD files
;
	pea	super1(pc)
	move	#38,-(sp)
	trap	#14		;push video registers
	addq	#6,sp
	dc.w	$a00a		;hide mouse

	lea	dir(pc),a5
loadfile
	tst.b	(a5)
	beq	quit3

	lea	file(pc),a2
	lea	path(pc),a1
loadf1	move.b	(a1)+,(a2)+
	bne.s	loadf1
	subq	#5+1,a2		;revient sur *.PI1

	moveq	#11,d0
loadf3	move.b	(a5)+,d1
	cmp.b	#' ',d1
	beq.s	loadf5
	move.b	d1,(a2)+
loadf5
	dbra	d0,loadf3
	clr.b	(a2)+
	move.l	(a5)+,d7		;nb octets
	move.l	a5,ptrdir
;
; routine de chargement de fichier
;
; en entr‚e :
;	d7 contient le nb d'octets … charger
; en sortie :
;	d7 contient le nb d'octets charg‚s
;
	clr	-(sp)
	pea	file(pc)
	move	#$3d,-(sp)
	trap	#1		;OPEN
	addq	#8,sp
	tst	d0
	bmi	errload
	move	d0,d5
	pea	mfree
	move.l	d7,-(sp)
	move	d5,-(sp)
	MOVE	#$3F,-(SP)
	trap	#1		;READ
	lea	12(sp),sp
	tst.l	d0
	bmi	errload
	move.l	d0,d7
	move	d5,-(sp)
	move	#$3e,-(sp)
	trap	#1		;CLOSE
	addq	#4,sp
	tst.l	d0
	bmi	errload

	lea	mfree,a5		;a5=d‚but fichier
	lea	0(a5,d7.L),a6		;a6=fin fichier

	bsr	pi1
	tst.l	d0
	bmi	errload

	pea	affiche(pc)
	move	#38,-(sp)
	trap	#14
	addq	#6,sp

	bsr	geniff		;compression IFF
;
; SAUVE
;				;oui-> sauvegarde de fichier
	pea	file(pc)
	move	#$41,-(sp)
;	trap	#1		;delete last file .PI1
	addq	#6,sp

	lea	file(pc),a0
hfin	tst.b	(a0)+
	bne.s	hfin
	subq	#4,a0
	move.b	#'I',(A0)+
	MOVE.B	#'F',(A0)+
	MOVE.B	#'F',(A0)

	pea	file(pc)
	move	#$41,-(sp)
	trap	#1		;delete last file .IFF
	addq	#6,sp

	clr	-(sp)
	pea	file(pc)
	move	#$3c,-(sp)
	trap	#1		;CREATE
	addq	#8,sp
	tst	d0
	bmi.s	errload
	move	d0,d5
	pea	mfree
	move.l	a5,d7
	sub.l	(sp),d7

	btst	#0,d7
	beq.s	mangled
	clr.b	(a5)+
	addq.l	#1,d7
mangled

	move.l	d7,-(sp)	;nb octets
	move	d5,-(sp)
	MOVE	#$40,-(SP)
	trap	#1		;SAVE
	lea	12(sp),sp
	tst.l	d0
	bmi.s	errload
	move	d5,-(sp)
	move	#$3e,-(sp)
	trap	#1		;CLOSE
	addq	#4,sp
	tst.l	d0
	bpl.s	nxtload
errload:
	pea	erreur(pc)
	move	#38,-(sp)
	trap	#14
	addq	#6,sp

nxtload:
	move.l	ptrdir(pc),a5
	bra	loadfile
quit3
	pea	super2(pc)
	move	#38,-(sp)
	trap	#14		;restore video regs
	addq	#6,sp
quit2:
;
; APPL_EXIT
;
	move.l	savdta(pc),-(sp)
	move	#$1a,-(sp)
	trap	#1			;SETDTA
	addq	#6,sp
quit:
	lea	control(pc),a1
	move.w	#19,(a1)+		store the op code
	clr.w	(a1)+			do control1
	move.w	#1,(a1)+		and control2
	clr.w	(a1)+			and control3
	clr.w	(a1)			assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1
	move.w	#200,d0			function number
	trap	#2

	clr	-(a7)
	trap	#1			;RETURN TO DESKTOP

super1:
	MOVE	SR,-(SP)
	OR	#$700,sr
	move.b	$ffff8260.w,savrez
	lea	$ffff8200.w,a0
	movep	1(a0),d0
	move	d0,savadrecr
	lea	savpal(pc),a0
	lea	$ffff8240.w,a1
	moveq	#7,d0
copal1	move.l	(a1)+,(a0)+
	dbra	d0,copal1
	RTE
super2:
	move	#37,-(sp)
	trap	#14		;waitvbl
	addq	#2,sp
	MOVE	SR,-(SP)
	OR	#$700,sr
	move.b	savrez,$ffff8260.w
	move	savadrecr,d0
	lea	$ffff8200.w,a0
	movep	d0,1(a0)
	lea	$ffff8240.w,a0
	lea	savpal(pc),a1
	moveq	#7,d0
copal2	move.l	(a1)+,(a0)+
	dbra	d0,copal2
	RTE
erreur	eor	#$700,$ffff8240.w
	rts
affiche:
	move	#37,-(sp)
	trap	#14		;waitvbl
	addq	#2,sp
	move	sr,-(sp)
	or	#$700,sr
	clr.b	$ffff8260.w
	movem.l	newpal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	moveq	#0,d0
	move	savadrecr(pc),d0
	asl.l	#8,d0
	move.l	d0,a0
	move.l	ecran1(pc),a1
	move	#32000/8-1,d0
aff1:	move.l	(a1)+,(a0)+
	move.L	(a1)+,(a0)+
	dbra	d0,aff1
	rte
;
; transfert image PI1
;
; format :
;	0.w=r‚solution
;	2 … 34=palette
;	34 … 32034=image
;
; entr‚e :
;	a5=adresse d‚but fichier
;	a6=adresse fin fichier
;
erresol	moveq	#-1,D0
	rts
pi1:
	tst	(a5)+
	bne.s	erresol
	lea	newpal(pc),a0
	moveq	#16/2-1,d0
pi11	MOVE.L	(A5)+,(a0)+
	dbra	d0,pi11

	move.l	ecran1(pc),a0
	move	#32000/4-1,d0
pi12	move.l	(a5)+,(a0)+
	dbra	d0,pi12
	moveq	#0,d0		;pas d'erreur
	rts
;
; transfert IFF
;
; entr‚e :
;	a5=d‚but fichier IFF
;	a6=fin fichier IFF
;
iff:
	move.l	a5,a0
ifcmap	cmp.l	a6,a0
	bhs.s	erreif
	cmp.l	#'CMAP',(a0)+
	bne.s	ifcmap
	cmp.l	#48,(a0)+
	beq.s	iffpaer
erreif	moveq	#-1,d0
	rts
iffpaer
	lea	newpal(pc),a1
	moveq	#16-1,d2	;nb couleurs !!
setcolif
	move.b	(a0)+,d1
	asl	#8-5,d1
	and	#$700,d1
	move.b	(a0)+,d0
	lsr	#5-4,d0
	and	#$070,d0
	or	d0,d1
	move.b	(a0)+,d0
	lsr	#5,d0
	and	#7,d0
	or	d0,d1
	move	d1,(a1)+
	dbra	d2,setcolif

ifbody
	cmp.l	a6,a5
	bhs.s	erreif
	cmp.l	#'BODY',(A5)+
	BNE.S	ifbody
	addq	#4,a5		;NB OCTETS DU BODY (INUTILE)

	bsr	decomp
	moveq	#0,d0		;pas d'erreur
	RTS

geniff:
	lea	mfree,a5
	move.l	#'FORM',(A5)+
	CLR.L	(A5)+		;NB OCTETS DU DESSIN
	MOVE.L	a5,ptr1
	move.l	#'ILBM',(A5)+
	MOVE.L	#'BMHD',(A5)+
	MOVE.L	#$14,(A5)+
	MOVE	#$140,(A5)+
	MOVE	#$C8,(A5)+
	clr.l	(a5)+
	move.l	#$04020100,(a5)+
	MOVE.L	#$A0B,(A5)+
	MOVE	#$140,(A5)+
	MOVE	#$C8,(A5)+

	MOVE.L	#'CMAP',(A5)+
	move.l	#48,(a5)+

	lea	newpal(pc),a1
	moveq	#16-1,d2	;nb couleurs !!
setcoli
	MOVE.B	(A1)+,D0
	ASL	#5,D0
	MOVE.B	D0,(A5)+	;COMPOSANTE R
	MOVE.B	(A1),D0
	AND	#$F0,D0
	add	d0,d0
	MOVE.B	D0,(A5)+	;COMPOSANTE V
	MOVE.B	(A1)+,D0
	ASL	#5,D0
	MOVE.B	D0,(A5)+	;COMPOSANTE B
	dbra	d2,setcoli
	MOVE.L	#'BODY',(A5)+
	CLR.L	(A5)+
	move.L	a5,ptr2

	move.l	ecran1(pc),a0
	move.l	ecran2(pc),a3
	MOVE	#200-1,D0
IFF70	MOVEQ	#20-1,D1
IFF80
	move	(a0)+,(a3)+
	move	(a0)+,38(a3)
	move	(a0)+,78(a3)
	move	(a0)+,118(a3)
	DBF	D1,IFF80
	lea	160-40(a3),a3
	DBF	D0,IFF70

compact
	move.l	ecran2(pc),a6
	move	#4*200-1,d7
comp1
	move.l	a6,a4
	bsr	comp
	lea	40(a6),a6
	dbra	d7,comp1

	pea	(a5)
	move.L	ptr2,a0
	sub.l	a0,a5
	move.l	a5,-4(a0)
	move.l	(sp),a5
	move.l	ptr1,a0
	sub.l	a0,a5
	move.l	a5,-4(a0)
	move.L	(sp)+,a5
	rts
;
; COMPACTAGE D'OCTETS
;
; ENTREE :
;	D1.W=nb octets
;	A4=adresse source
;	a5=adresse destination
;
; SORTIE :
;	A4=adresse 1er octet n'ayant pu etre compact‚
;	a5=adresse fin des octets compact‚s
;
comp:
	moveq	#40-1,d1
	move.b	(a4)+,d0
entete:
	move	a4,d2
	move.l	a5,a2
	clr.b	(a5)+
	cmp.b	(a4),d0
	bne.s	copy
;	cmp.b	1(a4),d0
;	bne.s	copy
	bra.s	pareil
trans:	move.b	(a4)+,d0
	cmp.b	(a4),d0
;	bne.s	copy
;	cmp.b	1(a4),d0
	beq.s	change
copy:	move.b	d0,(a5)+
	dbra	d1,trans
	sub	a4,d2
	neg	d2
	move.b	d2,(a2)
	rts
change:	tst	d1
	beq.s	copy
	sub	a4,d2
	not	d2
	move.b	d2,(a2)
	move	a4,d2
	move.l	a5,a2
	clr.b	(a5)+
pareil:	move.b	d0,(a5)+
compar:	cmp.b	(a4)+,d0
	dbne	d1,compar
	beq.s	differe
	subq	#1,d1
	blt.s	differe
	move.b	-1(a4),d0
	sub	a4,d2
	addq	#1,d2
	move.b	d2,(a2)
	bra.s	entete
differe:
	sub	a4,d2
	addq	#1,d2
	move.b	d2,(a2)
	rts
;
; transfert image NEO
;
; format :
;	0.w=rien
;	2.w=r‚solution
;	4 … 36=palette
;	128=image
;
; entr‚e :
;	a5=adresse d‚but fichier
;	a6=adresse fin fichier
;
neo:
	tst.l	(a5)+
	bne	erresol
	lea	newpal(pc),a0
	moveq	#16/2-1,d0
neo1	MOVE.L	(A5)+,(a0)+
	dbra	d0,neo1

	lea	128-36(a5),a5
	move.l	ecran1(pc),a0
	move	#32000/4-1,d0
neo2	move.l	(a5)+,(a0)+
	dbra	d0,neo2
	moveq	#0,d0		;pas d'erreur
	rts
;
; transfert image PC1
;
; format :
;	0.w=r‚solution+$8000
;	2 … 34=palette
;	34=image
;
; entr‚e :
;	a5=adresse d‚but fichier
;	a6=adresse fin fichier
;
pc1:
	cmp	#$8000,(a5)+
	bne	erresol
	lea	newpal(pc),a0
	moveq	#16/2-1,d0
pc11	MOVE.L	(A5)+,(a0)+
	dbra	d0,pc11

	bsr	decomp
	moveq	#0,d0		;pas d'erreur
	rts
;
; routine de d‚compression IFF et PC1 !!!!
;
decomp
	move.l	ecran2(pc),a4
	move	#32000-1,d1
pcline1
	moveq	#0,d0
	move.b	(a5)+,d0
	bmi.s	pcline3
pcline4	move.b	(a5)+,(a4)+
	subq	#1,d1
	dbmi	d0,pcline4
	bpl.s	pcline1		;D1<0 ?
	bra.s	IFF6
pcline3	neg.b	d0
	move.b	(a5)+,d2
pcline5	move.b	d2,(a4)+
	subq	#1,d1
	dbmi	d0,pcline5
	bpl.s	pcline1		;D1<0 ?
IFF6
	move.l	ecran2(pc),a3
	move.l	ecran1(pc),a0
	MOVE	#200-1,D0
IFF7	MOVEQ	#20-1,D1
IFF8	MOVE	(A3)+,(A0)+
	MOVE	38(A3),(A0)+
	MOVE	78(A3),(A0)+
	MOVE	118(A3),(A0)+
	DBF	D1,IFF8
	lea	160-40(a3),a3
	DBF	D0,IFF7
	rts
	SECTION DATA
message
	dc.b	27,'E'
	dc.b	'IFF to PI1 V1.0',13,10
	DC.B	'By JCM',13,10,13,10
	dc.b	'Attention les fichiers .PI1 seront d‚truits !!!',13,10

	dc.b	0
	even

path:	ds.b	64
filename:
	dc.b	'FILE.PI1',0
	ds.b	64

* this is a table of pointers to all the AES arrays

aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out

	SECTION	BSS
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1

ptr1		ds.l	1
ptr2		ds.l	1
ptrdir		ds.l	1
ecran1		ds.l	1
ecran2		ds.l	1
savdta		ds.l	1
newpal		ds.w	16
savadrecr	ds.w	1
savrez		ds.b	1
savfreq		ds.b	1
savpal		ds.w	16
;
; variables pour accŠs disques
;
file		ds.b	80
		even
triname		ds.b	16
dta		ds.b	44
		even
dir		ds.b	16*200		;200 fichiers
		even
	ds.b	100		;100 octets pour la pile
pile
	ds.b	32000*2+255
	even
mfree:
