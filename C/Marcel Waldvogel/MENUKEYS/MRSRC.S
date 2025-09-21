;
; MRSRC.S - Resourcen fest in Programme einbinden
;
; Version fÅr TurboC V2.0 (fÅr V1.x muss "global" angepasst werden)
;
; Assemblerversion: Marcel Waldvogel
; Idee: mrsrc_load von Laser C, stark verbessert und erweitert.
;
; 08.02.90 mw Angepasst an _GemParBlk-Struktur des TC 2.0
; 20.07.90 mw Aufgeteilt in mrsrc_load und mrsrc_install
; 12.08.90 mw mrsrc_gaddr() eingefÅhrt, Relozierfehler behoben
; 03.01.91 mw Nochmals Åberarbeitet und screenw eingefÅhrt
;
; Aufrufe:
; ParameterÅbergabe wie bei TC, verÑndert werden A0-A1/D0-D2
;
; void mrsrc_load(int rsc_buffer[], int fontw, int fonth, int screenw);
; void mrsrc_gaddr(void *rsc, int type, int index, void **ptr);
;
;
; mrsrc_load() wird anstelle von rsrc_load() aufgerufen, um eine
; bereits im Programm vorhandene Resource zu relozieren und an die
; aktuelle Auflîsung anzupassen.
; Danach werden die Adressen der Objekte und freien Strings mittels
; mrsrc_gaddr() bestimmt. Falls Parameter rsc == NULL, dann wird die
; Originalroutine aufgerufen. Somit ist es mîglich, alternativ die
; eingebaute Resource oder eine nachgeladene Resource zu verwenden.

		.xdef mrsrc_load, mrsrc_gaddr
		.xref rsrc_gaddr, _GemParBlk


global		= 30 ; Offset des global-Arrays relativ zu _GemParBlk
		;TC 1.0: 22, TC 2.0: 30

		;rsrc_gaddr()-Opcodes
R_TREE		= 0
R_STRING	= 5

		;Der Resource-Header besteht aus:
rsh_vsrn	= 0
rsh_object	= 2
rsh_tedinfo	= 4
rsh_iconblk	= 6
rsh_bitblk	= 8
rsh_frstr	= 10
rsh_string	= 12
rsh_imdata	= 14
rsh_frimg	= 16
rsh_trindex	= 18
rsh_nobs	= 20
rsh_ntree	= 22
rsh_nted	= 24
rsh_nib 	= 26
rsh_nbb 	= 28
rsh_nstring	= 30
rsh_nimages	= 32
rsh_rssize	= 34

		;Ein Objekt besteht aus:
ob_next 	= 0
ob_first	= 2
ob_last 	= 4
ob_type 	= 6
ob_flags	= 8
ob_state	= 10
ob_spec 	= 12	;LONG!!
ob_x		= 16
ob_y		= 18
ob_width	= 20
ob_height	= 22

		;******************************************************************

mrsrc_gaddr:	moveq	#0,D2
		cmp.l	D2,A0			;Eigener Baum angegeben?
		beq	go_rsrc_gaddr		;Nein ->
		move.w	rsh_trindex(A0),D2	;Default
		tst.w	D0			;R_TREE
		beq	getitem

		move.w	rsh_frstr(A0),D2	;Weiterer Versuch
		cmp.w	#R_STRING,D0
		beq	getitem			;Ja, R_STRING!

		moveq	#0,D0			;Fehler, kann nur R_TREE
		rts				;und R_STRING!

getitem:	adda.l	D2,A0			;Zum Baumanfang
		lsl.w	#2,D1			;4*index
		adda.w	D1,A0
		move.l	(A0),(A1)		;Zeiger zurÅckgeben
		moveq	#1,D0			;OK
		rts

go_rsrc_gaddr:	move.l	A1,A0			;RÅckgabewert
		jmp	rsrc_gaddr

**********************************************************************

mrsrc_load:	movem.l D5-D7/A5,-(A7)	;Sichern
		movea.l A0,A5		;Bufferadresse
		move.w	D0,D5		;Zeichenbreite
		move.w	D1,D6		;Zeichenhîhe

		;******************************************************************

rel_tree:	moveq.l #0,D0 			;Unsigned Extend
		move.w	rsh_trindex(A5),D0
		lea	0(A5,D0.l),A0		;Adresse der Baumtabelle
		move.w	rsh_ntree(A5),D7
		subq.w	#1,D7
		bcs	rel_obj
		move.l	A5,D0
treeloop:	add.l	D0,(A0)+
		dbf	D7,treeloop

		;******************************************************************

rel_frstr:	moveq.l #0,D0 			;Unsigned Extend
		move.w	rsh_frstr(A5),D0
		lea	0(A5,D0.l),A0		;Adresse der Stringtabelle
		move.w	rsh_nstring(A5),D7
		subq.w	#1,D7
		bcs	rel_obj
		move.l	A5,D0
strloop:	add.l	D0,(A0)+
		dbf	D7,strloop

		;******************************************************************

rel_obj:	moveq.l #0,D0			;Objektgrîssen anpassen und
		move.w	rsh_object(A5),D0	;ob_spec wenn nîtig relozieren
		lea	0(A5,D0.l),A0
		move.w	rsh_nobs(A5),D7
		subq.w	#1,D7
		bcs	rel_ted
		moveq.l #0,D0
objloop:	move.w	ob_type(A0),D0

; Bytevergleiche wegen Extended Object Types
		cmpi.b	#21,D0		;Bei 21-23,
		bcs	norelobspec
		cmpi.b	#23,D0
		bls	relobspec

		cmpi.b	#26,D0		;26 und
		beq	relobspec

		cmpi.b	#28,D0		;28-32 muss ob_spec reloziert werden.
		bcs	norelobspec
		cmpi.b	#32,D0
		bhi	norelobspec

relobspec:	move.l	A5,D0
		add.l	D0,ob_spec(A0)

norelobspec:	lea	ob_x(A0),A1	;Objektgrîssen anpassen
		move.w	D5,D0
		bsr	obfix

		lea	ob_y(A0),A1
		move.w	D6,D0
		bsr	obfix

		lea	ob_width(A0),A1
		cmp.w	#80,(A1)	;Breite genau 80 Zeichen?
		bne	widthnot80	;Nein ->
		move.w	D2,(A1)		;Dann setze die Breite
		bra	widthwas80	;So, Breite angepasst

widthnot80:	move.w	D5,D0
		bsr	obfix

widthwas80:	lea	ob_height(A0),A1
		move.w	D6,D0
		bsr	obfix

		lea	24(A0),A0
		dbf	D7,objloop

		;******************************************************************

rel_ted:	moveq.l #0,D0		;Tedinfos relozieren
		move.w	rsh_tedinfo(A5),D0
		lea	0(A5,D0.l),A0
		move.w	rsh_nted(A5),D7
		subq.w	#1,D7
		bcs	rel_ib
tedloop:	move.l	A5,D0
		add.l	D0,(A0)+
		add.l	D0,(A0)+
		add.l	D0,(A0)
		lea	28-8(A0),A0	;Insgesamt pro Durchgang +28
		dbf	D7,tedloop

rel_ib: 	moveq.l #0,D0		;Iconblocks relozieren
		move.w	rsh_iconblk(A5),D0
		lea	0(A5,D0.l),A0
		move.w	rsh_nib(A5),D7
		subq.w	#1,D7
		bcs	rel_bb
		move.l	A5,D0
ibloop: 	add.l	D0,(A0)+
		add.l	D0,(A0)+
		add.l	D0,(A0)
		lea	34-8(A0),A0
		dbf	D7,ibloop

rel_bb: 	moveq.l #0,D0		;Bitblocks relozieren
		move.w	rsh_bitblk(A5),D0
		lea	0(A5,D0.l),A0
		move.w	rsh_nbb(A5),D7
		subq.w	#1,D7
		bcs	mrl_ret
		move.l	A5,D0
bbloop: 	add.l	D0,(A0)
		lea	14(A0),A0
		dbf	D7,bbloop

mrl_ret:	movem.l (A7)+,D5-D7/A5
		rts	

		;******************************************************************

		;Subroutine "obfix": multipliziert das, wohin A1 zeigt, mit D0
		;(Ñndert D0/D1)
obfix:		move.w	(A1),D1
		ext.w	D1		;Nur Low-Byte (Zeichenposition)
		muls.w	D0,D1 		;Mal Zeichengrîsse
		move.b	(A1),D0		;Nur High-Byte (Pixeloffset)
		ext.w	D0		;...als Word
		add.w	D0,D1 		;...als Offset
		move.w	D1,(A1)		;...und alles zusammen zurÅck
		rts

