******************************************
*                                        *
* MAGTOROM V1.0                          *
*                                        *
* Schreibschutz fÅr MagiC ab Version 2.0 *
*                                        *
* auf Ataris mit MC68030                 *
*                                        *
* (C) Juli 1994 by Uwe Seimet            *
*                                        *
******************************************


	loadfast
	ttram
	ttmem
	mc68030


	include "SYSTEM.ASM"


	text

*cookie- und PMMU-Manipulationen
*nur im Supervisor-Modus

	clr.l -(sp)
	move #SUPER,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l d0,d7

	move.l #"_CPU",d0
	bsr get_cookie
	lea cpuerr,a6

*_CPU-cookie vorhanden?
*Falls ja, auf 68030 testen

	beq error
	cmp #30,d2
	bne error

*Ist MagiC Åberhaupt installiert?

	move.l #"MagX",d0
	bsr get_cookie
	lea magerr,a6
	beq error

*Wird die PMMU schon benutzt?

	move.l #"PMMU",d0
	bsr get_cookie
	lea mmuerr,a6
	bne error

*Es werden maximal 16 Tabellen-Deskriptoren
*und 512 Seiten-Deskriptoren benîtigt.

	pea 4*(16+512)+15
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	lea memerr,a6
	move.l a0,d6
	beq error

*Tabellen mÅssen auf einer Langwortgrenze liegen

	add.l #15,d6
	and #$fff0,d6

*Start der Tabellen-Deskriptoren

	move.l d6,a5

*Start der Seiten-Deskriptoren

	lea 64(a5),a4

*Startseite des Systembereichs ermitteln

	move.l _sysbase,a0
	move.l 8(a0),d1
	add.l #$7fff,d1
	and #$8000,d1
	move.l d1,a1
	move.l d1,a3
	cmp.l #$01000000,a1
	bcc.s ttram
	move.l 20(a0),a2
	cmp.l #$87654321,(a2)+
	beq.s magaes
	lea 12(a0),a2
magaes:	move.l (a2),a2
	bra.s stram
ttram:	move.l _____md,a2
stram:

*Grîûe des Systembereichs

	move.l a2,d2
	sub.l a1,d2

*Deskriptor ermitteln, der auf
*Systemstart zeigt

	ptestr #7,(a3),#3,a0

*Early Termination Deskriptoren aufbauen

	move.l (a0),d1
	and #$8000,d1
	or #$0001,d1
	moveq #15,d0
setterm:	move.l d1,(a5)+
	add.l #$00100000,d1
	dbra d0,setterm

*Hardwarebereich nicht cachen

	cmp.l #$01000001,d1
	bne.s nostram
	or.l #$00000040,-4(a5)

*Tabellen-Deskriptoren einrichten

nostram:	move.l d2,d0
	divu.l #$01000000,d0
	move.l d6,a1
	move.l a4,d1
	or #$0002,d1
settab:	move.l d1,(a1)+
	add.l #128,d1
	dbra d0,settab

*Nun die Seiten-Deskriptoren

	move.l (a0),d1
	and #$8000,d1
	or #$0001,d1
	move #511,d0
setpage:	move.l d1,(a5)+
	add.l #$00008000,d1
	dbra d0,setpage

*Originaltabelle erweitern

	ptestr #7,(a3),#2,a0
	or #$0002,d6
	move.l d6,(a0)

*PMMU neu initialisieren,
*keine transparente öbersetzung

	pflusha
	pmove tt0reg,tt0

*MagiC-Pages schreibschÅtzen

	move.l _sysbase,a0
	move.l 8(a0),d1
	add.l #$7fff,d1
	and #$8000,d1
	ptestr #7,(d1.l),#7,a4
	divu #$8000,d2
	bra.s protnxt
prot:	or.l #$0004,(a4)+
protnxt:	dbra d2,prot
	pflusha

*PMMU-cookie einrichten

	bsr add_cookie

*das war schon alles

	move.l d7,-(sp)
	move #SUPER,-(sp)	;zurÅck in
	trap #GEMDOS	;User-Modus
	addq.l #6,sp
	pea message
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	clr -(sp)
	pea 128	;fÅr Basepage
	move #PTERMRES,-(sp)	;Tabellen
	trap #GEMDOS	;resident halten

error:
	move.l d7,-(sp)
	move #SUPER,-(sp)	;zurÅck in
	trap #GEMDOS	;User-Modus
	addq.l #6,sp
	pea (a6)
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	pea notinst
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	clr -(sp)
	trap #GEMDOS

*Cookie holen, falls vorhanden

get_cookie:
	move.l _p_cookies,d1
	beq.s getend
	move.l d1,a0
getloop:movem.l (a0)+,d1-d2
	tst.l d1
	beq.s getend
	cmp.l d0,d1
	bne getloop
	moveq #1,d0
getend:	rts

*Cookie jar bei Bedarf erweitern

add_cookie:
	move.l _p_cookies,a0
addloop:	movem.l (a0)+,d0-d1
	tst.l d0
	bne addloop
	move.l a0,d2
	sub.l _p_cookies,d2

*Zahl der cookies bisher

	lsr.l #3,d2

*Ein cookie kommt hinzu
	addq.l #1,d2

*Cookie jar voll?

	cmp.l d1,d2
	bcs.s nofull

*Wenn ja, 8 weitere cookies

	addq.l #8,d2
	asl.l #3,d2
	move.l d2,-(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	tst.l d0
	beq.s adderr
	move.l _p_cookies,a1
	move.l d0,a0
	move.l d0,a2
addcopy:	movem.l (a1)+,d0-d1
	movem.l d0-d1,(a0)
	addq.l #8,a0
	tst.l d0
	bne addcopy
	move.l a2,_p_cookies

*PMMU-cookie einrichten

nofull:	subq.l #8,a0
	move.l #"PMMU",(a0)+
	clr.l (a0)+
	movem.l d0-d1,(a0)
adderr:	rts


	data

message:	dc.b $0d,$0a,$1b,"pMAGTOROM V1.0 installiert",$1b,"q",$0d,$0a
         dc.b "Ω 1994 by Uwe Seimet",$0d,$0a,0

notinst:	dc.b $0d,$0a,"MAGTOROM nicht installiert!",$0d,$0a,0

cpuerr:	dc.b $0d,$0a,"Kein MC68030 vorhanden!",0

magerr:	dc.b $0d,$0a,"MagiC ist nicht installiert!",0

mmuerr:	dc.b $0d,$0a,"Es ist bereits ein PMMU-Programm aktiv!",0

memerr:	dc.b $0a,$0a,"Zu wenig Hauptspeicher!",0


	bss

tt0reg:	ds.l 1