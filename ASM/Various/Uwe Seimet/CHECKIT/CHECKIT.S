*****************************
*			 *
* CHECKIT V1.0		 *
*			 *
* Vektorcheck fÅr ST und TT *
*			 *
* April 1992 by Uwe Seimet  *
*			 *
*****************************


GEMDOS	= 1
CCONWS	= 9
PTERMRES	= 49
MSHRINK	= 74


BIOS	= 13
SETEXC	= 5


XBIOS	= 14
KBDVBASE	= 34
SUPEXEC	= 38


etv_timer = $400
resvalid	= $426
resvector = $42a
_memtop	= $436
nvbls	= $454
_vblqueue = $456
_sysbase	= $4f2
_p_cookies = $5a0
_ramtop	= $5a4
_ramvalid = $5a8


ttmagic	= $1357bd13	;Magic fÅr TT-RAM


	text

	move.l 4(sp),a0
	move.l 12(a0),a6		;LÑnge des
				;TEXT-Segments
	add.l 20(a0),a6		;LÑnge DATA
	add.l 28(a0),a6		;LÑnge BSS
	lea $100(a6),a6		;fÅr Basepage
	pea (a6)
	pea (a0)
	clr -(sp)
	move #MSHRINK,-(sp)	;ÅberzÑhligen
	trap #GEMDOS		;Speicher
	lea 12(sp),sp		;freigeben

	pea tttest(pc)
	move #SUPEXEC,-(sp)	;auf TT
	trap #XBIOS		;testen
	addq.l #6,sp

	pea gemdos(pc)
	move #33,-(sp)
	move #SETEXC,-(sp)	;neuer
	trap #BIOS		;GEMDOS-Vektor
	addq.l #8,sp
	move.l d0,o_gemdos

	pea term(pc)
	move #258,-(sp)
	move #SETEXC,-(sp)	;neuer Vektor
	trap #BIOS		;fÅr etv_term
	addq.l #8,sp
	move.l d0,o_term

	pea message
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp

	clr -(sp)
	pea (a6)
	move #PTERMRES,-(sp)	;Programm
	trap #GEMDOS		;resident halten


	dc.l "XBRA"
	dc.l "USCK"
o_term:	dc.l 0
term:	tst.b resflg		;nichts tun
	bne cont			;bei residen-
				;tem Programm
	move.l _sysbase,a0
	move.l a0,a1
	move.l $28(a1),a0
	move.l (a0),a0		;Prozeû-
				;Deskriptor
	cmp #$0102,$02(a1)	;neuer als
	bcc.s newtos		;TOS 1.00-
	move.l $873c,a0		;Default fÅr
				;spanisches
				;TOS 1.00
	move $1c(a1),d0		;LÑndercode
	lsr #1,d0		;isolieren
	cmp #4,d0		;spanisch?
	beq.s newtos		;ja-
	move.l $602c,a0		;fÅr TOS 1.00
newtos:	move.l 8(a0),a1		;Beginn des
	move.l a1,a2		;TEXT-Segments
	add.l 12(a0),a2		;+ LÑnge TEXT
	add.l 20(a0),a2		;+ LÑnge DATA
	add.l 28(a0),a2		;+ LÑnge BSS
				;ergibt
				;Endadresse

	move nvbls,d0
	move.l _vblqueue,a0
	bra.s checkvbl
checkv:	move.l (a0)+,d1
	cmp.l d1,a1		;zeigt Vektor
	bcc.s checkvbl		;in Programm-
	cmp.l d1,a2		;bereich?
	bcs.s checkvbl
	clr.l -4(a0)		;Vektor
checkvbl:dbra d0,checkv		;lîschen

	lea $08,a0
	moveq #8,d0
	bsr.s check

	lea $80,a0		;TRAP-Vektoren
	moveq #16,d0
	bsr.s check

	lea $64,a0		;Autovektor
	moveq #6,d0		;Interrupts
	bsr.s check

	lea $0100,a0		;MFP1-
	moveq #15,d0		;Interrupts
	bsr.s check

	tst.b ttflg
	beq.s nott
	lea 320,a0		;MFP2-, SCC-
	moveq #31,d0		;Interrupts
	bsr.s check		;nur bei TT

nott:	lea $0114,a0		;Systemtimer
	moveq #1,d0
	bsr.s check		:und IKBD/MIDI

	lea etv_timer,a0
	moveq #2,d0
	bsr.s check		;etv-Vektoren

	movem.l a1-a2,-(sp)
	move #KBDVBASE,-(sp)
	trap #XBIOS
	addq.l #2,sp
	movem.l (sp)+,a1-a2
	move.l d0,a0
	moveq #8,d0
	bsr.s check

	movem.l a1-a2,-(sp)
	dc.w $a000
	move.l a2,a0
	movem.l (sp)+,a1-a2
	moveq #15,d0		;LINEA-
	bsr.s check		;Vektoren

	cmp.l #$31415926,resvalid
	bne.s cont
	move.l resvector,a0
	moveq #0,d0
	bsr.s check

cont:	move.l o_term(pc),a0	;weiter
	jmp (a0)			;im TOS


*Testen, ob Vektor in ehemaligen Programmbereich
*zeigt. Wenn ja, aus Vektorkette enfernen oder
*auf RTE setzen.
check:
	move.l #iret,d2		;Zeiger
	move.l a0,a3		;auf RTE
trp:	move.l (a3),d1
	cmp.l #ttmagic,_ramvalid
	bne.s nottram		;kein TT-RAM-
	cmp.l _ramtop,d1		;zeigt Vektor
	bcc.s invalid		;in TT-RAM?
	cmp.l #$01000000,d1
	bcc.s test
nottram:	cmp.l _memtop,d1		;zeigt Vektor
	bcc.s invalid		;in ST-RAM?
	cmp.l #$0400,d1
	bcs.s invalid
*Vektor ist gÅltig und zeigt in ST- oder TT-RAM
test:	cmp.l d1,a1		;zeigt Vektor
	bcc.s valid		;in Programm-
	cmp.l d1,a2		;bereich?
	bcs.s valid		;nein-
	move.l d1,a4
	cmp.l #"XBRA",-12(a4)	;XBRA benutzt?
	bne noxbra
	move.l -4(a4),d2		;neu verketten
noxbra:	move.l d2,(a3)
valid:	move.l d1,a3
	cmp.l #"XBRA",-12(a3)
	beq trp
invalid:	addq.l #4,a0		;nÑchster
	dbra d0,check		;Vektor
	rts

*Auf TT testen
tttest:
	move.l _p_cookies,d0
	beq.s nojar
	move.l d0,a0
loop:	movem.l (a0)+,d0-d1
	tst.l d0
	beq.s nojar
	cmp.l #"_MCH",d0
	bne loop
	cmp.l #$00020000,d1	;TT?
	scc ttflg
nojar:	rts


	dc.l "XBRA"
	dc.l "USCK"
o_gemdos:dc.l 0
gemdos:
	lea 8(sp),a0		;Supervisor-
	btst #5,(sp)               ;Modus?
	bne super                  ;ja-
	move.l usp,a0
super:	cmp #PTERMRES,(a0)	;residentes
	seq resflg		;Programm?
	move.l o_gemdos(pc),a0
	jmp (a0)			;weiter im TOS


iret:	rte


	data

message:	dc.b $0d,$0a,"CHECKIT V1.0 installiert"
	dc.b $0d,$0a
	dc.b "1992 by Uwe Seimet",$0d,$0a,0


	bss

ttflg:	ds.b 1	;Flag fÅr TT

resflg:	ds.b 1	;Flag fÅr residentes Programm