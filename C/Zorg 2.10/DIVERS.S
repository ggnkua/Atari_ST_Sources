/********************************************************************
*																	*
*		mediach(): force the media change on a removable drive		*
*																	*
********************************************************************/

	XDEF mediach

/* int mediach( int drive ); */
/* paramŠtre dans D0 */

regs_used	REG d7

mediach:
	movem.l	#regs_used,-(sp)

	move.w	d0,mydev
	add.b	#'A',d0
	move.b	d0,fspec		;Set drive spec for search

loop:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)

	move.l	$472.w,oldgetbpb
	move.l	$47e.w,oldmediach
	move.l	$476.w,oldrwabs

	move.l	#newgetbpb,$472.w
	move.l	#newmediach,$47e.w
	move.l	#newrwabs,$476.w

	; Fopen a file on that drive
	move.w	#0,-(sp)
	move.l	#fspec,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp

	; Fclose the handle
	tst.l	d0
	bmi.s	noclose

	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

noclose:
	moveq	#0,d7
	cmp.l	#newgetbpb,$472.w
	bne.s	done

	moveq	#1,d7
	move.l	oldgetbpb,$472.w
	move.l	oldmediach,$47e.w
	move.l	oldrwabs,$476.w

done:
	trap	#1
	addq.l	#6,sp

	move.l	d7,d0
	movem.l	(sp)+,#regs_used
	rts

/*	New Getbpb()...if it's the target device, uninstall vectors. 
	In any case, call normal Getbpb(). */

newgetbpb:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne.s	dooldg

	move.l	oldgetbpb,$472.w
	move.l	oldmediach,$47e.w
	move.l	oldrwabs,$476.w
dooldg:
	move.l	oldgetbpb,a0
	jmp		(a0)

/*	New Mediach()...if it's the target device, return 2. Else call old. */

newmediach:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne.s	dooldm
	moveq	#2,d0			;Target device, return 2

	rts

dooldm:
	move.l	oldmediach,a0	;Call old
	jmp		(a0)

/*	New Rwabs()...if it's the target device, return E_CHG (-14) */

newrwabs:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne.s	dooldr
	moveq.l	#-14,d0
	rts

dooldr:
	move.l	oldrwabs,a0
	jmp		(a0)

	DATA

fspec:
	dc.b	"X:\\X",0
mydev:
	ds.w	1
oldgetbpb:
	ds.l	1
oldmediach:
	ds.l	1
oldrwabs:
	ds.l	1

/* mediach */

/********************************************************************
*																	*
*					cherche du d‚but vers la fin					*
*																	*
********************************************************************/

	XDEF search_pattern_ste

/* long search_pattern_ste( char *buffer, long size, char *pattern, int pattern_size ) */
/* les paramŠtres sont dans A0, D0, A1 et D1 */

regs_used	REG a2/d2-d4

search_pattern_ste:
	and.l	#$FFFF,d0		;met le mot de poid fort … 0
	cmp.l	#$8000,d0
	ble.s	ste_ok
	moveq.l	#-2,d0
	rts	

ste_ok:
	movem.l	#regs_used,-(sp)

	move.l	d0,d3			;taille du buffer
	subq.w	#1,d3
	subq.w	#2,d1			;taille du pattern -1 pour dbxx
							;et -1 car le premier caratcŠre a d‚ja ‚t‚ trouv‚

	move.b	(a1),d2			;premier caractŠre … chercher
ste_retour:
	subq.w	#1,d0			;-1 pour le premier dbxx
							;et -1 au retour d'un recherhe d‚fectueuse
							;car A0 a ‚t‚ incr‚ment‚ mais D0 n'a pas ‚t‚ d‚cr‚ment‚
	bmi.s	ste_end			;il n'y a plus rien … tester
ste_test:
	cmp.b	(a0)+,d2		;c'est bon ?
	dbeq	d0,ste_test
	beq.s	ste_test_chaine	;c'est le mˆme octet
ste_end:
	moveq.l	#-1,d0			;sinon on est arriv‚ au bout
	movem.l	(sp)+,#regs_used
	rts

ste_test_chaine:
	move.w	d1,d4			;taille du pattern
	bmi.s	ste_fini		;pattern d'un caractŠre seulement
	lea		1(a1),a2		;deuxiŠme caractŠre … chercher
	lea		(a0),a3			;position courante
ste_test1:
	cmpm.b	(a2)+,(a3)+		;compare la suite de la chaŒne
	dbne	d4,ste_test1
	bne.s	ste_retour		;c'est pas bon
ste_fini:
	sub.w	d0,d3			;ok, d‚calage de la position courante par rapport au d‚but du buffer
	move.l	d3,d0
	movem.l	(sp)+,#regs_used
	rts

/* search_pattern_ste */

/********************************************************************
*																	*
*				cherche de la fin vers le d‚but 					*
*																	*
********************************************************************/

	XDEF search_pattern_ets

/* long search_pattern_ets( char *buffer, long size, char *pattern, int pattern_size ) */
/* les paramŠtres sont dans A0, D0, A1 et D1 */

regs_used	REG a2/d2-d3

search_pattern_ets:
	and.l	#$FFFF,d0		;met le mot de poid fort … 0
	cmp.l	#$8000,d0
	ble.s	ets_ok			;<32767 ($7FFF) ?
	moveq.l	#-2,d0
	rts	

ets_ok:
	movem.l	#regs_used,-(sp)

	subq.w	#2,d1			;taille du pattern -1 pour dbxx
							;et -1 car le premier caratcŠre a d‚ja ‚t‚ trouv‚
	add.w	d0,a0			;on part de la fin

	move.b	(a1),d2			;premier caractŠre … chercher
ets_retour:
	subq.w	#1,d0			;-1 pour le premier dbxx
							;et -1 au retour d'un recherhe d‚fectueuse
							;car A0 a ‚t‚ d‚cr‚ment‚ mais pas D0
	bmi.s	ets_end			;il n'y a plus rien … tester
ets_test:
	cmp.b	-(a0),d2		;c'est bon ?
	dbeq	d0,ets_test
	beq.s	ets_test_chaine	;c'est le mˆme octet
ets_end:
	moveq.l	#-1,d0			;sinon on est arriv‚ au bout
	movem.l	(sp)+,#regs_used
	rts

ets_test_chaine:
	lea		1(a1),a2		;deuxiŠme caractŠre … chercher
	lea		(a0),a3			;position courante
	move.w	d1,d3			;taille du pattern
ets_test1:
	cmpm.b	(a2)+,(a3)+		;compare la suite de la chaŒne
	dbne	d3,ets_test1
	bne.s	ets_retour		;c'est pas bon
	movem.l	(sp)+,#regs_used
	rts

/* search_pattern_ets */

/********************************************************************
*																	*
*				passe tout un buffer en majuscules					*
*																	*
********************************************************************/

	XDEF and_buffer

/* void and_buffer( char *buffer, long size ) */
/* les paramŠtres sont dans A0 et D0 */

and_buffer:
	lsr.l	#4,d0			;/16, on traite par 16 octets
	subq.w	#1,d0

	move.l	d1,-(sp)		;sauvegarde D1

	move.l	a0,d1
	btst	#0,d1
	beq.s	impaire
	and.b	#$DF,(a0)+
impaire:
	move.l	#$DFDFDFDF,d1	;masque ~('a'-'A')
minuscule:
	and.l	d1,(a0)+
	and.l	d1,(a0)+
	and.l	d1,(a0)+
	and.l	d1,(a0)+
	dbra	d0,minuscule

	move.l	(sp)+,d1		;restaure D1

	rts

/* and_buffer */

/********************************************************************
*																	*
*		lit un ou plusieurs secteurs du disque dur sans driver		*
*																	*
********************************************************************/

	XDEF hard_read

/* int hard_read( long debut, int nombre, char *buffer, int control ) */
/* les paramŠtres sont dans D0, D1, A0 et D2 dans l'ordre */

hard_read:
	move.l	a0,buffer
	move.w	d1,nombre
	move.l	d0,debut
	move.w	d2,control
	pea		read
	move.w	#$26,-(a7)	;Supexec
	trap	#14
	addq.l	#6,a7
	rts

buffer:
	ds.l	1
nombre:
	ds.w	1
debut:
	ds.l	1
control:
	ds.w	1

/* int hard_read */
	
/********************************************************************
*																	*
*		‚crit un ou plusieurs secteurs du disque dur sans driver	*
*																	*
********************************************************************/

	XDEF hard_write

/* int hard_write( long debut, int nombre, char *buffer, int control ) */
/* les paramŠtres sont dans D0, D1, A0 et D2 dans l'ordre */

hard_write:
	move.l	a0,buffer
	move.w	d1,nombre
	move.l	d0,debut
	move.w	d2,control
	pea		write
	move.w	#$26,-(a7)	;Supexec
	trap	#14
	addq.l	#6,a7
	rts

/* int hard_write */

/********************************************************************
*																	*
*					I/O du disque dur sans driver					*
*																	*
********************************************************************/

wdc		=	$ffff8604 	;FDC/HDC-Access, DMA-Sector-Count
wdl		=	wdc+2		;DMA-Mode/Status
dma		=	$ffff8609 	;DMA-Adress HI
flock	=	$43E		;Floppy-VBL-Flag
port 	=	$fffffa01 	;Parallel-Port, Bit 5=HDC-IRQ

read:			; * Lire secteurs *
	lea		wdc,a0
	st		flock		;M‚moriser routine Floppy-VBL

	moveq	#0,d0		;efface D0
	move.w	control,d0	;Num‚ro de contr“le
	lsl		#5,d0		;bits 0, 1 et 2 dans 5, 6 et 7
	swap	d0
	move.l	#$08008a,d1	;Commande READ du controleur 0
	or.l	d0,d1

	move.w	#$88,2(a0)	;AccŠs HDC, A1=0
	nop
	move.l	d1,(a0)		;Commande READ complŠte

	move.l	buffer,-(a7)	;buffer-Adress
	bsr		setdma		;Positionner DMA 
	addq.l	#4,a7

	bsr		set_parameters	;Nombre et num‚ros de secteurs 
	bmi		tout			;Timeout	!

	move.w	#$190,2(a0)
	nop
	move.w	#$90,2(a0)	;Remettre en READ
	nop
	move.w	nombre,(a0)	;Envoyer Sector-Count au DMA 
	nop
	move.w #$8a,2(a0)
	nop
	move.l	#0,(a0)		;Commencer transfert
	bsr		waitl		;Attendre max. 3 secondes
	bmi		tout		;Timeout !
	move.w	#$8a,2(a0)
	bra		exec

write:				; * Ecrire secteurs *
	lea		wdc,a0
	st		flock		;M‚moriser Floppy-VBL 
	move.l	buffer,-(a7)
	bsr 	setdma		;Positionner Adresse DMA
	addq.l	#4,a7

	move.w	control,d0	;Num‚ro de contr“le
	lsl		#5,d0		;bits 0, 1 et 2 dans 5, 6 et 7
	swap	d0
	move.l	#$0a008a,d1	;Commande WRITE du controleur 0
	or.l	d0,d1

	move.w	#$88,2(a0)	;AccŠs HDC, A1=0
	nop
	move.l	d1,(a0)		;Commande WRITE complŠte

	moveq	#0,d0

	bsr		set_parameters	;Nombre et num‚ros de secteurs
	bmi		tout		;Timeout !

	move.w	#$90,2(a0)
	nop
	move.w	#$190,2(a0)	;Mettre sur WRITE
	nop
	move.w	nombre,(a0)	;Envoyer Sector-Count au DMA 
	nop
	move.w	#$18a,2(a0)
	nop
	move.l	#$100,(a0)	;Commencer transfert
	bsr		waitl		;Attendre max. 3 secondes
	bmi		tout		;Timeout !
	move.w	#$18a,2(a0)

exec:
	nop
	move.l	(a0),d6		;Recup‚rer HDC/DMA-Status dans D6 
	and.l	#$ff00ff,d6	;HI=HDC, LO=DMA
tout:
	move.w	#$80,2(a0)	;Mettre sur FDC 
	nop
	move.l	(a0),d7		;R‚cup‚rer Completion-Byte 
	and.l	#$ff00ff,d7	;HI=HDC (0), LO=DMA
	clr		flock		;Lib‚rer routine Floppy-VBL
	rts					;fini

set_parameters:		;D‚finir nombre de secteurs et Sector-Count 
	move.w	#$8a,2(a0)
	bsr		wait		;Attendre que HDC-OK
	bmi		setpx		;Timeout !

	clr.w	d0
	move.b	debut+1,d0	;Sectornr. HI
	bsr		send_byte
	bmi		setpx

	move.b	debut+2,d0	;Sectornr. MID
	bsr		send_byte
	bmi		setpx

	move.b	debut+3,d0	;Sectornr. LO
	bsr		send_byte
	bmi		setpx

	move.w	nombre,d0	;Nombre de secteurs
	bsr		send_byte
setpx:
	rts					;fin

send_byte:		; * Envoyer 1 octet au HDC *
	swap	d0
	move.w	#$8a,d0
	move.l	d0,(a0)
	bra		wait

waitl:		;Attendre OK max. 3 secondes
	move.l	#450000,count
	bra		wait1
wait:		;Attendre OK max. 100 ms 
	move.l	#15000,count
wait1:
	subq.l	#1,count
	bmi		timeout
	move.b	port,d0
	and.b	#$20,d0	;HDC-Interrupt ?
	bne		wait1	;non
	moveq	#0,d0	;oui => OK
	rts

timeout:
	moveq	#1,d0	;Timeout	Z_READ_WRITE
	rts

setdma:		; * Positionner adresse DMA *
	move.b	7(a7),dma+4	;LO
	move.b	6(a7),dma+2	;MID
	move.b	5(a7),dma	;HI
	rts

even
count:
	dc.l	1	;Timeout-Counter

/********************************************************************
*																	*
*				un bon vieux Reset … froid pour 68000				*
*																	*
********************************************************************/

	XDEF reset000

/* void reset000( void ) */

reset000:
	SUPER
	move.w	#$2700,sr	;Reset total
	lea		ResRout(pc),a0
	lea		8.w,a1
	move.w	#$25,d0		;cette taille d‚pend de la longueur du code
copie:					;elle vaut (ClearStart - ResRout) /4
	move.l	(a0)+,(a1)+
	dbra	d0,copie
	jmp		8.w
ResRout:
	lea		BusErr(pc),a0
	move.l	a0,8.w
	lea		ClearStart(pc),a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
clear:
	movem.l	d0-d7/a1-a6,(a0)
	lea		(8+6)*4(a0),a0
	bra.b	clear
BusErr:
	move.l	4.w,a0
	jmp		(a0)
ClearStart:
	USER

/* reset000 */

/********************************************************************
*																	*
*				un Reset … froid pour 68030							*
*																	*
********************************************************************/

;	XDEF reset030
/* void reset030( void ) */

;reset030:
;	SUPER
;	move	#$2700,sr 
;	move.l	#$808,d0
;	movec	d0,cacr 
;	moveq	#0,d0 
;	movec	d0,vbr
;	pmove	zero,tc
;	pmove	zero,tt0 
;	pmove	zero,tt1 
;	move.l	4.w,8.w 
;	lea		ResRout2(pc),a0
;	lea		12.w,a1
;	move.w	#(ClearStart2-ResRout)/4,d0		;cette taille d‚pend de la longueur du code
;copie2:				;elle vaut (ClearStart - ResRout) /4
;	move.l	(a0)+,(a1)+
;	dbra	d0,copie2
;	jmp		12.w
;ResRout2:
;	movea.w	#$c,a0
;	moveq	#0,d0 
;	move.w	#-2,d1
;clear2:
;	move.l	d0,(a0)+
;	move.l	d0,(a0)+
;	move.l	d0,(a0)+
;	move.l	d0,(a0)+
;	dbf		d1,clear2
;	movea.l	4.w,a0
;	jmp		(a0)
;ClearStart2:
;zero:
;	dc.l	0
;	USER

/* reset030 */

/********************************************************************
*																	*
*	transfome en (unsigned int) les num‚ros de cluster sur 12 bits	*
*																	*
********************************************************************/

	XDEF swap_flopy_FAT

/* void swap__flopy_FAT( unsigned int *FAT, unsigned int *local_FAT, int numcl ) */
/* les paramŠtres sont dans A0, A1 et D0 dans l'ordre */

regs_used	REG d1-d2

swap_flopy_FAT:

	movem.l	#regs_used,-(a7)

	addq.w	#1,d0
	lsr.w	#1,d0	;/2 arrondi au dessus

	;m‚thode de swap : ab cd ef -> 0d ab 0e fc

suite3:
				;cluster inf‚rieur (12 bits de gauche)
	move.b	1(a1),d1	;cd
	and.b	#$0f,d1		;r‚cupŠre d
	lsl.w	#8,d1		;d‚calage … gauche d'un octet
	move.b	(a1),d1		;r‚cupŠre ab
	cmp.w	#$0ff1,d1
	blo.w	suite4
	or.w	#$f000,d1
suite4:
	move.w	d1,(a0)+

				;cluster sup‚rieur (12 bits de droite)
	move.b	2(a1),d1	;ef
	and.w	#$ff,d1		;efface l'octet de poids fort
	lsl.w	#4,d1		;d‚calage gauche de 4 bits
	move.b	1(a1),d2	;cd
	lsr.b	#4,d2		;0c
	or.b	d2,d1		;0e fc
	cmp.w	#$0ff1,d1
	blo.w	suite5
	or.w	#$f000,d1
suite5:
	move.w	d1,(a0)+

	addq.l	#3,a1
	dbra	d0,suite3

	movem.l	(a7)+,#regs_used
	rts

/* swap_flopy_FAT */

/********************************************************************
*																	*
*			‚change les deux octets du num‚ro de cluster			*
*				(format Intel -> format Motorola)					*
*																	*
********************************************************************/

	XDEF swap_FAT

/* void swap_FAT( unsigned int *FAT, unsigned int *local_FAT, int size ) */
/* les paramŠtres sont dans A0, A1 et D0 dans l'ordre */

regs_used	REG d1

swap_FAT:
	movem.l	#regs_used,-(a7)

	subq.w	#1,d0
suite2:
	move.w	#255,d1		;512 octets et 2 octets par No de cluster
suite1:

	move.b	(a1)+,1(a0)	;swap un mot
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	dbra	d1,suite1	;No suivant
	dbra	d0,suite2	;secteur suivant

	movem.l	(a7)+,#regs_used
	rts

/* swap_FAT */

/********************************************************************
*																	*
*	transfome les (unsigned int) en num‚ros de cluster sur 12 bits	*
*																	*
********************************************************************/

	XDEF re_swap_flopy_FAT

/* void re_swap__flopy_FAT( unsigned int *local_FAT, unsigned int *FAT, int numcl ) */
/* les paramŠtres sont dans A0, A1 et D0 dans l'ordre */

regs_used	REG d1-d2

re_swap_flopy_FAT:
	movem.l	#regs_used,-(a7)

	addq.w	#1,d0
	lsr.w	#1,d0	;/2 arrondi au dessus

	;m‚thode de swap : 0d ab 0e fc -> ab cd ef

suite:
	move.b	(a1)+,d1	;copie 0d
	and.b	#$0f,d1
	move.b	d1,1(a0)

	move.b	(a1)+,(a0)	;copie ab

	move.b	(a1)+,d1	;copie 0e dans D1
	lsl.b	#4,d1
	and.b	#$f0,d1

	move.b	(a1),d2		;copie c0
	lsl.b	#4,d2
	or.b	d2,1(a0)

	move.b	(a1)+,d2	;copie 0f sur D1
	lsr.b	#4,d2
	or.b	d2,d1
	move.b	d1,2(a0)

	addq.l	#3,a0
	dbra	d0,suite

	movem.l	(a7)+,#regs_used
	rts

/* re_swap_flopy_FAT */

/********************************************************************
*																	*
*		copie d'une entr‚e de directory real_dir_elt en dir_elt		*
*																	*
********************************************************************/

	XDEF trans_dir_elt_short

/* void trans_dir_elt( dir_elt *destination, real_dir_elt *source ) */
/* les paramŠtres sont dans A0 et A1 dans l'ordre */

trans_dir_elt_short:
	move.l	(a1)+,(a0)+	/* copie le nom et l'attribut 8+3+1=12=3*4 octets */
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	lea		10(a1),a1	/* 10 octets qui servent en VFAT mais pas ici */

	clr.w	(a0)+		/* norealdir … FALSE */

	move.b	(a1)+,1(a0)	/* time */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* date */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* first cluster (swap du mot) */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,3(a0)	/* size (swap du mot long) */
	move.b	(a1)+,2(a0)
	move.b	(a1)+,1(a0)
	move.b	(a1)+,(a0)

	clr.l	4(a0)		/* dir … NULL */

	rts

/* trans_dir_elt_short */

/********************************************************************
*																	*
*		copie d'une entr‚e de directory dir_elt en real_dir_elt		*
*																	*
********************************************************************/

	XDEF re_trans_dir_elt_short

/* void re_trans_dir_elt( real_dir_elt *destination, dir_elt *source ) */
/* les paramŠtres sont dans A0 et A1 dans l'ordre */

re_trans_dir_elt_short:
	move.l	(a1)+,(a0)+	/* copie le nom et l'attribut 8+3+1=12=3*4 octets */
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	clr.l	(a0)+		/* 10 octets qui servent en VFAT mais pas ici */
	clr.l	(a0)+
	clr.w	(a0)+

	lea		2(a1),a1	/* saute norealdir */

	move.b	(a1)+,1(a0)	/* time */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* date */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* first cluster (swap du mot) */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,3(a0)	/* size (swap du mot long) */
	move.b	(a1)+,2(a0)
	move.b	(a1)+,1(a0)
	move.b	(a1)+,(a0)

	rts

/* re_trans_dir_elt_short */

/********************************************************************
*																	*
	copie d'une entr‚e de directory real_dir_elt en dir_elt_vfat	*
*																	*
********************************************************************/

	XDEF trans_dir_elt_vfat

/* void trans_dir_elt( dir_elt_vfat *destination, real_dir_elt *source ) */
/* les paramŠtres sont dans A0 et A1 dans l'ordre */

trans_dir_elt_vfat:
	move.l	(a1)+,(a0)+	/* copie le nom et l'attribut 8+3+1=12=3*4 octets */
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	move.l	(a1)+,2+2+2+2+4+4+0(a0)	/* 10 octets qui servent en VFAT */
	move.l	(a1)+,2+2+2+2+4+4+4(a0)
	move.w	(a1)+,2+2+2+2+4+4+8(a0)

	clr.w	(a0)+		/* norealdir … FALSE */

	move.b	(a1)+,1(a0)	/* time */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* date */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* first cluster (swap du mot) */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,3(a0)	/* size (swap du mot long) */
	move.b	(a1)+,2(a0)
	move.b	(a1)+,1(a0)
	move.b	(a1)+,(a0)

	clr.l	4(a0)		/* dir … NULL */

	rts

/* trans_dir_elt_vfat */

/********************************************************************
*																	*
*	copie d'une entr‚e de directory dir_elt_vfat en real_dir_elt	*
*																	*
********************************************************************/

	XDEF re_trans_dir_elt_vfat

/* void re_trans_dir_elt( real_dir_elt *destination, dir_elt_vfat *source ) */
/* les paramŠtres sont dans A0 et A1 dans l'ordre */

re_trans_dir_elt_vfat:
	move.l	(a1)+,(a0)+	/* copie le nom et l'attribut 8+3+1=12=3*4 octets */
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	move.l	2+2+2+2+4+4+0(a1),(a0)+	/* 10 octets qui servent en VFAT */
	move.l	2+2+2+2+4+4+4(a1),(a0)+
	move.w	2+2+2+2+4+4+8(a1),(a0)+

	lea		2(a1),a1	/* saute norealdir */

	move.b	(a1)+,1(a0)	/* time */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* date */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,1(a0)	/* first cluster (swap du mot) */
	move.b	(a1)+,(a0)
	addq.l	#2,a0

	move.b	(a1)+,3(a0)	/* size (swap du mot long) */
	move.b	(a1)+,2(a0)
	move.b	(a1)+,1(a0)
	move.b	(a1)+,(a0)

	rts

/* re_trans_dir_elt_vfat */

/********************************************************************
*																	*
*		convertit un secteur en texte Hexa ou ASCII selon mode		*
*																	*
********************************************************************/

	XDEF convert_sect
	XREF ZeroChar

/* void	convert_sect( char *secteurBin, char *secteurLigne[], int ascii); */
/* les paramŠtres sont dans A0, 4(A7) et D0 dans l'ordre */

regs_used	REG a1-a2/d1-d2

convert_sect:
	movem.l	#regs_used,-(a7)
	move.l	4+4(a7),a1
	tst.b	d0
	beq		hexa

/* texte en ASCII */
	lea		4*4(a1),a1	/* pointe sur la premiŠre ligne */
	move.w	#15,d1
ligne:
	move.l	(a1)+,a2
	move.w	#31,d2
	addq.l	#6,a2	/* positionne juste apr‚s l'espace */
colonne:
	move.b	(a0)+,d0
	bne.b	ok
	move.b	ZeroChar,d0
ok:
	move.b	d0,(a2)+
	move.b	#" ",(a2)+
	dbra	d2,colonne
	dbra	d1,ligne

	movem.l	(a7)+,#regs_used
	rts

/* texte en hexa-d‚cimal */
hexa:
	lea		4*4(a1),a1	/* pointe sur la premiŠre ligne */
	move.w	#15,d1
_ligne:
	move.l	(a1)+,a2
	move.w	#31,d2
	addq.l	#6,a2	/* positionne juste apr‚s l'espace */
_colonne:
	move.b	(a0)+,d0
	lsr.b	#4,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.b	_ok1
	add.b	#'A'-'9'-1,d0
_ok1:
	move.b	d0,(a2)+

	move.b	-1(a0),d0
	and.b	#%1111,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.b	_ok2
	add.b	#'A'-'9'-1,d0
_ok2:
	move.b	d0,(a2)+

	dbra	d2,_colonne
	dbra	d1,_ligne

	movem.l	(a7)+,#regs_used
	rts

/* convert_sect*/
