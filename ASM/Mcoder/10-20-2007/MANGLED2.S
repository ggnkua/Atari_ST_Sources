	opt	o+,ow-
;
; debugge les fichiers IFF amiga
;
; Mangled disparait en rajoutant un octet 00 Ö la fin du code
;
OPTIM	EQU	0
;
	section	text
;
; programme de saisie de FSEL
;
	move.l	4(a7),a3		base page
	lea	pile(pc),sp

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
	move.b	#'I',(a1)+
	move.b	#'F',(a1)+
	move.b	#'F',(a1)+
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
	move.b	#'I',(a1)+
	move.b	#'F',(a1)+
	move.b	#'F',(a1)+
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
file1	move.b	(a0)+,d0		;on prend le prÇfixe
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
; ici on insäre triname
;  dans dir
;
	lea	triname(pc),a0
	cmp.l	a6,a5
	beq.s	inserename	;si 1 seul nom-> on insäre
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
	lea	dir(pc),a5
loadfile
	tst.b	(a5)
	beq	quit3

	lea	file(pc),a2
	lea	path(pc),a1
loadf1	move.b	(a1)+,(a2)+
	bne.s	loadf1
	subq	#5+1,a2		;revient sur *.IFF

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
; en entrÇe :
;	d7 contient le nb d'octets Ö charger
; en sortie :
;	d7 contient le nb d'octets chargÇs
;

	move	#2,-(sp)	;open lecture/Çcriture
	pea	file(pc)
	move	#$3d,-(sp)
	trap	#1		;OPEN
	addq	#8,sp
	tst	d0
	bmi	errload
	move	d0,d5

	pea	mfree
	pea	8.w
	move	d5,-(sp)
	MOVE	#$3F,-(SP)
	trap	#1		;READ
	lea	12(sp),sp
	tst.l	d0
	bmi	errload

	move.l	mfree+4(pc),d0
	btst	#0,d0
	beq	nxtload

	addq.l	#1,d0
	move.l	d0,mfree+4

	move	#1,-(sp)	;mode relatif
	move	d5,-(sp)
	pea	-8.w
	move	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	tst.l	d0
	bmi	errload

	pea	mfree
	pea	8.w		;nb octets
	move	d5,-(sp)
	MOVE	#$40,-(SP)
	trap	#1		;SAVE
	lea	12(sp),sp
	tst.l	d0
	bmi.s	errload

	pea	file(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	pea	cr(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
nxtload
	move	d5,-(sp)
	move	#$3e,-(sp)
	trap	#1		;CLOSE
	addq	#4,sp

errload
;
; SAUVE
;				;oui-> sauvegarde de fichier
	move.l	ptrdir(pc),a5
	bra	loadfile
quit3
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

erreur	eor	#$700,$ffff8240.w
	rts
	SECTION DATA
message
	dc.b	27,'E'
	dc.b	'IFF to IFF V1.0',13,10
	DC.B	'By JCM',13,10,13,10
	dc.b	'Attention les fichiers impairs .IFF seront agrandis !!!',13,10

	dc.b	0
cr
	dc.b	13,10,0
	even

path:	ds.b	64
filename:
	dc.b	'FILE.IFF',0
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
savdta		ds.l	1
;
; variables pour accäs disques
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
	even
mfree:
