	opt	o+,ow2-
	nolist
	output	.tos
OFFSETMIN=2
MARK=1			;0=MARQUAGE TYPE DEPACKER
rsoff=0
rsfils=4
XOR=0			;0=HASH PAR XOR
;
; CE QUI RESTE A FAIRE
;
;	- mettre nb octets gagn‚s au fur et … mesure
;	- indiquer le tps en Heure,Minute,Seconde
;	- % de compression obtenu
;	- tests OUT OF MEM
;	- ajouter gestion directory (actuellement ne peut packer que
;	   des fichiers dans le meme directory !!!)
;	- File Selector (.PRG)
;	- Batch mode (.TTP)
;	- d‚packer n'efface pas bien la RAM
;
;	- bug possible dans d‚packer PACK (test dernier octet foireux ???)
;	- packer/d‚packer en (an)+ et -(an)
;	- ne pas packer les 2 zones de la meme fa‡on
;
;	+ r‚server m‚moire maximum (plante actuellement)
;	+ am‚liorer d‚packer (ne pas se mettre derriŠre l'‚cran)
;	+ d‚packers plantent si symboles
;	+ CLS au d‚but
;	+ dernier word … 0 enlev‚ !!!
;	+ impl‚mentation hash-code
;
; am‚liorations apport‚es le 02/04/90
;
;	+ sauver fichier en .HUF ou en .PAK si une des 2 compressions
;	   n'a pas r‚ussi (pas de gain d'octets)
;	+ affichage du temps mis pour la compression
;	+ tailles du fichier
;		Longueur originelle
;		Longueur finale
;		Gain en octets
;	+ % de packing
;	+ offset demand‚ au clavier
;	+ nom du fichier demand‚ au clavier
;	+ affichage de "Chargement de ..."
;	+ gestion m‚moire incr‚mentale
;	+ quand on tape CR -> directory affich‚ !!! (non)
;	+ interfa‡age avec HUF11.S
;	+ demande du type de compression (Huff+Pack,Huff ou Pack)
;	+ si .TOS,.PAK ou .CMP demander si on d‚gage l'entete
;	+ int‚grer offset
;	+ demande du nom en sortie quand un seul fichier (non)
;	+ g‚rer m‚moire correctement pour PACK16
;	+ int‚grer d‚packeur/relocateur
;
; liste des am‚liorations … apporter :
;	on peut packer des fichiers de la taille de la m‚moire centrale !!!!
;	il suffit :
;		1) de faire que ptrfinal=ptrdebut
;		    et g‚rer si on d‚borde
;		      (ce qui signifie que le fichier est plus gros !!!)
;		2) de stocker le fichier le plus en haut possible
;		    et d'effacer … partir du bas de la RAM
;
overlay = 0	;0=overlay final avec debut
; si TOPO8=1 -> gaintop=4 puis 3...
; si TOPO8=0 -> gaintop=5 puis 4 puis 3...
; TOPO8=1 plus int‚ressant que 0 !!!
gaintop = 4
TOPO8 = 1		;0=topo 8 bits, 1=topo 9 bits

PRINT	MACRO
	pea	\1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	ENDM
;
; initialisation des vecteurs
;
	move.l	4(sp),a0
	lea	pile(pc),sp
	move.l	$c(a0),d0	;taille prg
	add.l	$14(a0),d0	;taille data
	add.l	$1c(a0),d0	;taille bss
	add.l	#$100,d0	;+256=base page
	move.l	d0,-(sp)
	pea	(a0)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bne	bug31

	pea	-1.w
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp		;d0=nb octets libres

	sub.l	#$8000,d0	;32K pour le systŠme
	bmi	bug31

	move.l	d0,d7
	move.l	d0,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	bmi	bug31
	move.l	d0,ptr_buf_names
	add.l	d7,d0
	move.l	d0,ramtop

	clr.b	flag_entete

	PRINT	WELCOME
	PRINT	inputname
	bsr	input		;ok
	tst.b	(a0)
	beq	fin_code

	PRINT	recherche
	clr	compteur

	pea	dta(pc)
	move	#$1a,-(sp)
	trap	#1
	addq	#6,sp
	clr	-(sp)
	pea	filein(pc)
	move	#$4e,-(sp)
	trap	#1
	addq	#8,sp
	tst	d0
	bne	bug4
	move.l	ptr_buf_names(pc),filenames
count:
	addq	#1,compteur
	move.l	filenames(pc),a1
	lea	dta+26(pc),a0

	move.l	(a0)+,length

copysp1:move.b	(a0)+,(a1)+
	bne.s	copysp1

	move.l	a1,filenames

	PRINT	dta+30
	PRINT	spaces

	move.l	length(pc),d7
	bsr	aff_mixte
	bsr	cr

	clr	-(sp)
	pea	filein(pc)
	move	#$4f,-(sp)
	trap	#1
	addq	#8,sp
	tst	d0
	beq.s	count

	move.l	filenames(pc),d0
	addq.l	#1,d0
	bclr	#0,d0
	move.l	d0,ptr_buffer_hash


	cmp	#1,compteur
	beq.s	notm1
	PRINT	paramcons
notm1:

	lea	filein(pc),a0
searcpt2:
	tst.b	(a0)+
	bne.s	searcpt2

	subq	#5,a0
	move.b	(a0)+,d0
	asl	#8,d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	asl	#8,d0
	move.b	(a0)+,d0

	and.l	#$FFDFDFDF,d0

	cmp.l	#'.PRG',d0
	beq.s	tst_entet
	cmp.l	#'.TTP',d0
	beq.s	tst_entet
	cmp.l	#'.ACC',d0
	beq.s	tst_entet
	cmp.l	#'.TOS',d0
	bne.s	insv2
tst_entet:
	PRINT	mess_entet
	bsr	input		;ok
	moveq	#1,d7
	bsr	get_hexa
	bne.s	tst_entet
	subq.l	#1,d7
	cmp.l	#3,d7
	bhs.s	tst_entet
	move.b	d7,flag_entete
insv2:
	PRINT	memory
	move.l	ptr_buffer_hash(pc),d7
	move.l	d7,ptr_buf_debut
	bsr	aff_mixte
	bsr	cr

.inputtype:
	PRINT	mess_type
	bsr	input		;ok
	moveq	#1,d7
	bsr	get_hexa
	bne.s	.inputtype
	subq.l	#1,d7
	cmp.l	#3,d7
	bhs.s	.inputtype
	move.b	d7,type_comp

	cmp.b	#1,type_comp
	beq.s	nooffset
inputoff:
	PRINT	input_offset
	bsr	input		;ok
	move.l	#$100,d7
	bsr	get_hexa
	bne.s	inputoff
	addq.l	#1,d7		;offset mini=1 !!!
	cmp.l	#65536,d7	;offset max
	bhi.s	inputoff
	move.l	d7,offset
nooffset:
	move.l	offset(pc),d0	;r‚servation m‚moire pour offset
	asl.l	#3,d0
	addq.l	#8,d0
	add.l	d0,ptr_buf_debut

	move.l	ptr_buf_names(pc),cur_name
load_it:
	move.l	cur_name(pc),a0
	lea	filein(pc),a1
.load1	move.b	(a0)+,(a1)+
	bne.s	.load1
	move.l	a0,cur_name
;
; chargement du fichier
;
	PRINT	loadmess
	PRINT	filein
	bsr	cr

	clr	-(sp)
	pea	filein(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d7
	bmi	bug5

	move.l	ptr_buf_debut(pc),a6
	move.l	a6,ptrdebut
	cmp.b	#2,flag_entete
	bne.s	noskippe
	pea	(a6)
	pea	$1c.w		;on charge l'entete pour l'ignorer !!!
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug19
noskippe
	pea	(a6)
	pea	1<<31-1		;400 Ko charg‚s
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug6

	add.l	d0,a6		;a6=fin du fichier charg‚
	move.l	a6,ptrfin1

	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
;
; rajoute l'extension .PAK,.HUF,.CMP suivant compression
;
	lea	filein(pc),a0
	lea	fileout(pc),a1
searcpt:
	move.b	(a0)+,(a1)+
	bne.s	searcpt

	subq	#1,a1
	move.l	a1,a0
	moveq	#4-1,d0
sev:
	cmp.b	#'.',-(a1)
	beq.s	foundv
	dbra	d0,sev
	move.b	#'.',(a0)+
	bra.s	insv
foundv:
	lea	1(a1),a0
insv:
	move.b	type_comp(pc),d0
	bne.s	.not0
	move.b	#'C',(a0)+
	move.b	#'M',(a0)+
	move.b	#'P',(a0)+
	bra.s	.not3
.not0	subq.b	#1,d0
	bne.s	.not1
	move.b	#'H',(a0)+
	move.b	#'U',(a0)+
	move.b	#'F',(a0)+
	bra.s	.not3
.not1	move.b	#'P',(a0)+
	move.b	#'A',(a0)+
	move.b	#'K',(a0)+
.not3
	clr.b	(a0)+

	bsr	get_time
	move.l	time(pc),time2
;
; type_comp :
;	0->huff+pack
;	1->huff
;	2->pack
;
	move.l	ptrfin1(pc),d7
	sub.l	ptrdebut(pc),d7
	move.l	d7,longueur_source

	cmp.b	#1,type_comp
	beq.s	huffe1
	bsr	packer_byte
huffe1:
	cmp.b	#2,type_comp
	beq.s	huffe2
	bsr	huffmann
huffe2:
	bsr	get_time
	move.l	time(pc),d7
	sub.l	time2(pc),d7
	move.l	d7,time
;
; time.l=nb millisecondes pour compresser
;
	PRINT	mess4
	move.l	time(pc),d7
	bsr	decimal

	PRINT	mess5

	move.l	longueur_source(pc),d7
	bsr	aff_mixte

	PRINT	mess7

	move.l	ptrfin1(pc),d7
	sub.l	ptrdebut(pc),d7
	move.l	d7,longueur_dest
	bsr	aff_mixte

	PRINT	mess8

	move.l	longueur_source(pc),d7
	sub.l	longueur_dest(pc),d7

	tst.l	d7
	bpl.s	positif
	neg.l	d7
	moveq	#'-',d0
	bsr	put2
positif:
	bsr	aff_mixte

	bsr	cr

	move.l	longueur_source(pc),d7	;d7=nb octets source
	move.l	d7,d6
	sub.l	longueur_dest(pc),d6	;d6=nb octets gagn‚s
	bsr	percent
	PRINT	mess10
;
; d‚but du code=ptrfinal
; fin du code=ptrfin2
;
	PRINT	savemess
	PRINT	fileout
	bsr	cr

	pea	fileout(pc)
	move	#$41,-(sp)	;delete file (sinon bug 1eres ROMs)
	trap	#1
	addq	#6,sp

	clr	-(sp)
	pea	fileout(pc)
	move	#$3c,-(sp)	;create file
	trap	#1
	addq	#8,sp
	move	d0,d7
	bmi	bug7

;
; save entete si on veut...
;
	cmp.b	#1,flag_entete
	bne	pareloc

	PRINT	relogeur

	move.l	longueur_source(pc),d0
	addq.l	#1,d0
	bclr	#0,d0
	move.l	d0,longueur_source
	move.l	longueur_dest(pc),d0
	addq.l	#1,d0
	bclr	#0,d0
	move.l	d0,longueur_dest

	LEA	DECRUNCH0(PC),A0
	LEA	ENDCRUNCH0(PC),A1
	move.b	type_comp(pc),d0
	beq.s	goodrel
	LEA	DECRUNCH1(PC),A0
	LEA	ENDCRUNCH1(PC),A1
	subq.b	#1,d0
	beq.s	goodrel
	LEA	DECRUNCH2(PC),A0
	LEA	ENDCRUNCH2(PC),A1
goodrel:

	move.l	a1,a2
	sub.l	a0,a2
	add.l	longueur_dest(pc),a2
	lea	-$1c(a2),a2
	move.l	a2,2(a0)

	move.l	longueur_dest(pc),-8(a1)
	move.l	longueur_source(pc),-4(a1)
;
; sauver bloc A0-A1
;
	pea	(a0)		;start
	sub.l	a0,a1
	pea	(a1)		;length
	move	d7,-(sp)
	move	#$40,-(sp)	;save block
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug8
pareloc:

	move.l	ptrdebut(pc),-(sp)
	move.l	longueur_dest(pc),-(sp)
	move	d7,-(sp)
	move	#$40,-(sp)	;save block
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug8
	move	d7,-(sp)
	move	#$3e,-(sp)	;close file
	trap	#1
	addq	#4,sp

	subq	#1,compteur
	bne	load_it
fin_code
	PRINT	press_space
1$	move	#7,-(sp)
	trap	#1
	addq	#2,sp
	cmp	#' ',d0
	bne.s	1$
	clr	-(sp)
	trap	#1		;exit sans erreur

packer_byte:

	bsr	init_hash

;
; initialisations packer (04/04/90)
;
	clr.l	lasthex
	move	#-1,lastrep
	move	#-1,lasttopo
	lea	freq2(pc),a0
	moveq	#256*2/4-1,d0
clrfr2	clr.l	(a0)+
	dbra	d0,clrfr2
	ifne	1-TOPO8
	lea	freqtopo(pc),a0
	moveq	#256/4-1,d0
clrto	clr.l	(a0)+
	dbra	d0,clrto
	endc
	lea	freq(pc),a0
	moveq	#nbmeth-1,d0
clrmet	clr	(a0)+
	dbra	d0,clrmet
	lea	best(pc),a0
	moveq	#nbmeth*2-1,d0
clrbest	clr	(a0)+
	dbra	d0,clrbest
	lea	codes(pc),a0
	moveq	#nbmeth-1,d0
clearcodes:
	move	#-1,(a0)+
	dbra	d0,clearcodes
;
; am‚liorations du packer :
;
;	+1) augmenter la fr‚quence des topos, il suffit d'autoriser
;	   la topo meme si on ne gagne pas d'octets !
;	   cela permet de diminuer la fr‚quence globale des octets
;	   non compress‚s
;	2) essayer d'enlever les m‚thodes 5 et 7 ???
;	3) compresser le fichier … l'envers (cf BYTE-KILLER)
;	+4) am‚liorer topo 8 bits (voir plus loin)
;
; bug dans SEKA :
;	optimise les bra qui sont dans les IF non assembl‚s !!!
;
; nouvelle g‚n‚ration de compacteurs
;  V2.0 15/09/89
;  V2.1 20/09/89 gestion d'un seul segment, am‚lioration
;		 des offsets (-256), recherche des offsets
;		 les plus petits (pour compstr)
;
; 1Šre passe :
;	- d‚termine les diff‚rentes m‚thodes de compression
;	- calcule les occurrences des m‚thodes de compression
;	- calcule les fr‚quences des octets non compress‚s
; 2Šme passe :
;	- assigne 1 octet parmi les 12 octets les moins fr‚quents
;	  … chaque m‚thode de compression en fonction de leur occurrence
;	  (nocomp n'a pas de code assign‚ !!!)
; 3Šme passe :
;	- g‚nŠre le fichier compress‚ en octet
;	  (les 12 codes de compression sont les 12 premiers octets
;	   du fichier compress‚)
; 4Šme passe :
;	- codage par Huffmann du fichier compress‚ en octets
;
; astuces utilis‚es :
;	- les m‚thodes inutilis‚es ne doivent pas utiliser
;	   d'octet r‚serv‚...
;
; ci-dessous, les diff‚rentes m‚thodes de compression
;
;	0->pas de compression+2 bytes (compteur-1)
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
;	8->chaine de longueur 3+offset 8 bits
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
nbmeth = 12	;nb m‚thodes de compression
;
; registres utilis‚s :
;
;	a5=ptr courant
;	a6=ptr sur fin du code
;	a4=ptr sur segment compress‚
;
;	d7=nb octets gagn‚s
;	d6=meilleure m‚thode
;	d5=offset pour compression de chaines ou octet pour corr‚lation
;	d4=nb octets pour nocomp
;
	PRINT	mess1

	move.l	ptrdebut(pc),a5
	move.l	ptrfin1(pc),a6	;a6=fin du fichier
	move.l	a6,a4
	move.l	a6,ptrsegm
	moveq	#0,d4

	move.l	a5,current_a5

_boucle:
	bsr	hexa
	cmp.l	a6,a5
	bhs	fini

	moveq	#0,d7		;nb octets gagn‚s
	moveq	#0*4,d6		;meilleure m‚thode
;
; 1) r‚p‚tition de caractŠre
;
;	0->pr‚fixe
;	1->octet … r‚p‚ter
;	2->nb r‚p‚titions (8/16 bits)
;
; gain d'octets si plus de 3 octets se r‚pŠtent (>=3)
;
	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	(a0)+,d0
	bne.s	parepete
	cmp	lastrep(pc),d0
	beq.s	skip1
	cmp.b	(a0)+,d0
	bne.s	parepete
skip1:	cmp.l	a6,a0
	bhs.s	parepete
	cmp.b	(a0)+,d0
	bne.s	parepete
bcrep:
	cmp.l	a6,a0
	bhs.s	finrep
	cmp.b	(a0)+,d0
	beq.s	bcrep
	subq	#1,a0
finrep:
	move.l	a0,d1
	sub.l	a5,d1
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
	subq.l	#2,d1		;perte d'au moins 2 octets (entete)

	cmp.l	#256+3-2,d1	;si len>256 -> perte de 2 octets
	bhs.s	jlx
	cmp	lastrep(pc),d0
	beq.s	rep1		;si lastrep->ok
	subq.l	#1,d1		;si pas lastrep->perte d'1 octet
	bra.s	rep1
jlx:
	subq.l	#2,d1
rep1:
	cmp.l	d7,d1
	ble.s	parepete
	move.l	d1,d7		;nb octets gagn‚s
	moveq	#1*4,d6		;m‚thode 1 !!!
	move.l	a0,ptrfin
	cmp.l	a6,a0		;si jusqu'… la fin
	bhs	comprep		;-> on ne cherche pas plus loin

	move.l	a0,d0
	sub.l	a5,d0
	cmp.l	offset(pc),d0	;d‚passe l'offset ???
	bhs	comprep		;oui->fini

parepete:
;
; 2) r‚p‚tition de chaine dans le code pr‚c‚dent
;
;	0->pr‚fixe
;	1->Offset de la chaine (-1 … -65536)
;	2->longueur de la chaine (8/16 bits)
;
; gain d'octets si la chaine contient au moins 3 caractŠres (>=3)
;
	lea	3(a5),a0
	cmp.l	a6,a0		;s'il ne reste que 3 octets
	bhs	finstr		;on n'a rien … faire
;
; RECHERCHE DE CHAINES
;
; registres utilis‚s :
;	d0
;	a0,a1,a2
;	d1=longueur chaine
;	d3=offset chaine
;	d7=nb octets gagn‚s
;	a5=ptr source
;	a6=ptr fin source
;
; GESTION HASH-CODE
;
	MOVEQ	#0,D0
	MOVE.B	(A5),D0
	IFEQ	XOR
	MOVE.B	1(A5),D1
	EOR.B	D1,D0
	ENDC

	asl	#3,d0
	lea	occur(pc),a0
	add	d0,a0
	move.l	(a0),d0
	beq	finstr
loopsearch:
	move.l	d0,a2
	MOVE.L	rsoff(a2),a0	;OFFSET RECHERCHE

	MOVE.L	A5,A1
;	CMP.L	A0,A1
;	BEQ	bug22

	move.l	a5,d0
	sub.l	a0,d0
	bls	bug22
	cmp.l	#OFFSETMIN,d0
	blo	finstr

	IFEQ	XOR
	CMPM.B	(A0)+,(A1)+
	BNE.S	cmpch2
	ELSEIF
	CMPM.B	(A0)+,(A1)+
	BNE	bug23
	ENDC

	CMPM.B	(A0)+,(A1)+
	BNE.s	cmpch2

	CMPM.B	(A0)+,(A1)+
	BNE.s	cmpch2

CMPCH3:
	CMP.L	A6,A0
	BHS.S	CMPCH4
	CMP.L	A6,A1
	BHS.S	CMPCH4

	CMPM.B	(A0)+,(A1)+
	BEQ.S	CMPCH3
	SUBQ	#1,A1
CMPCH4:
	MOVE.L	A1,D1
	SUB.L	A5,D1		;LONGUEUR CHAINE
	CMP.L	#3,D1
	BLT	bug24

	MOVE.L	A5,D3
	SUB.L	rsoff(a2),D3	;OFFSET
	SUBQ.L	#OFFSETMIN,D3	; -2
	BLT	bug25
;
;	4->chaine+offset 8 bits de la chaine-1+1 byte(compteur-4)
;	5->chaine+offset 8 bits de la chaine-1+2 bytes(compteur-4)
;	6->chaine+offset 16 bits de la chaine-1+1 byte(compteur-5)
;	7->chaine+offset 16 bits de la chaine-1+2 bytes(compteur-5)
;	+8->chaine de longueur 3+offset 8 bits
;
	subq.l	#3,d1		;perte de 3 octets minimum
	bne.s	ch1
	cmp.l	#256,d3
	bhs.s	cmpch2		;si longueur 3->… suivre...
	moveq	#1,d1		;compression 8=1 octet de gagn‚
	bra.s	setch
ch1:
	cmp.l	#256+4-3,d1
	blo.s	jlx2
	subq.l	#1,d1		;perte de 1 octet si plus de 256 octets
jlx2:
	cmp.l	#256,d3
	blo.s	setch
	subq.l	#1,d1		;perte de 1 octet si offset 16 bits
setch:
	cmp.l	d7,d1
	blt.s	cmpch2
	bne.s	meil1
	cmp	#2*4,d6
	bne.s	cmpch2		;essaie de diminuer l'offset !!!
meil1:
;	tst.l	d3
;	bgt.s	.noerr
;	illegal
;.noerr

	move.l	d1,d7
	moveq	#2*4,d6
	move.l	A1,ptrfin	;nouveau pointeur de d‚but
	move.l	d3,d5		;m‚morise offset-1
;	subq.l	#1,d5
;	blo	bug1

	move.l	a1,d0
	sub.l	a5,d0
	cmp.l	offset(pc),d0	;d‚passe l'offset ???
	bhs	compstr		;oui->fini
	cmp.l	a6,a1
	bhs	compstr		;on atteint la fin ???
cmpch2:
	move.l	rsfils(a2),d0
	bne	loopsearch
finstr:
;
; 3) corr‚lation
;
;	0->pr‚fixe
;	1->premier caractŠre
;	2->diff‚rence constante
;	3->nb r‚p‚titions (8/16 bits)
;
; gain d'octets quand plus de 4 octets se suivent (>4)
;
	move.b	1(a5),d0
	sub.b	(a5),d0
	beq.s	pacorel		;si constante=0 -> r‚p‚tition
	lea	1(a5),a0
	move.b	(a0)+,d1
	add.b	d0,d1
	cmp.b	(a0)+,d1
	bne.s	pacorel
	add.b	d0,d1
	cmp.b	(a0)+,d1
	bne.s	pacorel
	add.b	d0,d1
	cmp.b	(a0)+,d1
	bne.s	pacorel

	cmp.l	a6,a0
	bhs.s	pacorel

	lea	256+4(a5),a1	;on ne recherche que dans les 256+5
	cmp.l	a6,a1		;premiers octets...
	bls.s	gaincor
	move.l	a6,a1
gaincor:
	cmp.l	a1,a0
	bhs.s	fincor
	add.b	d0,d1
	cmp.b	(a0)+,d1
	beq.s	gaincor
	subq	#1,a0
fincor:
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
	move.l	a0,d1
	sub.l	a5,d1
	subq.l	#4,d1		;4 octets perdus par entete
	cmp.l	d7,d1
	ble.s	pacorel
	move	d0,d5		;stocke diff‚rence
	move.l	d1,d7
	moveq	#3*4,d6
	move.l	a0,ptrfin
pacorel:
;
; d6=type de compression … effectuer
; d7=nb octets gagn‚s
; d5=offset pour compression de chaine
; d4=nb octets non compress‚s
;
	jmp	compress(pc,d6.w)

compress:
	bra.w	nocomp		;0
	bra.w	comprep		;1
	bra.w	compstr		;2
	bra.w	compcor		;3
;
; pas de compression … effectuer
; transfert pur et simple
;
;	0->pr‚fixe
;	1->compteur (8/16 bits)
;	2->octets...
;
; m‚moriser les limites du bloc non compressible
;  afin d'effectuer une topo dans une seconde passe
;
nocomp:
	tst	d4
	bne.s	incd4
	move.l	a5,ptrdeb
incd4:
	addq	#1,a5
	addq	#1,d4
	bne	boucle
	bra	bug2
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
comprep:
	bsr	fincomp
	move.l	a4,a3
	move.b	#1,(a4)+	;poke type=repeat normal+compteur

	move.l	ptrfin(pc),a2
	move.l	a2,d1
	sub.l	a5,d1
	cmp.l	#$10000+3-1,d1
	blo.s	compre1
	move.l	#$10000+3-1,d1
	move.l	a5,a2
	add.l	d1,a5		;on borne le compteur
compre1:
	moveq	#0,d0
	move.b	(a5),d0
	move.l	a2,a5

	subq.l	#3,d1		;compteur au minimum=3 !!!!
	blo	bug10

	cmp	lastrep(pc),d0
	bne.s	rep2
	cmp.l	#256,d1
	bhs.s	rep2
	addq.b	#2,(a3)		;repeat with lastrep+compteur
	move.b	d1,(a4)+	;poke compteur

	bsr	modify
	bra	boucle
rep2:
	move	d0,lastrep
	move.b	d0,(a4)+
	move	d1,d0
	lsr	#8,d0
	beq.s	compr1

	subq	#1,d0

	addq.b	#1,(a3)		;indique offset 16 bits
	move.b	d0,(a4)+
compr1:	move.b	d1,(a4)+	;poke repet

	bsr	modify
	bra	boucle
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
;	8->chaine de longueur 3+offset 8 bits
;
compstr:
	bsr	fincomp
	move.l	a4,a3

	move.l	ptrfin(pc),a2

	move.l	a2,d1
	sub.l	a5,d1		;calcule longueur chaine-3
	move.l	a2,a5

	cmp	#256,d5
	bhs.s	str1
	cmp.l	#3,d1
	beq.s	cmp3car
str1:
	move.b	#4,(a4)+	;poke type

	cmp	#256,d5
	blo.s	off8
	addq.b	#2,(a3)		;offset 16 bits de la chaine
	move	d5,d0
	lsr	#8,d0

	subq	#1,d0

	move.b	d0,(a4)+	;poke poids fort offset
off8:
	move.b	d5,(a4)+	;poke poids faible offset

	subq.l	#4,d1
	blo	bug11

	cmp	#256,d1
	blo.s	comps1
	addq.b	#1,(a3)		;longueur sur 16 bits
	move	d1,d0
	lsr	#8,d0

	subq	#1,d0

	move.b	d0,(a4)+
comps1:	move.b	d1,(a4)+	;poke compteur
	bsr	modify
	bra.s	boucle
cmp3car:
	move.b	#8,(a4)+	;poke type=chaine de longueur 3
	move.b	d5,(a4)+	;poke poids faible offset
	bsr	modify
	bra.s	boucle
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
compcor:
	bsr	fincomp
	move.l	a4,a3
	move.b	#9,(a4)+	;poke type

	move.l	ptrfin(pc),a2
	move.b	(a5),(a4)+	;1er octet
	move.b	d5,(a4)+	;poke diff‚rence
	move.l	a2,d1
	sub.l	a5,d1
	subq.l	#5,d1		;5 au moins
	blo	bug12
	move.b	d1,(a4)+	;poke compteur
	move.l	a2,a5
	bsr	modify
;	bra.s	boucle
;
; gestion des hashcodes
;
boucle:
	cmp.l	current_a5(pc),a5
	beq	bug26
	move.l	current_a5(pc),a0
	move.l	a5,current_a5
	move.l	a0,a5
SKIP_BYTE:
;
; GESTION HASH-CODE
;
	MOVE.L	A5,A0
	SUB.L	offset(PC),A0
	CMP.L	ptrdebut(pc),A0
	BLO.S	SKIPDEL
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	IFEQ	XOR
	MOVE.B	1(A0),D1
	EOR.B	D1,D0
	ENDC

	MOVE.L	A0,D1
;	SUBQ.L	#1,D1
;deletehash:
	asl	#3,d0
	lea	occur(pc),a0
	add	d0,a0
	move.l	(a0),d0
	beq	bug27
	move.l	d0,a1

	cmp.l	rsoff(a1),d1
	bne	bug28

	move.l	rsfils(a1),(a0)
	move.l	a1,a0
	move.l	ptrfree(pc),rsfils(a0)
	move.l	a0,ptrfree
	SUBQ.L	#1,NB
	bmi	bug30

SKIPDEL:
	MOVE.L	A5,D1
	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0

	IFEQ	XOR
	MOVE	D1,-(SP)
	MOVE.B	(A5),D1
	EOR.B	D1,D0
	MOVE	(SP)+,D1
	ENDC

;inserthash:
	asl	#3,d0
	lea	occur(pc),a0
	add	d0,a0
	move.l	(a0),d0
	beq.s	cree_pere

	ifeq	1
	move.l	4(a0),d3	;adresse dernier ‚l‚ment
	moveq	#0,d2
noeud_final:
	addq.l	#1,d2
	cmp.l	offset(pc),d2
	bhs	bug32
	move.l	d0,a1
	move.l	rsfils(a1),d0
	bne.s	noeud_final

	cmp.l	a1,d3
	bne	bug33
	endc

	move.l	4(a0),a1

	move.l	ptrfree(pc),rsfils(a1)
	move.l	ptrfree(pc),a1
	move.l	a1,4(a0)
	move.l	d1,rsoff(a1)
	move.l	rsfils(a1),ptrfree
	beq	bug29
	clr.l	rsfils(a1)
	bra.S	NEXTBYTE
cree_pere:
	move.l	ptrfree(pc),a1
	move.l	a1,(a0)
	move.l	a1,4(a0)
	move.l	d1,rsoff(a1)
	move.l	rsfils(a1),ptrfree
	clr.l	rsfils(a1)

NEXTBYTE
	ADDQ.l	#1,NB
	move.l	NB(PC),d0
	cmp.l	offset(pc),d0
	bhi	bug30

	cmp.l	current_a5(pc),a5
	blo	SKIP_BYTE
	bra	_boucle
;
fini:
;
; indique premiŠre passe finie
;
	bsr	fincomp

	PRINT	mess2

	lea	freq(pc),a0
	moveq	#nbmeth-1,d0
	moveq	#0,d2
tstmeth:
	tst	(a0)+
	beq.s	pan
	addq	#1,d2
pan:
	dbra	d0,tstmeth

	tst	d2
	beq	bug13		;si pas de compression, bug !!!
;
; ici d2=nb m‚thodes de compressions utilis‚es-1
;
	lea	best(pc),a2
	moveq	#0,d3
calfre:
	lea	freq2(pc),a0
	moveq	#-1,d0
	move	#256-1,d1
;
; recherche les d2 octets les moins utilis‚s...
;
min:
	cmp	(a0)+,d0
	bls.s	pamin
	lea	-2(a0),a1
	move	(a1),d0
pamin:
	dbra	d1,min

	move.l	a1,d1
	sub.l	#freq2,d1
	lsr	#1,d1
	move	d1,(a2)+	;poke valeur octet
	move	d0,(a2)+	;poke fr‚quence
	add	d0,d3
	move	#-1,(a1)	;fr‚quence=maximum
	dbra	d2,calfre

	tst	d3
	bne.s	nometh
	moveq	#1,d3
nometh:
	move	d3,freq		;indique nb octets perdus
;
; on assigne … chaque code de compression, un code peu r‚pandu
;   dans le fichier final
;
; a2 pointe sur la fin de best...
;
trions:
	lea	freq(pc),a0	;recherche des codes les plus utilis‚s
	moveq	#nbmeth-1,d1
	moveq	#0,d0
max:
	cmp	(a0)+,d0
	bhs.s	pamax
	lea	-2(a0),a1
	move	(a1),d0
pamax:
	dbra	d1,max

	tst	d0
	beq	bug14

	clr	(a1)		;efface la fr‚quence

	subq	#2,a2
	move	-(a2),d0	;on prend le dernier code empil‚
	move.l	a1,d1
	sub.l	#freq,d1
	lea	codes(pc),a0
	add.l	d1,a0
	move	d0,(a0)		;on remplit la table correspondante
	cmp.l	#best,a2
	bne.s	trions
;
	move.l	a4,finsegm

	ifeq	overlay
	move.l	ptrdebut(pc),a4
	endc
	move.l	a4,ptrfinal
;
; maintenant, on va d‚compresser le fichier afin de g‚n‚rer
;  le fichier final
;
	move.l	ptrfinal(pc),a6
	lea	codes(pc),a0	;on poke d'abord les octets de m‚thodes
	moveq	#nbmeth-1,d0
pokecode:
	move	(a0)+,d1
	bmi.s	setcode		;si m‚thode inutilis‚e,
	move	d1,d2		; on poke l'ancien code
setcode:
	move.b	d2,(a6)+
	dbra	d0,pokecode

	PRINT	mess3

	move.l	ptrfinal(pc),a3
	move.l	ptrsegm(pc),a0	;pointeur sur le segment data
traduit:
	ifeq	overlay
	cmp.l	a6,a0		;final vient de scratcher segm ????
	blo	bug15
	endc

	cmp.l	finsegm(pc),a0
	bhs	sure

	moveq	#0,d0
	move.b	(a0)+,d0
	cmp	#12,d0
	bhs	bug16
	add	d0,d0
	add	d0,d0
	jmp	methon(pc,d0.w)
methon:
	bra.w	meth0
	bra.w	meth1
	bra.w	meth2
	bra.w	meth3
	bra.w	meth4
	bra.w	meth5
	bra.w	meth6
	bra.w	meth7
	bra.w	meth8
	bra.w	meth9
	bra.w	meth10
	bra.w	meth11
;
;	0->pas de compression+2 bytes (compteur-1)
;
meth0:
	move.b	(a0)+,d0
	asl	#8,d0
	move.b	(a0)+,d0
meth00:
	moveq	#0,d1
	move.b	(a0)+,d1
	lea	codes(pc),a2
	moveq	#nbmeth-1,d2
cmpcode:
	cmp	(a2)+,d1
	dbeq	d2,cmpcode
	bne.s	nxtcode
	move.b	(a3),(a6)+	;final+0
nxtcode:
	move.b	d1,(a6)+
	dbra	d0,meth00
	bra.s	traduit
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
meth1:
	move.b	1(a3),(a6)+	;code de rept=final+1
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra.s	traduit
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
meth2:
	move.b	2(a3),(a6)+	;code de rept=final+2
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
meth3:
	move.b	3(a3),(a6)+	;code de rept=final+3
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
meth4:
	move.b	4(a3),(a6)+	;=final+4
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
meth5:
	move.b	5(a3),(a6)+	;=final+5
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
meth6:
	move.b	6(a3),(a6)+	;=final+6
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
meth7:
	move.b	7(a3),(a6)+	;=final+7
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	8->chaine de longueur 3+offset 8 bits
meth8:
	move.b	8(a3),(a6)+	;=final+8
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
meth9:
	move.b	9(a3),(a6)+	;=final+9
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
meth10:
	move.b	10(a3),(a6)+	;=final+10
	move.b	(a0)+,(a6)+	;1er octet
	move.b	(a0)+,d0	;mask
	move.b	d0,(a6)+
	moveq	#8-1,d1
msk1:
	add.b	d0,d0
	bcc.s	nomsk1
	move.b	(a0)+,(a6)+
nomsk1:
	dbra	d1,msk1
	bra	traduit
;
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
meth11:
	move.b	11(a3),(a6)+	;=final+11
	move.b	(a0)+,d0	;mask
	move.b	d0,(a6)+
	moveq	#8-1,d1
msk2:
	add.b	d0,d0
	bcc.s	nomsk2
	move.b	(a0)+,(a6)+
nomsk2:
	dbra	d1,msk2

	bra	traduit

sure:
	cmp.l	finsegm(pc),a0
	bne	bug17
***********************************
*
*  FIN DU PACKER EN BYTES
*
***********************************
	move.l	a6,ptrfin2

	move.l	ptrfinal(pc),ptrdebut
	move.l	ptrfin2(pc),ptrfin1
;
; inverse les premiers octets (m‚thodes de compression)
;
	move.l	ptrdebut(pc),a0
	lea	nbmeth(a0),a1
inv1:
	move.b	-(a1),d0
	move.b	(a0),(a1)
	move.b	d0,(a0)+
	cmp.l	a1,a0
	blo.s	inv1

	rts
fincomp:
	tst	d4
	beq	nomore
;
; quand on a un bloc non compress‚, on lui fait une topographie...
;
	movem.l	d5-d7/a5/a6,-(sp)

	move.l	a5,a6			;nouvelle fin
	move.l	ptrdeb(pc),a5		;nouveau d‚but

	moveq	#0,d4
boucle2:
;	bsr	hexa
	cmp.l	a6,a5
	bhs	fini2

	ifne	TOPO8
;
; 4) topographie 9 bits
;
;	0->pr‚fixe
;	1->octet le plus fr‚quent=premier octet
;	2->configuration binaire (masque)
;	3->octets moins fr‚quents...
;
; gain d'octets si le premier octet se r‚pŠte au moins
;   3 fois (>=4)
;
	lea	9(a5),a0
	cmp.l	a6,a0
	bhs	patopo

	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#-gaintop,d1	;entete prend 3 octets
	cmp	lasttopo(pc),d0
	bne.s	pat0
	addq.l	#1,d1		;gain d'1 octet si lasttopo
pat0:
	cmp.b	(a0)+,d0	;2Šme octet
	bne.s	pat1
	addq.l	#1,d1
pat1:
	cmp.b	(a0)+,d0	;3Šme octet
	bne.s	pat2
	addq.l	#1,d1
pat2:
	cmp.b	(a0)+,d0	;4Šme octet
	bne.s	pat3
	addq.l	#1,d1
pat3:
	cmp.b	(a0)+,d0	;5Šme octet
	bne.s	pat4
	addq.l	#1,d1
pat4:
	cmp.b	(a0)+,d0	;6Šme octet
	bne.s	pat5
	addq.l	#1,d1
pat5:
	cmp.b	(a0)+,d0	;7Šme octet
	bne.s	pat6
	addq.l	#1,d1
pat6:
	cmp.b	(a0)+,d0	;8Šme octet
	bne.s	pat7
	addq.l	#1,d1
pat7:
	cmp.b	(a0)+,d0	;9Šme octet
	bne.s	pat8
	addq.l	#1,d1
pat8:
	tst.l	d1
	ble.s	patopo
	bsr	fincomp2
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
	move.l	a4,a3
	move.b	#11,(a4)+	;poke type=topo with lasttopo
	moveq	#0,d5
	move.b	(a5)+,d5
	cmp	lasttopo(pc),d5
	beq.s	top121
	move	d5,lasttopo
	subq.b	#1,(a3)
	move.b	d5,(a4)+	;premier octet=new topo
top121:
	move.l	a4,a2
	addq	#1,a4
	moveq	#8-1,d2
top131:
	add.b	d0,d0
	move.b	(a5)+,d1
	cmp.b	d5,d1
	beq.s	top141
	addq.b	#1,d0
	move.b	d1,(a4)+	;poke les octets
top141:
	dbra	d2,top131

	move.b	d0,(a2)		;poke le masque
	bsr	modify
	bra	boucle2

	elseif
;
; 4) topographie 8 bits
;
;	0->pr‚fixe
;	1->octet le plus fr‚quent=premier octet
;	2->configuration binaire (masque)
;	3->octets moins fr‚quents...
;
; gain d'octets si le premier octet se r‚pŠte au moins
;   3 fois (>=4)
;
	lea	8(a5),a0
	cmp.l	a6,a0
	bhs	patopo
;
; seul bug :
;	2 octets se r‚pŠtent 4 fois chacun
;
	lea	freqtopo(pc),a1
	move.l	a5,a0

	moveq	#0,d0
	move.b	(a0)+,d0	;0
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;1
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;2
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;3
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;4
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;5
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;6
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;7
	addq.b	#1,(a1,d0.w)
	subq	#8,a0

	moveq	#0,d1
	moveq	#0,d6
	move.b	(a0)+,d1
	move.b	(a1,d1.w),d6
	clr.b	(a1,d1.w)

	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not2
	move	d0,d1
	move.b	(a1,d0.w),d6
not2:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not3
	move	d0,d1
	move.b	(a1,d0.w),d6
not3:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not4
	move	d0,d1
	move.b	(a1,d0.w),d6
not4:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not5
	move	d0,d1
	move.b	(a1,d0.w),d6
not5:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not6
	move	d0,d1
	move.b	(a1,d0.w),d6
not6:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
; les 2 tests suivants sont inutiles !!!
;	cmp.b	(a1,d0.w),d6
;	bhs.s	not7
;	move	d0,d1
;	move.b	(a1,d0.w),d6
;not7:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
;	cmp.b	(a1,d0.w),d6
;	bhs.s	not8
;	move	d0,d1
;	move.b	(a1,d0.w),d6
;not8:
	clr.b	(a1,d0.w)
;
; d6=nb octets gagn‚s
; d1=octet de topo
;
	cmp	lasttopo(pc),d1
	bne.s	topo1
	addq	#1,d6		;on gagne un octet de plus
topo1:
	subq	#gaintop,d6
	bls.s	patopo		;d6=nb octets gagn‚s
	move	d1,-(sp)
	bsr.s	fincomp2
	move	(sp)+,d1	;d1=octet topo
;
;	10->topo 8 bits+octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
	move.l	a4,a3
	move.b	#11,(a4)+	;poke type=topo with lasttopo
	cmp	lasttopo(pc),d1
	beq.s	top12
	move	d1,lasttopo
	subq.b	#1,(a3)
	move.b	d1,(a4)+
top12:
	move.l	a4,a2
	addq	#1,a4
	moveq	#8-1,d2
top13:
	add.b	d0,d0
	move.b	(a5)+,d3
	cmp.b	d1,d3
	beq.s	top14
	addq.b	#1,d0
	move.b	d3,(a4)+	;poke les octets
top14:
	dbra	d2,top13

	move.b	d0,(a2)		;poke le masque

	bsr	modify
	bra	boucle2

	endc

patopo:
	tst	d4
	bne.s	incd5
	move.l	a5,ptrdeb
incd5:
	addq	#1,a5
	addq	#1,d4
	bne	boucle2
	bra	bug3

fini2:
	bsr.s	fincomp2
	movem.l	(sp)+,d5-d7/a5/a6

	moveq	#0,d4
nomore:
	rts
;
; GESTION HASH-CODE 10/05/91
;
; entr‚e :
;	d0=octet hash-code
;	d1=offset octet courant
;
; STRUCTURE DE LA TABLE DE HASHAGE :
;	0.L=OFFSET
;	4.L=PTR FILS
;
init_hash:
	CLR.L	NB
	move.l	ptr_buffer_hash(pc),a0
	move.l	offset(pc),d0
	subq.l	#1,d0
;	move	#lenoffset+1-1-1,d0
	CMP	#-1,D0
	beq.s	nobuf
inithash2:
	addq	#8,a0
	move.l	a0,rsfils-8(a0)
	dbra	d0,inithash2
nobuf:
	clr.l	rsfils(a0)
	move.l	ptr_buffer_hash(pc),ptrfree
	lea	occur(pc),a0
	move	#256-1,d0
inithash3:
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,inithash3
nooff:	rts

;
; indique pas de compression
;
; d4=nb octets non compress‚s
;
fincomp2:
	tst	d4
	beq.s	fin3

	move.l	a4,a3
	clr.b	(a4)+
	subq	#1,d4
	move	d4,d0
	lsr	#8,d0
	move.b	d0,(a4)+
	move.b	d4,(a4)+

	move.l	ptrdeb(pc),a0

	lea	freq2(pc),a1
copy2:
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	d0,(a4)+
	add	d0,d0
	addq	#1,(a1,d0.w)
	beq.s	copyzero1	;09/04/90 correction bug possible
copyzero2:
	dbra	d4,copy2
	cmp.l	a5,a0
	bne	bug18
	moveq	#0,d4
fin3:	rts
copyzero1:
	subq	#1,(a1,d0.w)
	bra.s	copyzero2

hexa:
	cmp.l	lasthex(pc),a5
	blo.s	rethex
	move.l	a5,lasthex
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	ptrfin1(pc),d7
	sub.l	lasthex(pc),d7		;nb octets restants
	bsr.s	aff_hexa

	move	#13,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp

	movem.l	(sp)+,d0-d7/a0-a6
	add.l	#256,lasthex
rethex:	rts

aff_mixte:
	moveq	#'$',d0
	bsr.s	put2
	bsr.s	aff_hexa
	moveq	#' ',d0
	bsr.s	put2
	bra.s	decimal

aff_hexa:
	rol.l	#8,d7
	bsr.s	hexa2
	bsr.s	hexa2
	bsr.s	hexa2
	bsr.s	hexa2
	bsr.w	hexa2
hexa2:
	rol.l	#4,d7
	moveq	#$f,d0
	and	d7,d0
	add	#$30,d0
	cmp	#$3a,d0
	blo.s	put2
	addq	#7,d0
put2:
	move	d0,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	rts

modify:
	moveq	#0,d0
	move.b	(a3),d0
	lea	freq(pc),a3
	add	d0,d0
	addq	#1,(a3,d0.w)
	beq.s	copyzero3	;09/04/90
	rts
copyzero3:
	subq	#1,(a3,d0.w)
	rts
get_time:
	pea	supexec(pc)
	move	#38,-(sp)
	trap	#14
	addq	#6,sp
	rts
supexec:
	move.l	$4ba.w,d7
	move.l	d7,d0
	add.l	d7,d7
	add.l	d7,d7
	add.l	d0,d7
	MOVE.L	d7,time
	rts
;
; conversion/affichage d'un nombre d‚cimal
;
; entr‚e :
;	d7.L=nb … afficher
;
decimal:
	moveq	#' ',d6
	move.l	#1000000000,d5
	bsr.s	decime
	move.l	#100000000,d5
	bsr.s	decime
	move.l	#10000000,d5
	bsr.s	decime
	move.l	#1000000,d5
	bsr.s	decime
	move.l	#100000,d5
	bsr.s	decime
	move.l	#10000,d5
	bsr.s	decime
	move.l	#1000,d5
	bsr.s	decime
	moveq.l	#100,d5
	bsr.s	decime
	moveq.l	#10,d5
	bsr.s	decime

	moveq	#'0',d0
	add	d7,d0
	bra	put2

decime:
	moveq	#-1,d0
deci1:
	addq	#1,d0
	sub.l	d5,d7
	bhs.s	deci1
	add.l	d5,d7
	tst	d0
	beq.s	ok0xxx
	moveq	#'0',d6
ok0xxx:
	add	d6,d0
	bra	put2

;
; d6=nb octets gagn‚s
; d7=nb octets d'origine
;
percent:
	moveq	#' ',d5
	tst.l	d6
	bpl.s	nogain
	neg.l	d6
	moveq	#'-',d0
	bsr	put2
	moveq	#'0',d5
nogain:
	bsr.s	decim4
	moveq	#'0',d5
	bsr.s	decim4
	moveq	#'.',d0
	bsr	put2
	bsr.s	decim4
	bsr.s	decim4
	rts
decim4:
	move.l	d6,d0
	add.l	d6,d6
	add.l	d6,d6
	add.l	d0,d6
	add.l	d6,d6		;d6=d6*10
	moveq	#-1,d0
decim41:
	addq	#1,d0
	sub.l	d7,d6
	bhs.s	decim41
	add.l	d7,d6

	tst	d0
	beq.s	decim42
	moveq	#'0',d5
decim42:
	add	d5,d0
	bra	put2

input:
	pea	chaine(pc)
	move	#$a,-(sp)
	trap	#1
	addq	#6,sp
	bsr	cr

	lea	chaine+2(pc),a0
	clr	d0
	move.b	-1(a0),d0
	clr.b	(a0,d0.w)
	rts
get_hexa
	tst.b	(a0)
	beq.s	.rts
	moveq	#0,d7
.get	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	.rts
	cmp.b	#$40,d0
	blo.s	.maj
	and	#$df,d0
.maj
	sub.b	#'0',d0
	cmp.b	#10,d0
	blo.s	.hex
	add.b	#$fa-('A'-'0'),d0
	cmp.b	#$fa,d0
	blo.s	.rts
	and	#$f,d0
.hex
	asl.l	#4,d7
	add.l	d0,d7
	bra.s	.get
.rts	rts

bug1	moveq	#1,d0
	bra.s	exit		;1=erreur interne dans algo chaine
bug2	moveq	#2,d0		;2=64K sans compression, faut pas pousser
	bra.s	exit
bug3	moveq	#3,d0		;64K sans compression, faut pas pousser
	bra.s	exit
bug4	moveq	#4,d0			;file not found
	bra.s	exit
bug5	moveq	#5,d0		;file not found 2
	bra.s	exit
bug6	moveq	#6,d0		;erreur load 2
	bra.s	exit
bug7	moveq	#7,d0
	bra.s	exit
bug8	moveq	#8,d0		;erreur write
	bra.s	exit
bug10	moveq	#10,d0
	bra.s	exit
bug11	moveq	#11,d0
	bra.s	exit
bug12	moveq	#12,d0
	bra.s	exit
bug13	moveq	#13,d0
	bra.s	exit
bug14	moveq	#14,d0
	bra.s	exit
bug15	moveq	#15,d0
	bra.s	exit
bug16	moveq	#16,d0
	bra.s	exit
bug17	moveq	#17,d0
	bra.s	exit
bug18	moveq	#18,d0
	bra.s	exit
bug19	moveq	#19,d0		;erreur load 1
	bra.s	exit
bug20	moveq	#20,d0
	bra.s	exit
bug21	moveq	#21,d0
	bra.s	exit
bug22	moveq	#22,d0
	bra.s	exit
bug23	moveq	#23,d0
	bra.s	exit
bug24	moveq	#24,d0
	bra.s	exit
bug25	moveq	#25,d0
	bra.s	exit
bug26	moveq	#26,d0
	bra.s	exit
bug27	moveq	#27,d0
	bra.s	exit
bug28	moveq	#28,d0
	bra.s	exit
bug29	moveq	#29,d0
	bra.s	exit
bug30	moveq	#30,d0
	bra.s	exit
bug31	moveq	#31,d0		;out of memory
	bra.s	exit
bug32	moveq	#32,d0		;boucle infinie !!!
	bra.s	exit
bug33	moveq	#33,d0

exit:	move.l	d0,d7

	PRINT	internal

	cmp	#10,d7
	blo.s	inf101
	moveq	#'0',d0
.sub10
	addq	#1,d0
	sub	#10,d7
	cmp	#10,d7
	bhs.s	.sub10
	bsr	put2
inf101:
	moveq	#'0',d0
	add	d7,d0
	bsr	put2
	bsr	cr
paesc:
	PRINT	plantade
1$	move	#7,-(sp)
	trap	#1
	addq	#2,sp
	cmp	#27,d0
	bne.s	1$
	clr	-(sp)
	trap	#1
;
; impl‚mentation ultime du codage de Huffmann
;  finie le 02/09/89
;  revu le 17/09/89 (‡a va 2 fois plus vite maintenant !!!)
;
; am‚liorations :
;	+ travailler d5 en .W
;	- afficher : Longueur originale :
;			Longueur finale :
;
; m‚thode g‚niale
;
; compression du type Huffmann avec :
;  - codes Huffmann jusqu'… 31 bits
;  - sauvegarde optimale de l'arbre au d‚but du code
;  - compression des bytes
;  - attention un bit … 1 est sauv‚ … la fin du fichier
;  - le code de fin de fichier est r‚serv‚ au dernier noeud
;      de l'arbre pour faciliter le test de d‚compression
;
; astuces :
;	- mettre la carry … 1 : MOVE #$11,CCR
;	    mieux :	TAS Dn NEG.B Dn
;
; codage de Huffmann
;
huffmann:
	lea	frequences(pc),a0
	move	#257-1,d0
clfg:	clr.l	(a0)+
	dbra	d0,clfg

	move.l	ptrfin1(pc),d7
	sub.l	ptrdebut(pc),d7
	move.l	d7,const2

	move.l	ptrdebut(pc),a5
	addq.l	#1,d7
	bclr	#0,d7
	add.l	d7,a5
	move.l	a5,const4

	PRINT	mess21

	move.l	ptrdebut(pc),a0
	move.l	const2(pc),d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
	lea	frequences(pc),a1
byte1:
	moveq	#0,d3
	move.b	(a0)+,d3
	add	d3,d3
	add	d3,d3
	addq.l	#1,(a1,d3.w)
	dbra	d0,byte1
	dbra	d1,byte1
;
; pour une compression de bytes, le code de fin de fichier
;   est le dernier
;
	addq.l	#1,256*4+frequences

	PRINT	mess22
;
; deuxiŠme partie :
;
; tri par insertion des fr‚quences dans l'ordre croissant
;
	move.l	const4(pc),a1
	lea	frequences(pc),a3
	lea	256*4(a3),a6
;
; on fait en sorte que le code de fin du fichier soit le premier d‚gag‚
;
;	lea	256*4(a3),a2
	move.l	a6,a2
suivant:
	move.l	(a2),(a1)+	;fr‚quence
	clr.l	(a1)+		;indique noeud terminal
	clr.l	(a2)

	move.l	a2,d0
	sub.l	#frequences,d0
	lsr.l	#2,d0
	move.l	d0,(a1)+	;valeur du noeud terminal

sear2:	move.l	(a3)+,d7
	bne.s	fnd2
	cmp.l	a6,a3
	blo.s	sear2
	bra.s	finse
fnd2:	move.l	a3,a4
	subq	#4,a3
fnd1:	lea	-4(a4),a2
searc1:	cmp.l	a6,a4
	bhs.s	suivant
	move.l	(a4)+,d0
	beq.s	searc1
	cmp.l	d0,d7
	bls.s	searc1
	move.l	d0,d7
	bra.s	fnd1
finse:
	move.l	a1,const5

	PRINT	mess23
;
; fin de l'arbre=const5
;
	move.l	const4(pc),a5
	move.l	const5(pc),a6
code1:	tst.l	(a5)
	bne.s	pasaut
	lea	12(a5),a5
	bra.s	code1
pasaut:	move.l	a5,a4
	sub.l	a2,a2
	move.l	a2,a3
code2:	move.l	(a4),d1
	bne.s	tester
contin:	lea	12(a4),a4
	cmp.l	a6,a4
	blo.s	code2
	move.l	a3,d0
	beq.s	fincod		;ici a2=racine

	move.l	(a3),d0
	add.l	(a2),d0
	move.l	d0,(a6)+	;cr‚e un nouveau noeud
	move.l	a2,(a6)+
	move.l	a3,(a6)+
	clr.l	(a2)
	clr.l	(a3)
	bra.s	code1
;
; a2 et a3 pointent sur les deux plus petites fr‚quences
; a2 pointe sur la plus petite des 2
; d6=(a2)
; d7=(a3)
; d6<=d7
tester:
	move.l	a2,d0
	bne.s	code3
	move.l	a4,a2		;positionne ptr gauche
	move.l	d1,d6
	bra.s	contin
code3:	move.l	a3,d0
	beq.s	code4
	cmp.l	d7,d1
	bhs.s	contin		;si > valeur la plus grande, on continue
code4:	move.l	a4,a3		;positionne ptr droit
	move.l	d1,d7
	cmp.l	d7,d6
	bls.s	contin
	exg	d7,d6
	exg	a2,a3
	bra.s	contin
fincod:
	move.l	a6,const6
;
; ici a2 pointe sur la racine
;
	move.l	a2,racine

	PRINT	mess24

	move.l	racine(pc),a6
	moveq	#1,d5		;d‚calage
	move.l	const6(pc),a3	;adresse codage datas

	moveq	#1,d6		;code Huffmann (avec MSB=1 pour compter
	bsr	huffing		;les bits)

	PRINT	mess25
;
; pr‚calcule les codes de Huffmann
;
	move.l	const4(pc),a5	;a5 pointe sur d‚but arbre
	move.l	const5(pc),a6	;a6 pointe sur fin arbre
	lea	frequences(pc),a0
retri:
	move.l	(a5)+,d0	;code de Huffmann
	tst.l	(a5)+
	bne	bug20
	move.l	(a5)+,d3
;
; ici d3=code de 0 … 256 inclus (256=fin de fichier)
;
	add	d3,d3
	add	d3,d3
	move.l	d0,(a0,d3.w)	;transfŠre Huffmann code

	cmp.l	a6,a5
	blo.s	retri

	PRINT	mess26

	move.l	ptrdebut(pc),a0
	move.l	const2(pc),d0	;nb octets
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
	lea	frequences(pc),a1
	moveq	#0,d2		;optimisation
byte2:
;
; ici d2=0 !!!
;
	move.b	(a0)+,d2
	add	d2,d2
	add	d2,d2
	move.l	(a1,d2.w),d2	;get Huffmann code

	add.l	d2,d2
	addx	d5,d5
	bcc.s	.bit0
	move	d5,(a3)+
	moveq	#1,d5
.bit0

SHIFT	MACRO
	add.l	d2,d2
	beq.s	.findec
	addx	d5,d5
	bcc.s	.\@
	move	d5,(a3)+
	moveq	#1,d5
.\@
	ENDM

	REPT	9
	SHIFT
	ENDR

	add.l	d2,d2
	beq.s	.findec
.cont
	addx	d5,d5
	bcc.s	.bit1
	move	d5,(a3)+
	moveq	#1,d5
.bit1
	add.l	d2,d2
	bne.s	.cont
.findec

;	add.l	d2,d2
;decale:
;	addx	d5,d5
;	bcc.s	bit2
;	move	d5,(a3)+
;	moveq	#1,d5
;bit2:
;	add.l	d2,d2
;	bne.s	decale

	dbra	d0,byte2
	dbra	d1,byte2

	move.l	256*4+frequences(pc),d0		;code de fin de fichier
	add.l	d0,d0
decale2:addx	d5,d5
	bcc.s	bit22
	move	d5,(a3)+
	moveq	#1,d5
bit22:
	add.l	d0,d0
	bne.s	decale2
shift:
	tas	d0
	neg.b	d0
;	move	#$11,ccr
shift0:
	addx	d5,d5
	bcc.s	shift0

	tst	d5
	beq.s	gain2
	move	d5,(a3)+	;pattern+bit 1 pour finir fichier
gain2:
	move.l	const6(pc),a0
	move.l	a3,a1
;	move.l	a3,d0
;	sub.l	a0,d0
;
; fin :
;
;	a0=adresse de d‚but du fichier
;	a1=adresse de fin du fichier
;	d0=nb octets du fichier
;
	move.l	a0,ptrdebut
	move.l	a1,ptrfin1
	rts

hufg2:
	pea	(a6)
	move.l	d0,a6
	bsr.s	hufg
	move.l	(sp)+,a6
	move.l	8(a6),a6
hufg:
	tst	d1
	bne.s	okhug
	move.l	4(a6),d0
	bne.s	hufg2
	move.l	8(a6),d0
	cmp.l	#256,d0		;code de fin>256 !!!
	blo.s	okhug
	moveq	#-1,d1		;merde, on l'a trouv‚
okhug:	rts

huffing:
	move.l	4(a6),d0
	beq.s	termin		;noeud terminal ???

	add	d5,d5
	bcc.s	bit0
	move	d5,(a3)+
	moveq	#1,d5
bit0:
	pea	(a6)		;non
	move.l	d0,a6
	add.l	d6,d6
	bcs	bug21		;bugge si plus de 31 bits !!!
;
; pour am‚liorer le d‚compacteur de Huffmann, une bidouille :
;
;	pour faire en sorte que le code de fin de fichier
;	 soit le dernier code explor‚ dans l'arbre,
;	j'effectue une recherche pour v‚rifier si on emprunte
;	 sa branche
;	si on le voit, on l'‚vite
;
	moveq	#0,d1		;indique si on l'a trouv‚
	bsr.s	hufg
	move.l	(sp),a6
	move.l	4(a6),a6
	tst	d1
	beq.s	paevite		;on l'a pas trouv‚ -> on continue

	move.l	(sp),a6
	move.l	8(a6),a6
	bsr.s	huffing
	move.l	(sp)+,a6
	addq.b	#1,d6
	move.l	4(a6),a6
	bsr.s	huffing		;on emprunte le chemin de la fin...
	lsr.l	#1,d6
	rts

paevite:
	bsr.s	huffing
	move.l	(sp)+,a6
	addq.b	#1,d6
	move.l	8(a6),a6
	bsr.s	huffing
	lsr.l	#1,d6
	rts
termin:
	add	d5,d5
	bcc.s	bit1
	addq	#1,d5
	move	d5,(a3)+
	moveq	#0,d5
bit1:
	addq	#1,d5

	move.l	8(a6),d0
	moveq	#7,d1
bit4:	add.b	d0,d0
	addx	d5,d5
	bcc.s	bit5
	move	d5,(a3)+
	moveq	#1,d5
bit5:	dbra	d1,bit4

	tas	d0
	neg.b	d0
	move.l	d6,d0
;	move	#$11,ccr
bitsev:
	addx.l	d0,d0
	bcc.s	bitsev
	move.l	d0,(a6)		;pattern justifi‚ … gauche+bit 1 … droite
	rts
cr:
	PRINT	cr2
	rts
;
; nouveau d‚packers optimis‚s avec relogeur
;
; 10/04/90
; 10/05/91 r‚vision+cleanage relogeur...
;
; D5,A6 inutilis‚s dans le d‚packer !!!
;
ajuste = 12		;12 pour Ivanho‚

WAITDMA	MACRO
;.\@	CMP.L	ADRESSE_DERNIER_OCTET_CHARGE,A0	;ATTENTE DMA DISK
;	BHS.S	.\@
	MOVE	(A0)+,D2
;	MOVE	D2,$FFFF8240.W			;plus beau
	ADDX	D2,D2
	ENDM
RDBYTE	macro
	move.l	a2,a5
	move	d1,d0
.\@1	add	d2,d2
	bne.s	.\@2
	WAITDMA
.\@2	bcc.s	.\@3
	add	d0,a5
.\@3	move	(a5)+,d0
	bpl.s	.\@1
	endm

LITTLE_PLACE=$50

;
; DECRUNCHER MIXTE (HUFFMANN+PACK)
;
DECRUNCH0:
	DC.W	$601A
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	-1		;PAS DE RELOCATION
.base_page:
;
; on recopie le fichier pack‚ … la fin du fichier d‚pack‚
;
	move.l	.length(pc),d0
	lea	.pack(pc),a0
	add.l	d0,a0			;ptr source
	move.l	a0,a3

	lea	.pack+ajuste(pc),a1
	add.l	.longueur(pc),a1	;ptr dest
	move.l	a1,a2
	move.l	a2,a0
	sub.l	d0,a0

	addq.l	#7,d0
	lsr.l	#3,d0
.move_it:
	move.l	-(a3),-(a1)
	move.l	-(a3),-(a1)
	dbra	d0,.move_it

;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)

	lea	.pack(pc),a1

	bsr	.decomp

	lea	.base_page-$100(pc),a2
	lea	.pack(PC),A3
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	add.l	$e(a3),a0		;SKIPPE LABELS !!!!
	LEA	$1C(A3),A1
	add.l	a1,a0

	MOVE.L	(A0)+,D0
	BEQ.S	.NORELOC
	ADD.L	D0,A1
	MOVE.L	8(a2),D0
	MOVEQ	#0,D1
.RELOC1	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.RELOC2
	LEA	$FE-1(A1),A1
	BRA.S	.RELOC3
.RELOC2	ADD.L	D0,(A1)
.RELOC3	MOVE.B	(A0)+,D1
	BNE.S	.RELOC1
.NORELOC
	MOVE.L	2(A3),d0
	MOVE.L	d0,$C(a2)
	MOVE.L	6(A3),$14(a2)
	MOVE.L	$A(A3),$1C(a2)
	ADD.L	8(a2),d0
	MOVE.L	d0,$10(a2)
	ADD.L	$14(a2),d0
	MOVE.L	d0,$18(a2)
	move.l	d0,a5

	movem.l	.MOVER(pc),d0-d3
	movem.l	d0-d3,LITTLE_PLACE(a2)	;on claque le d‚placeur
					;dans la Basepage !!!
	LEA	$1C(A3),A0
	MOVE.L	.longueur(PC),D2
	lea	.pack+ajuste+1026+256(pc),a3
	add.l	d2,a3

	ADDQ.L	#3,D2
	LSR.L	#2,D2
	lea	.base_page(pc),a1
	MOVEQ	#0,D0
	jmp	LITTLE_PLACE(a2)

.MOVER	MOVE.L	(A0)+,(A1)+	;16 octets
	SUBQ.L	#1,D2
	BNE.S	.MOVER
.CLEARER
	MOVE.L	D0,(A5)+
	CMP.L	A3,A5
	BLO.S	.CLEARER
	BRA	.MOVER+256-LITTLE_PLACE
.decomp
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR	.DECODE0
	MOVE	(a2)+,D1
	moveq	#0,d4
	move.l	a3,a4
	moveq	#256/4-1,d0
.clear:	move.l	d4,(a4)+
	dbra	d0,.clear
	lea	.codes2(pc),a4
	moveq	#nbmeth-1,d3
.copy:
	bsr	.byte
	move.b	d0,d4
	move.b	(a4)+,(a3,d4.w)
	dbra	d3,.copy
	bra.s	.traduit
.sure:
	rts
.base:
	move.b	d0,(a1)+
.traduit:
	RDBYTE

	cmp.l	a3,a5
	bhs.s	.sure
	move.b	d0,d4
	move.b	(a3,d4.w),d4
	jmp	.base(pc,d4.w)
.meth0:
	bsr	.byte
	bra.s	.base
.meth1:
	bsr	.byte
	move.b	d0,d6
.meth3:
	moveq	#0,d3
.meth2xx:
	bsr	.byte
	move.b	d0,d3
	move.b	d6,(a1)+
	move.b	d6,(a1)+
.meth2x:
	move.b	d6,(a1)+
	dbra	d3,.meth2x
	bra.s	.traduit
.meth2:
	bsr	.byte
	move.b	d0,d6

	bsr	.byte8
	bra.s	.meth2xx
.meth4:
	moveq	#0,d3
.cnt8:
	bsr	.byte
	move.b	d0,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4
	moveq	#0,d3
.copy4:
	bsr	.byte
	move.b	d0,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.meth4x:move.b	(a4)+,(a1)+
	dbra	d3,.meth4x
	bra.S	.traduit
.meth5:
	moveq	#0,d3
.cnt16:
	bsr.s	.byte
	move.b	d0,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4
	bsr.s	.byte8
	bra.s	.copy4
.meth6:
	bsr.s	.byte8
	bra.s	.cnt8
.meth7:
	bsr.s	.byte8
	bra.s	.cnt16
.meth8:
	bsr.s	.byte
	and	#$ff,d0
	neg	d0
	lea	-OFFSETMIN(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra	.traduit
.meth9:
	bsr.s	.byte
	move.b	d0,d3
	bsr.s	.byte
	move.b	d0,d4
	bsr.s	.byte
	and	#$ff,d0
	addq	#4,d0
.meth9x:
	move.b	d3,(a1)+
	add.b	d4,d3
	dbra	d0,.meth9x
	bra	.traduit
.meth10:
	bsr.s	.byte
	move.b	d0,d7
.meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
	bsr.s	.byte
	move.b	d0,d4
	moveq	#8-1,d3
.meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	.nomsk1
	bsr.s	.byte
.nomsk1:
	move.b	d0,(a1)+
	dbra	d3,.meth10x
	bra	.traduit
.byte8:
	bsr.s	.byte
	addq.b	#1,d0
	move.b	d0,d3
	asl	#8,d3
	rts
.byte:
	MOVE.L	a2,a5
	MOVE	D1,D0
.X1:	ADD	D2,D2
	BEQ.S	.X2
	BCC.S	.X3
	ADD	D0,a5
.X3:	MOVE	(a5)+,D0
	BPL.S	.X1
	rts
.X2:
	WAITDMA
	BCC.S	.X4
	ADD	D0,a5
.X4:	MOVE	(a5)+,D0
	BPL.S	.X1
	RTS
.DECODE3:
	ADDQ	#2,a3
	PEA	(a3)
	BSR.S	.DECODE
	MOVE.L	(sp)+,a5
	MOVE	a3,D0
	SUB	a5,D0
	MOVE	D0,-(a5)
.DECODE:
	ADD	D2,D2
	BNE.S	.TSTCARY1
.DECODE0:
	WAITDMA
.TSTCARY1:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.GETBIT:ADD	D2,D2
	BNE.S	.TSTCARY2
	WAITDMA
.TSTCARY2:
	ADDX.B	D0,D0
	BCC.S	.GETBIT
	MOVE	D0,(a3)+
	rts
.codes2:
	dc.b	.meth11-.base,.meth10-.base,.meth9-.base,.meth8-.base
	dc.b	.meth7-.base,.meth6-.base,.meth5-.base,.meth4-.base
	dc.b	.meth3-.base,.meth2-.base,.meth1-.base,.meth0-.base
	IFEQ	MARK
	DC.B	'MCMP'
	ENDC
	even
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH0
;
; DECRUNCHER HUFFMANN
;
DECRUNCH1:
	DC.W	$601A
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	-1		;PAS DE RELOCATION
.base_page:
;
; on recopie le fichier pack‚ … la fin du fichier d‚pack‚
;
	move.l	.length(pc),d0
	lea	.pack(pc),a0
	add.l	d0,a0			;ptr source
	move.l	a0,a3

	lea	.pack+ajuste(pc),a1
	add.l	.longueur(pc),a1	;ptr dest
	move.l	a1,a2
	move.l	a2,a0
	sub.l	d0,a0

	addq.l	#7,d0
	lsr.l	#3,d0
.move_it:
	move.l	-(a3),-(a1)
	move.l	-(a3),-(a1)
	dbra	d0,.move_it

;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026 octets)

	lea	.pack(pc),a1

	bsr	.decomp

	lea	.base_page-$100(pc),a2
	lea	.pack(PC),A3
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	add.l	$e(a3),a0		;SKIPPE LABELS !!!!
	LEA	$1C(A3),A1
	add.l	a1,a0

	MOVE.L	(A0)+,D0
	BEQ.S	.NORELOC
	ADD.L	D0,A1
	MOVE.L	8(a2),D0
	MOVEQ	#0,D1
.RELOC1	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.RELOC2
	LEA	$FE-1(A1),A1
	BRA.S	.RELOC3
.RELOC2	ADD.L	D0,(A1)
.RELOC3	MOVE.B	(A0)+,D1
	BNE.S	.RELOC1
.NORELOC
	MOVE.L	2(A3),d0
	MOVE.L	d0,$C(a2)
	MOVE.L	6(A3),$14(a2)
	MOVE.L	$A(A3),$1C(a2)
	ADD.L	8(a2),d0
	MOVE.L	d0,$10(a2)
	ADD.L	$14(a2),d0
	MOVE.L	d0,$18(a2)
	move.l	d0,a5

	movem.l	.MOVER(pc),d0-d3
	movem.l	d0-d3,LITTLE_PLACE(a2)

	LEA	$1C(A3),A0
	MOVE.L	.longueur(PC),D2
	lea	.pack+ajuste+1026(pc),a3
	add.l	d2,a3

	ADDQ.L	#3,D2
	LSR.L	#2,D2
	lea	.base_page(pc),a1
	MOVEQ	#0,D0
	jmp	LITTLE_PLACE(a2)

.MOVER	MOVE.L	(A0)+,(A1)+	;16 octets
	SUBQ.L	#1,D2
	BNE.S	.MOVER
.CLEARER
	MOVE.L	D0,(A5)+
	CMP.L	A3,A5
	BLO.S	.CLEARER
	JMP	(A4)
.decomp
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026 octets)
;
	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR.s	.DECODE0
	MOVE	(a2)+,D1
	bra.s	.traduit
.base:
	move.b	d0,(a1)+
.traduit:
	RDBYTE

	cmp.l	a3,a5
	blo.s	.base
	rts
.DECODE3:
	ADDQ	#2,a3
	PEA	(a3)
	BSR.S	.DECODE
	MOVE.L	(sp)+,a5
	MOVE	a3,D0
	SUB	a5,D0
	MOVE	D0,-(a5)
.DECODE:
	ADD	D2,D2
	BNE.S	.TSTCARY1
.DECODE0:
	WAITDMA
.TSTCARY1:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.GETBIT:ADD	D2,D2
	BNE.S	.TSTCARY2
	WAITDMA
.TSTCARY2:
	ADDX.B	D0,D0
	BCC.S	.GETBIT
	MOVE	D0,(a3)+
	rts
	IFEQ	MARK
	DC.B	'MHUF'
	ENDC
	even
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH1

;
; DECRUNCHER PACK
;
DECRUNCH2:
	DC.W	$601A
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	-1		;PAS DE RELOCATION
.base_page:
;
; on recopie le fichier pack‚ … la fin du fichier d‚pack‚
;
	move.l	.length(pc),d0
	lea	.pack(pc),a0
	add.l	d0,a0			;ptr source
	move.l	a0,a3

	lea	.pack+ajuste(pc),a1
	add.l	.longueur(pc),a1	;ptr dest
	move.l	a1,a2
	move.l	a2,a0
	sub.l	d0,a0

	addq.l	#7,d0
	lsr.l	#3,d0
.move_it:
	move.l	-(a3),-(a1)
	move.l	-(a3),-(a1)
	dbra	d0,.move_it

;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (256 octets)

	lea	.pack(pc),a1

	bsr	.decomp

	lea	.base_page-$100(pc),a2
	lea	.pack(PC),A3
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	add.l	$e(a3),a0		;SKIPPE LABELS !!!!
	LEA	$1C(A3),A1
	add.l	a1,a0

	MOVE.L	(A0)+,D0
	BEQ.S	.NORELOC
	ADD.L	D0,A1
	MOVE.L	8(a2),D0
	MOVEQ	#0,D1
.RELOC1	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.RELOC2
	LEA	$FE-1(A1),A1
	BRA.S	.RELOC3
.RELOC2	ADD.L	D0,(A1)
.RELOC3	MOVE.B	(A0)+,D1
	BNE.S	.RELOC1
.NORELOC
	MOVE.L	2(A3),d0
	MOVE.L	d0,$C(a2)
	MOVE.L	6(A3),$14(a2)
	MOVE.L	$A(A3),$1C(a2)
	ADD.L	8(a2),d0
	MOVE.L	d0,$10(a2)
	ADD.L	$14(a2),d0
	MOVE.L	d0,$18(a2)
	move.l	d0,a5

	movem.l	.MOVER(pc),d0-d3
	movem.l	d0-d3,LITTLE_PLACE(a2)

	LEA	$1C(A3),A0
	MOVE.L	.longueur(PC),D2
	lea	.pack+ajuste+256(pc),a3
	add.l	d2,a3

	ADDQ.L	#3,D2
	LSR.L	#2,D2
	lea	.base_page(pc),a1
	MOVEQ	#0,D0
	jmp	LITTLE_PLACE(a2)

.MOVER	MOVE.L	(A0)+,(A1)+	;16 octets
	SUBQ.L	#1,D2
	BNE.S	.MOVER
.CLEARER
	MOVE.L	D0,(A5)+
	CMP.L	A3,A5
	BLO.S	.CLEARER
	BRA	.MOVER+256-LITTLE_PLACE
.decomp
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (256 octets)
;
	moveq	#0,d4
	move.l	a2,a4
	moveq	#256/4-1,d0
.clear:	move.l	d4,(a4)+
	dbra	d0,.clear
	lea	.codes2(pc),a4
	moveq	#nbmeth-1,d3
.copy:
	move.b	(a0)+,d4
	move.b	(a4)+,(a2,d4.w)
	dbra	d3,.copy
	moveq	#0,d0
	bra.s	.traduit
.sure:
	rts
.base:
	move.b	d0,(a1)+
.traduit:
	cmp.l	a2,a0
	bhs.s	.sure
	move.b	(a0)+,d0
	move.b	(a2,d0.w),d4
	jmp	.base(pc,d4.w)
.meth0	move.b	(a0)+,(a1)+
	bra.s	.traduit
.meth1:
	move.b	(a0)+,d6
.meth3:
	moveq	#0,d3
.meth2xx:
	move.b	(a0)+,d3
	move.b	d6,(a1)+
	move.b	d6,(a1)+
.meth2x:
	move.b	d6,(a1)+
	dbra	d3,.meth2x
	bra.s	.traduit
.meth2:
	move.b	(a0)+,d6
	bsr.s	.byte8
	bra.s	.meth2xx
.meth4:
	moveq	#0,d3
.cnt8:
	move.b	(a0)+,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4
	moveq	#0,d3
.copy4:
	move.b	(a0)+,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.meth4x:move.b	(a4)+,(a1)+
	dbra	d3,.meth4x
	bra.S	.traduit
.meth5:
	moveq	#0,d3
.cnt16:
	move.b	(a0)+,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4
	bsr.s	.byte8
	bra.s	.copy4
.meth6:
	bsr.s	.byte8
	bra.s	.cnt8
.meth7:
	bsr.s	.byte8
	bra.s	.cnt16
.meth8:
	clr	d3
	move.b	(a0)+,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra.s	.traduit
.meth9:
	move.b	(a0)+,d3
	move.b	(a0)+,d4
	clr	d0
	move.b	(a0)+,d0
	addq	#4,d0
.meth9x:
	move.b	d3,(a1)+
	add.b	d4,d3
	dbra	d0,.meth9x
	bra	.traduit
.meth10:
	move.b	(a0)+,d7
.meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
	move.b	(a0)+,d4
	moveq	#8-1,d3
.meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	.nomsk1
	move.b	(a0)+,d0
.nomsk1:
	move.b	d0,(a1)+
	dbra	d3,.meth10x
	bra	.traduit
.byte8:
	move.b	(a0)+,d3
	addq.b	#1,d3
	asl	#8,d3
	rts
.codes2:
	dc.b	.meth11-.base,.meth10-.base,.meth9-.base,.meth8-.base
	dc.b	.meth7-.base,.meth6-.base,.meth5-.base,.meth4-.base
	dc.b	.meth3-.base,.meth2-.base,.meth1-.base,.meth0-.base
	IFEQ	MARK
	DC.B	'MPAK'
	ENDC
	even
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH2

		section	data
internal:	dc.b	"Erreur interne num‚ro ",0
WELCOME:	dc.b	27,"EM-Packer V1.7 04/04/90",13,10,10,10,0
inputname:	dc.b	"Nom du fichier … cruncher : (CR=exit)",13,10,0
recherche:	dc.b	"recherche des noms de fichiers",13,10,0
spaces:		dc.b	"    ",0
paramcons:	dc.b	"Attention, les paramŠtres sont pour tous les fichiers !!!",13,10,0
input_offset:	dc.b	"Offset de compression en hexa (CR=100) max=10000 :",13,10,0
mess_type:	dc.b	"Type de compression (CR=1) :",13,10
		dc.b	" 1) Huffmann+Pack",13,10
		dc.b	" 2) Huffmann",13,10
		dc.b	" 3) Pack",13,10
		dc.b	0
mess1:		dc.b	"compression en octets (rept,str,topo)...",13,10,0
mess2:		dc.b	'assignation des codes les moins fr‚quents',13,10,0
mess3:		dc.b	'g‚n‚ration du code',13,10,0
mess4:		dc.b	"Temps total de compression : ",0
mess5:		dc.b	"ms",13,10
		dc.b	"Longueur originelle : ",0
mess7:		dc.b	13,10,"Longueur finale     : ",0
mess8:		dc.b	13,10,"Gain en octets      : ",0
mess10:		dc.b	"% de compression",13,10,0
loadmess:	dc.b	"Loading file ",0
savemess:	dc.b	"Saving file ",0
cr2:		dc.b	13,10,0
plantade:	dc.b	"ESC",0
memory:		dc.b	"Limite basse m‚moire : ",0
press_space:	dc.b	"Press SPACE",0
mess_entet:	dc.b	"Compression programme (CR=1)",13,10
		dc.b	"1) rien de plus",13,10
		dc.b	"2) insertion relogeur",13,10
		dc.b	"3) d‚gagement entete GEMDOS",13,10,0
mess21:		dc.b	"Calcul des fr‚quences",13,10,0
mess22:		dc.b	"Tri des fr‚quences",13,10,0
mess23:		dc.b	"Cr‚ation de l'arbre de Huffmann",13,10,0
mess24:		dc.b	"Calcul des codes de Huffmann"
		dc.b	" et sauvegarde de l'arbre",13,10,0
mess25:		dc.b	"Tri des codes de Huffmann",13,10,0
mess26:		dc.b	"G‚n‚ration du code",13,10,0
relogeur:	dc.b	"Insertion du relogeur",13,10,0
chaine:		dc.b	80-2,0
filein:		ds.b	80
	even
	SECTION	BSS
current_a5:ds.l	1
NB:	ds.l	1
time2:	ds.l	1
time:	ds.l	1
;
; variables PACK
;
ptrdeb:	ds.l	1
ptrfin:	ds.l	1
lasthex:ds.l	1		;affichage incr‚mental
lastrep:ds.w	1
lasttopo:ds.w	1

ptrdebut:ds.l	1
ptrfin1:ds.l	1
ptrsegm:ds.l	1
finsegm:ds.l	1
ptrfinal:ds.l	1
ptrfin2:ds.l	1
;
; variables parametres
;
compteur:	ds.w	1
length:		ds.l	1
filenames:	ds.l	1
cur_name:	ds.l	1
longueur_source:ds.l	1
longueur_dest:	ds.l	1
offset:		ds.l	1
flag_entete:	ds.b	1
type_comp:	ds.b	1
;
; variables huffmann
;
racine:	ds.l	1
const2:	ds.l	1		;longueur fichier
const4:	ds.l	1		;d‚but arbre tri‚
const5:	ds.l	1		;adresse fin arbre tri‚+d‚but arbre complet
const6:	ds.l	1		;adresse fin arbre complet
frequences:
	ds.l	257		;+code fin de fichier

freq2:	ds.w	256		;pour calcul des moins fr‚quents
	ifne	1-TOPO8
freqtopo:ds.b	256
	endc
freq:	ds.w	nbmeth
best:	ds.w	nbmeth*2
codes:	ds.w	nbmeth
dta:	ds.b	44
fileout:ds.b	128
ptrfree:ds.l	1

ramtop:		ds.l	1
ptr_buf_names:	ds.l	1	;pointeur sur fichiers … cruncher
ptr_buffer_hash:ds.l	1	;ptr sur buffer lenoffset*8+8 octets
occur:	ds.l	256*2
ptr_buf_debut:ds.l	1

	ds.l	100
pile:
