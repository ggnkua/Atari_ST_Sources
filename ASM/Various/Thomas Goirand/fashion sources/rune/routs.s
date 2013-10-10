	text
***********************************************************
*** Routine de conversion d'un long vers une chaine     ***
*** representant la taille d'un fichier en B, KB, GB... ***
***********************************************************
	XDEF	long_2_filesize_rout
long_2_filesize_rout
	movem.l	d5-d7/a6,-(sp)
	move.l	20+4(sp),d7
	move.l	20+0(sp),a6

* Les bornes du calculs sont faites ainsi :
;o	9
;o	99
;o	999
;o	9 999
;
;ko	9.999 * 1024	= 10 238
;ko	99.99 * 1024	= 102 389
;ko	999.9 * 1024	= 1 023 897
;
;mo	9.999 * 1024 * 1024	= 10 484 711
;mo	99.99 * 1024 * 1024	= 104 847 114
;mo	999.9 * 1024 * 1024	= 1 048 471 142
;
;go	9.999 * 1024 * 1024 * 1024	= 10 736 344 498
;go	99.99 * 1024 * 1024 * 1024	= 107 363 444 981
;go	999.9 * 1024 * 1024 * 1024	= 1 073 634 449 817
;
;to

	cmp.l	#9,d7
	ble	octet1
	cmp.l	#99,d7
	ble	octet2
	cmp.l	#999,d7
	ble	octet3
	cmp.l	#9999,d7
	ble	octet4

	cmp.l	#10239,d7
	ble	kilo1
	cmp.l	#102390,d7
	ble	kilo2
	cmp.l	#1023898,d7
	ble	kilo3

	cmp.l	#10484712,d7
	ble	mega1
	cmp.l	#104847115,d7
	ble	mega2
	cmp.l	#1048471143,d7
	ble	mega3

	cmp.l	#10736344499,d7
	ble	giga1
	cmp.l	#107363444982,d7
	ble	giga2
	cmp.l	#1073634449818,d7
	ble	giga3
	illegal

	*----------*
octet1	; 9 B
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	add.b	#"0",d7
	move.b	d7,(a6)+
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
octet2	; 99 B
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.l	d7,d6
octdiz	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts

octet3	; 999 B
	move.b	#" ",(a6)+
	move.b	#" ",(a6)+
	move.l	d7,d6

octcent
	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	clr.w	d6
	swap	d6
	bra	octdiz

octet4	; 9 999 B
	move.l	d7,d6
	divu.w	#1000,d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	clr.w	d6
	swap	d6
	move.b	#" ",(a6)+
	bra	octcent

kilo1	; 9.999 KB
	swap	d7
	move.l	d7,d6
	divu.l	#1024,d6

	
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	clr.w	d6
	swap	d6

	mulu.w	#1000,d6
	clr.w	d6
	swap	d6

	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#" ",(a6)+
	move.b	#"K",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts

kilo2
	move.l	d7,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.l	d6,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	sub.l	d5,d7

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	swap	d7
	divu.l	#1024,d7

	mulu.w	#100,d7
	clr.w	d7
	swap	d7

	divu.w	#10,d7
	add.b	#"0",d7
	move.b	d7,(a6)+
	clr.w	d7
	swap	d7

	add.b	#"0",d7
	move.b	d7,(a6)+

	move.b	#" ",(a6)+
	move.b	#"K",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
kilo3
	move.l	d7,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.l	d6,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	sub.l	d5,d7

	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	swap	d7
	divu.l	#1024,d7

	mulu.w	#10,d7
	clr.w	d7
	swap	d7

	add.b	#"0",d7
	move.b	d7,(a6)+

	move.b	#" ",(a6)+
	move.b	#"K",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
mega1
	lsr.l	#8,d7
	lsr.l	#2,d7
	swap	d7
	move.l	d7,d6
	divu.l	#1024,d6

	
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	clr.w	d6
	swap	d6

	mulu.w	#1000,d6
	clr.w	d6
	swap	d6

	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#" ",(a6)+
	move.b	#"M",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
mega2
	lsr.l	#8,d7
	lsr.l	#2,d7

	move.l	d7,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.l	d6,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	sub.l	d5,d7

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	swap	d7
	divu.l	#1024,d7

	mulu.w	#100,d7
	clr.w	d7
	swap	d7

	divu.w	#10,d7
	add.b	#"0",d7
	move.b	d7,(a6)+
	clr.w	d7
	swap	d7

	add.b	#"0",d7
	move.b	d7,(a6)+

	move.b	#" ",(a6)+
	move.b	#"M",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
mega3
	lsr.l	#8,d7
	lsr.l	#2,d7

	move.l	d7,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.l	d6,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	sub.l	d5,d7

	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	swap	d7
	divu.l	#1024,d7

	mulu.w	#10,d7
	clr.w	d7
	swap	d7

	add.b	#"0",d7
	move.b	d7,(a6)+

	move.b	#" ",(a6)+
	move.b	#"M",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts

giga1
	moveq.l	#20,d6
	lsr.l	d6,d7

	swap	d7
	move.l	d7,d6
	divu.l	#1024,d6

	
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	clr.w	d6
	swap	d6

	mulu.w	#1000,d6
	clr.w	d6
	swap	d6

	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#" ",(a6)+
	move.b	#"G",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
giga2
	moveq.l	#20,d6
	lsr.l	d6,d7

	move.l	d7,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.l	d6,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	sub.l	d5,d7

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	swap	d7
	divu.l	#1024,d7

	mulu.w	#100,d7
	clr.w	d7
	swap	d7

	divu.w	#10,d7
	add.b	#"0",d7
	move.b	d7,(a6)+
	clr.w	d7
	swap	d7

	add.b	#"0",d7
	move.b	d7,(a6)+

	move.b	#" ",(a6)+
	move.b	#"G",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts

giga3
	moveq.l	#20,d6
	lsr.l	d6,d7

	move.l	d7,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.l	d6,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	sub.l	d5,d7

	divu.w	#100,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#".",(a6)+

	swap	d7
	divu.l	#1024,d7

	mulu.w	#10,d7
	clr.w	d7
	swap	d7

	add.b	#"0",d7
	move.b	d7,(a6)+

	move.b	#" ",(a6)+
	move.b	#"G",(a6)+
	move.b	#"B",(a6)+
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts
***************************************************
*** Routine convertissant l'heure en une chaine ***
***************************************************
	XDEF	time_2_string_rout
time_2_string_rout
	movem.l	d5-d7/a6,-(sp)
	move.w	20+6(sp),d7	; heure
	move.l	20+2(sp),a6	; chaine ou taper
	move.w	20+0(sp),d5	; seconde oui/non

* Heure
	moveq.l	#0,d6
	bfextu	d7{16:5},d6
	bsr	datime_convert

	move.b	#"h",(a6)+

* Minute
	moveq.l	#0,d6
	bfextu	d7{21:6},d6
	bsr	datime_convert

* Seconde
	tst.w	d5
	beq	.no_seconde

	move.b	#"m",(a6)+

	moveq.l	#0,d6
	bfextu	d7{27:5},d6
	lsl.w	#1,d6
	bsr	datime_convert

.no_seconde
	move.b	#0,(a6)+
	movem.l	(sp)+,d5-d7/a6
	rts

***************************************************
*** Routine convertissant la date en une chaine ***
***************************************************
	XDEF	date_2_string_rout
date_2_string_rout
	movem.l	d6/d7/a6,-(sp)
	move.w	16+4(sp),d7	; heure
	move.l	16+0(sp),a6	; chaine ou taper

* Mois
	moveq.l	#0,d6
	bfextu	d7{23:4},d6
	bsr	datime_convert

	move.b	#"/",(a6)+

* Jour
	moveq.l	#0,d6
	bfextu	d7{27:5},d6
	bsr	datime_convert

	move.b	#"/",(a6)+

* Annee
	moveq.l	#0,d6
	bfextu	d7{16:7},d6
	add.w	#1980,d6

	divu.w	#1000,d6
;	add.b	#"0",d6
;	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#100,d6
;	add.b	#"0",d6
;	move.b	d6,(a6)+
	clr.w	d6
	swap	d6

	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+

	move.b	#0,(a6)+

	movem.l	(sp)+,d6/d7/a6
	rts
*****************************************************************************************************************
* Converti un word dans d6 (poid fort a 0) en 2 charactere dans (a6)+ pour l'affichage d'une date ou de l'heure *
*****************************************************************************************************************
datime_convert
	divu.w	#10,d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	clr.w	d6
	swap	d6
	add.b	#"0",d6
	move.b	d6,(a6)+
	rts

**************************************************************************
*** Routine convertissant les attributs au format GEMDOS vers du texte ***
**************************************************************************
	XDEF	dosattrb_2_string_rout
dosattrb_2_string_rout
	movem.l	d7/a6,-(sp)
	move.w	12+4(sp),d7	; attributs
	move.l	12+0(sp),a6	; chaine ou taper

	btst	#0,d7
	beq	.no_readonly
	move.b	#"r",(a6)+
	bra.s	.readonly_ok	; readonly
.no_readonly
	move.b	#"-",(a6)+
.readonly_ok

	btst	#2,d7
	beq	.no_system
	move.b	#"s",(a6)+
	bra.s	.system_ok	; system
.no_system
	move.b	#"-",(a6)+
.system_ok

	btst	#1,d7
	beq	.no_hidden
	move.b	#"h",(a6)+
	bra.s	.hidden_ok	; hidden
.no_hidden
	move.b	#"-",(a6)+
.hidden_ok

	btst	#0,d7
	beq	.no_archive
	move.b	#"a",(a6)+
	bra.s	.archive_ok	; archive
.no_archive
	move.b	#"-",(a6)+
.archive_ok

	move.b	#0,(a6)+
	movem.l	(sp)+,d7/a6
	rts


