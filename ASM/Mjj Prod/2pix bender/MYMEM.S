;
; mymem.s:
;
; gestion basique de memoire
;
; fichier provenant du repertoire 2pix
;
	TEXT
*	ifeq _FLAGMYMEM
*_FLAGMYMEM	set true
*	endc
*	IFND _lib_mem_on
*_lib_mem_on equ 1

safemem	equ 1
bssmemorytl equ 630*1024  346*1024

_S_MY_MEM		jmp initmemall

initmemall:
; d0 = taille maximal que l'effet demande
; retour: d0 = -1 si pas asser de memoire

	ifeq safemem
	move.l d0,-(sp)
	move.w #72,-(sp)
	trap #1
	addq.l #2,sp
	move.l d0,ptr_mem
	move.l d0,basemem
	move.l (sp)+,d1
	add d1,d0
	move.l d0,ptr_highmem
	endc

	ifne safemem
	move.l #bssmemory,d0
	move.l d0,ptr_mem
	move.l d0,basemem
	add.l #bssmemorytl,d0
	move.l d0,ptr_highmem
	endc

	lea whatzone,a0
	move.l #freebloc32k,d0
	move.l d0,(a0)
	move.l d0,a0

	moveq #-1,d0
	moveq #0,d1
	move.l d0,(a0)+
	move.l d1,(a0)+

	rts
setnewbasemem:
	move.l ptr_mem,d0
	move.l d0,basemem
	rts
dezinitmem:
	ifeq safemem
	move.l basemem,a0
	move.l (a0),-(sp)
	move.w #73,-(sp)
	trap #1
	addq.l #6,sp
	endc
	rts
addzoneram32256:
	rts
	; d0 = adresse contenant 32256 octet de libre

	;??? ou whatzone? je me melange les pinceau lstadrzone,a2
	move.l d0,(a2)+
	move.l #32256,(a2)+
	;move.l a2,lstadrzone
	moveq #-1,d1
	move.l d1,(a2)+
	clr.l (a2)+		; taille zero au cas ou
	
	; il faut ajouter des truc, comment on gere whatzone
	rts
testzonelibre:
	; d0 = taille demand�
	; retour = d1=adresse= ok
	; 	d1=-1: aucune zone libre de cette tailles
	move.l whatzone,a2
	move.l (a2),d2
	tst.l d2
	bmi.s .finnomatch
	move.l (a2)+,a1		; a1 = adresse
	move.l (a2)+,d2		; d2=taille ram
	cmp.l d0,d2
	bmi.s .notmatch
.match:
	; ici, il y'a de la place
	move.l a1,d3		; adresse ram
	move.l a1,d1
	add.l d0,d3		; nouvelle adresse ram libre
	sub.l d0,d2		; de taille d2-d0
	move.l d3,-8(a2)
	move.l d2,-4(a2)
	; d1=adresse ram de taille d0
	; mission accomplie
	rts
	
	
.notmatch:
	; ici il n'ya pas de place
.1	move.l (a2),d3	; adresse ?
	bmi.s .finnomatch
	move.l (a2)+,a1
	move.l (a2)+,d2
	cmp.l d0,d2
	bpl.s .match
	bra.s .1
.finnomatch:
	moveq #-1,d1
	rts

_pushgetvalue:
	lea ptr_mem,a6
	move.l (a6),a0
	rts
getMem:
; d0 = taille demandé
; retour: a0 = adresse buffer
	move.l a6,-(sp)
	move.l d1,-(sp)
	
	lea ptr_mem,a6
	move.l (a6),a0
	move.l a0,d1
	add.l d0,d1
	move.l d1,(a6)		; ptr_mem pointera sur nouveau buffer memoire
	
	move.l (sp)+,d1
	move.l (sp)+,a6
	rts
	
freeMem:
; d0 =  taille a enlever
	move.l a6,-(sp)
	move.l d1,-(sp)
	lea ptr_mem,a6
	move.l (a6),d1
	sub.l d0,d1
	move.l d1,(a6)
	move.l (sp)+,d1
	move.l (sp)+,a6
	rts

convertallptr:
	; a0,a2 = plusieurs adresse liste de dc.l taille qui seront remplacé par dc.l adresse buffer de taille elemnent(b w ou l)
	; valeur de fin: -1
	;  valeur declenchement align 64k:
	;           =$8 000 0000			-> valeur remplacé=e rts
	; suivit 
	; retour:
	; d7 = taille total aloué
	; (a5)+ = d7 
	
	
	move.l ptrdernierdelaliste,a5
	
	move.l a5,a4
	moveq #0,d6
	
	moveq #0,d7
	move.l a0,a2
.loop:
	move.l (a2),d0
	tst.l d0
	bmi.s .negative
	add.l d0,d7
	jsr getMem
	
	move.l a0,(a2)+
	; d0 contient toujours la taille
	move.l d0,(a5)+						; a5 est une (pile? file ?) qui contient l'ensemble des valeurs
	addq.l #1,d6
	bra.s .loop	
.negative
	cmp.l #$80000000,d0
	beq.s .align64k
*	cmp.l #$80000001,d0				; push emplacement memoire
*	beq.s .push
	bra.s .finptrbufferconvert
.align64k
	jsr aligne64k
	move.l a0,(a2)+			; adresse de buffer taille variable
	neg.l d2
	move.l d2,(a5)+
	sub.l d2,d7
	addq.l #1,d6
	bra.s .loop
*.push
*	jsr pushgetvalue
*	move.l a0,
.finptrbufferconvert
	; d7 = taille total aloué
;	move.l d7,(a5)+
	neg.l d6
	move.l d6,(a5)+   si par exemple = -12 : retirer 12 element lors d'un popmem
	move.l a5,ptrdernierdelaliste
	rts
	
	
aligne64k:	; positionne l'adresse du futur buffer sur une page de 64k
	lea ptr_mem,a6
	move.l (a6),a0
	move.l a0,d1
	moveq #0,d2
	tst.w d1
	beq.s .alreadyaligned		; 2 align 64k ne bouffera pas 64k suplementaire
	move.l d1,d2
	add.l #$10000,d1
	clr.w d1
	sub.l d1,d2
	move.l d1,(a6)
	; d2 = nombre d'octet sauté
.alreadyaligned:
	rts
tempvar	dc.l 0
getMemSameBase:			; idem que getMem sauf que la plage d'adresse de l'ensemble du buffer doit avoir la same base c'est a dire le mot de poid fort de chaque adresse pointant dans le buffer est le meme
	clr.l tempvar
	lea ptr_mem,a6
	move.l (a6),a0
	move.l a0,d1			; d1 = adresse de depart
	move.l d1,d2
	add.l d0,d2			; on ajoute la taille en octet demander du buffer
	subq.l #1,d2			; -1  car par exemple 64k-200 + 200 = valeur differente
	swap d1
	swap d2
	cmp.w d1,d2
	beq.s .itsok
; cas problematique

	move.l d0,-(sp)
	jsr aligne64k
	move.l d2,tempvar
	movem.l (sp)+,d0
.itsok	
	
	jsr getMem 			; d0 = taille ptr_mem pointe sur aligné 64k ou le truc classique 
	move.l tempvar,d2			; le kasé chéhan, d2 contient le nombre d'octet suplementaire aloué si on doit faire un aligne64k
					; si d2 non nul, l'adresse du debut du buffer est du type $xxxx0000
	move.l a0,d3		; d3 = adresse buffer
	swap d3			; d3.W = base d3.HW = offset du premier element

	; retour: a0 = adresse buffer same base
	; d2.l = extra octet utilisé
	; d3.w = base utilisé

	rts
	
*getMem:
*; d0 = taille demandé
*; retour: a0 = adresse buffer
*	move.l a6,-(sp*)
*	move.l d1,-(sp)
*	
*	lea ptr_mem,a6
*	move.l (a6),a0
*	move.l a0,d1
*	add.l d0,d1
*	move.l d1,(a6)		; ptr_mem pointera sur nouveau buffer memoire
*	
*	move.l (sp)+,d1
*	move.l (sp)+,a6
*	rts
	

getTempMem:
; d0 = taille
; idem que getMem sauf que en haut de la memoire
	move.l a6,-(sp)
	move.l d1,-(sp)
	lea ptr_highmem,a6
	move.l (a6),d1
	sub.l d0,d1
	move.l d1,a0
	move.l d1,(a6)
	move.l (sp)+,d1
	move.l (sp)+,a6
	rts
	
freeTempMem:
; d0 = taille
	move.l a6,-(sp)
	move.l d1,-(sp)
	lea ptr_highmem,a6
	move.l (a6),d1
	add.l d0,d1
	move.l d1,(a6)
	move.l (sp)+,d1
	move.l (sp)+,a6
	rts

*preparetable:
*; a1: table de depart  32767*sinus(x)
*; d0: nombre d'element de la table de depart 1024 ou 1013
*; d1: amplitude
*; d2: modulo
*; d3: lsl value
*; a2: table d'arrivé
*
*; fait tablea2[x]=(Amp*a1(x) mod d2) lsl d3
*
*	add d1,d1
*
*	move.w d0,-(sp)
*	move.w d0,d6
*	subq #1,d6
*.loop
*	move (a1)+,d4
*	muls d1,d4
*	swap d4
*	and d2,d4
*	lsl d3,d4
*	move d4,(a2)+
*	dbf d6,.loop
*	rts


***************
popmem:
; a2=adresse liste ptr avec adresse buffer
	move.l ptrdernierdelaliste,a0
	move.l -(a0),d0
	bmi.s .xfois
	jsr freeMem
	*subq.l #4,a0
	move.l a0,ptrdernierdelaliste
	rts
.xfois
	neg.l d0	; repeter d0 fois:
	; a0=dernier de la liste
	move.l d0,d1
	add.l d1,d1
	add.l d1,d1		; *4
	sub.l d1,a0		; dernierdelaliste-12element*4
	clr.l d3
	move.l d0,d4
	add d4,d4
	add d4,d4		; *4
	subq #1,d0
.loop:
	move.l (a0)+,d2		; taille
	tst.l d2	; taille negative ?
	bpl.s .1
	neg.l d2
	add.l d2,d3
	move.l #$80000000,(a2)+		; marqueur align 64k
	bra.s .2
.1	add.l d2,d3
	move.l d2,(a2)+		;	 remplacer buffer par sa taille pour une utilisation ulterieur  a2 = liste de ptr
.2	dbf d0,.loop
	move.l d3,d0
	jsr freeMem
	
	sub.l d4,a0
	subq.l #4,a0				; ???? a voir
	move.l a0,ptrdernierdelaliste
	rts
**************************

;bloc32kgestion:
; a0 = adresse  listebloc
; d0 = taille demand�
;	move.l (a0)+,d1
;	bmi.s .finliste
;	move.l d1,a1	; a1 = adresse memoire
;	move.l (a1)+,d2	; amount of free space
;	sub.l #taille_descripteur,d2
;	cmp.l d0,d2
;	bpl.s .declareblochere
;	add.l #taille_descripteur,d2
;	add.l d2,a1		; a1 nouveau descripteur
;
;declare_buffer:		; d0= taille demander
;			; d1 = flag type	
;			; a2 = adresse pointeur variable
;			rts
;
;
outofmemorypanic:	ds.l 1	; adresse a aller en cas de out of memory
				; typiquement fermer le programme dans de bonne condition
				; choisie par le demosysteme en setant cette variable au cours du temps

	DATA
ptrdernierdelaliste dc.l bufferlistetaille
 	BSS
ptr_mem	ds.l 1
ptr_highmem	ds.l 1
*ptrdernierdelaliste: ds.l 1
	
bufferlistetaille
;				ds.l 1000   400 etiquettetaille max

	;				L: negatif: =-nombre de truc a enlever
	;				L: positif: taille memoire a suprimer
whatzone	ds.l 1				
freebloc32k:
	ds.l 4 		; 4 adresse max 32k
	ds.l 1		; -1 a la fin de la liste
	ds.l 1		; -2
				
basemem	ds.l 1
	ifne safemem
bssmemory	ds.b bssmemorytl
	endc
	
adrfirstblocramfree	ds.l 1
adrfirstblocramused	ds.l 1

;organisation de la memoire:
;bloc:	dc.l nextbloc ou -1		20 octet pour le descripteur
;	dc.l predbloc ou -1	pas besoin en fait on stoque ou est le predbloc pendant la recherche
;	dc.l flag_deplacable type zone libre ou non type boundary64k ou non type bound256octet ou non
;	dc.l adresse pointeur variable associ�
;	dc.l taille du bloc
;	ds.b taille : le bloc en question
;
; different flag:		  valeur bit
;	ram free ou buffer used		1
;	64k boundary			2
;	256 octet boundary		3
;	deplacable ou non		4
;	

premierdescripteurbuffer:	ds.l 1
premierdescripteurfree:		ds.l 1

;liste chain� adresse par ordre croissant
		rsreset
nextdescriptor		rs.l 1
flagmem			rs.w 1
taille			rs.l 1
linkvar			rs.l 1		; variable associ�= adresse pointeur
	
;flag samebasesameoffset	: le buffer qui peut etre deplacer doit 
;non seulement etre samebase sur l'ensemble mais doit commencer au meme
;offset pour la valeur d'indice 0	(exemple convx dans demo4k.s)


;parcoursdescriptorfreemem:
;	; d0= taille demand�
;	move.l firstdescriptorfreemem,a0
;.loop	move.l a0,preddesc
;	
;	move.l taille(a0),d1		; taille de la zone libre 
;	cmp.l d0,d1			; d1-d0>=0 = d1>=d0
;	bge.s .itfits
;	move.l nextdescriptor(a0),d1
;	cmp.l #-1,d1
;	beq.s .outofmemorypanic
;
;	bra.s .loop
;.itfits:
;	; ici  on a trouver une zone memoire valable		
;	; dont le descripteur est dans a0
;	; on a d1 octet libre on va prendre d0 sur d1 octet
;	; et creer un nouveau descripteur intermediaire
;	lea tlofdescriptor(a0),a2	; a2 = adresse zone ram
;	move.l nextdescriptor(a0),d2	; adresse du descripteur suivant
;
;	move.l d0,taille(a0)		
;
