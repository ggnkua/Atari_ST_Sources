
			.text
			.mc68000

;-------------------------------------------------------------------
			.xref exit
exit:
QuitBASIC:	movem.l	d0-d7/a0-a7,regBASIC
			movem.l	regCPX,d0-d7/a0-a7
			move.l	#'STOP',d0
			rts

;-------------------------------------------------------------------
regBASIC:	.dc.l	0,0,0,0,0,0,0,0			; d0-d7
			.dc.l	0,0,0,0,0,0,0,stackend	; a0-a7

regCPX:		.dc.l	0,0,0,0,0,0,0,0			; d0-d7
			.dc.l	0,0,0,0,0,0,0,0			; a0-a7

			.bss
			.export ctrl,ctrlsq
stackCPX:	.ds.b	40960
stackend:	.ds.l	4
systime:	.ds.l	1
ctrl:		.ds.b	1	; flag for pressing Ctrl-C
ctrlsq:		.ds.b	1	; flag for pressing Ctrl-S/Q


			.text
			.import basic
			.xref StartBASIC
StartBASIC:	movem.l	d0-d7/a0-a7,regCPX
			movem.l	regBASIC,d0-d7/a0-a7
			move.l	#QuitBASIC,-(sp)
			st		ctrlsq
			jmp		basic

			.import Bconstat
			.xref clock
			.xref BreakBASIC
			.xref WaitBASIC
			.xref Supexec

BreakBASIC:	moveq	#2,D0
			jsr		Bconstat(PC)	; wenn Taste gedrÅckt: switch
			tst.w	D0
			bne.s	WaitBASIC
			bsr.s	clock			; Systemzeit holen
			move.l	systime,D1
			cmp.l	D1,D0			; Fehlercheck
			bcs.s	WaitBASIC		; Zeit lÑuft nicht rÅckwÑrts!
			add.l   #10,D1			; 50 ms drauf
			cmp.l	D1,D0			; Zeit um?
			bcs.s	bye_break;		; nein

WaitBASIC:	movem.l	d0-d7/a0-a7,regBASIC ; Context-Wechsel
			movem.l	regCPX,d0-d7/a0-a7
bye_break:	rts

			.xref ContBASIC
ContBASIC:	movem.l	d0-d7/a0-a7,regCPX
			movem.l	regBASIC,d0-d7/a0-a7
			bsr.s	clock			; Systemzeit holen
			move.l	D0,systime
			rts

clock__:	lea		$4BA.w,A0
			move.l	(A0),D0
			rts

clock:		lea		clock__(PC),A0

Supexec:	move.l	A0,-(SP)
			move.w	#38,-(SP)
			trap	#14
			addq.l	#6,SP
			rts

			.data
			.xref m2,xywh
;MOBLK-Struktur m2
m2:			dc.w	0
;GRECT-Struktur
xywh:		dc.w	0
			dc.w	0
			dc.w	256
			dc.w	176
